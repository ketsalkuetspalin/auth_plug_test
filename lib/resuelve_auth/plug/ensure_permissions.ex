defmodule ResuelveAuth.Plug.EnsurePermissions do
  @moduledoc """
  Use this plug to ensure that there are the
  correct permissions set in the claims found on the connection.
  ### Example
      alias Resuelve.Plug.EnsurePermissions
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
  and params where reason: `:forbidden`
  The handler will be called on failure.
  The `:unauthorized` function will be called when a failure is detected.
  This based on Guardian implementation of permissions matching
  """

  require Logger
  import Plug.Conn

  def init(opts) do
    opts = Enum.into(opts, %{})
    on_failure = Map.get(opts, :on_failure)
    key = Map.get(opts, :key, :default)
    handler = Map.get(opts, :handler)

    perm_sets = case Map.get(opts, :one_of) do
      nil ->
        single_set = Map.drop(opts, [:handler, :on_failure, :key, :one_of])
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
      case on_failure do
        {mod, f} ->
          _ = Logger.warn(":on_failure is deprecated. Use :handler")
          {mod, f}
        _ -> raise "Requires a handler module to be passed"
      end
    end

    %{
      handler: handler_tuple,
      key: key,
      perm_sets: perm_sets
    }
  end

  @doc "Bridge to api permissions matching"
  def call(conn, opts) do
    key = Map.get(opts, :key)

    case claims(conn, key) do
      {:ok, claims} ->
        if matches_permissions?(conn, claims, Map.get(opts, :perm_sets)) do
          conn
        else
          handle_error(conn, opts)
        end
      {:error, _} -> handle_error(conn, opts)
    end
  end

  defp matches_permissions?(_, _, []), do: true
  defp matches_permissions?(conn, claims, sets) do
    IO.inspect claims

    auth_token = get_req_header(conn, "authorization")
    # Connection to auth api
    url = "#{System.get_env("AUTH_HOST")}/api/permissions"
    headers = ["Authorization": "#{auth_token}", "Accept": "Application/json; Charset=utf-8"]
    options = [recv_timeout: 30_000]
    body = Poison.encode! %{claims: claims, sets: sets}
    response = HTTPoison.post!(url, body, headers, options)

    IO.inspect response
    true
  end

  defp handle_error(%Plug.Conn{params: params} = conn, opts) do
    conn = conn |> assign(:auth_failure, :forbidden) |> halt
    params = Map.merge(params, %{reason: :forbidden})

    {mod, meth} = Map.get(opts, :handler)

    apply(mod, meth, [conn, params])
  end

  @doc """
  Fetch the currently verified claims from the current request
  """
  @spec claims(Plug.Conn.t, atom) :: {:ok, map} |
  {:error, atom | String.t}
  def claims(conn, the_key \\ :default) do
    case conn.private[claims_key(the_key)] do
      {:ok, the_claims} -> {:ok, the_claims}
      {:error, reason} -> {:error, reason}
      _ -> {:error, :no_session}
    end
  end

  # Guardian standard key model

  defp claims_key(key \\ :default) do
    String.to_atom("#{base_key(key)}_claims")
  end

  defp base_key(the_key = "guardian_" <> _) do
    String.to_atom(the_key)
  end

  @doc false
  defp base_key(the_key) do
    String.to_atom("guardian_#{the_key}")
  end

end
