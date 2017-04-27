defmodule ResuelveAuth.Plug.EnsurePermissions do
  @moduledoc """
  This plug provides permissions checking.
  correct permissions set in the claims found on the connection.
  ### Example
      alias ResuelveAuth.Plug.EnsurePermissions
      # read and write permissions for the admin set
      plug EnsurePermissions, admin: [:read, :write], handler: SomeMod,
      # read AND write permissions for the admin set
      # AND :profile for the default set
      plug EnsurePermissions, admin: [:read, :write],
                              default: [:profile],
                              handler: SomeMod
      # read AND write permissions for the admin set
      # OR :profile for the default set
      plug EnsurePermissions, one_of: [%{admin: [:read, :write]},
                              %{default: [:profile]}],
                              handler: SomeMod
  On failure will be handed the connection with the conn,
  and parameters where reason: `:forbidden`
  The handler will be called on failure.
  The `:unauthorized` function will be called when a failure is detected.
  This is based on Guardian implementation of permissions matching
  """

  require Logger
  import Plug.Conn


  @doc """
  Initialize plug with specified options
  """
  @spec init(map) :: map
  def init(opts) do
    opts = Enum.into(opts, %{})
    key = Map.get(opts, :key, :default)
    handler = Map.get(opts, :handler)

    perm_sets = case Map.get(opts, :one_of) do
      nil ->
        single_set = Map.drop(opts, [:handler, :key, :one_of])
        if Enum.empty?(single_set) do
          []
        else
          [single_set]
        end
      one_of ->
        if Keyword.keyword?(one_of) do
          [Enum.into(one_of, %{})]
        else
          one_of
        end
    end

    handler_tuple = if handler do
      {handler, :unauthorized}
    else
      {ResuelveAuth.Plug.ErrorHandler, :unauthorized}
    end
    %{
      handler: handler_tuple,
      key: key,
      perm_sets: perm_sets
    }

  end

  @doc "This function check permissions calling a service"
  @spec call(Plug.Conn, map) :: Plug.Conn
  def call(conn, opts) do
    auth_token = get_req_header(conn, "authorization")
    sets =  Map.get(opts, :perm_sets)
    if  matches_permissions?(auth_token, sets) do
      conn
    else
      handle_error(conn, opts)
    end

  end


  # When any permissions where set for matching
  defp matches_permissions?(_, []), do: true

  # Do the connection to permissions matching service
  defp matches_permissions?(auth_token, sets) do

    # Connection to authentication Api
    url = "#{System.get_env("AUTH_HOST")}/api/permissions"
    headers = ["Authorization": "#{auth_token}", "Accept": "Application/json; Charset=utf-8", "Content-type": "application/json"]
    options = [recv_timeout: 30_000]
    body = Poison.encode! %{sets: sets}

    response = HTTPoison.post!(url, body, headers, options)

    is_authorized?
      = response.body
      |> Poison.decode!
      |> Map.get("id")
    is_authorized? == "AUTHORIZED"
  end

  #  If there is an error, halt the connection and send a reason
  defp handle_error(%Plug.Conn{params: params} = conn, opts) do
    conn = conn |> assign(:auth_failure, :forbidden) |> halt
    params = Map.merge(params, %{reason: :forbidden})

    {mod, meth} = Map.get(opts, :handler)

    apply(mod, meth, [conn, params])
  end

end
