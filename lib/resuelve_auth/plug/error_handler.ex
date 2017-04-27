defmodule ResuelveAuth.Plug.ErrorHandler do
  @moduledoc """
  a default error handler that can be used for failed authentication
  """

  @callback unauthenticated(Plug.Conn.t, map) :: Plug.Conn.t

  import Plug.Conn

  @doc """
  Default implementation of handler function for EnsureAuth Plug
  """
  @spec unauthenticated(Plug.Conn.t, map) :: Plug.Conn.t
  def unauthenticated(conn, _params) do
    respond(conn, response_type(conn), 401, "Unauthenticated")
  end

  @doc """
  Default implementation of handler function for EnsurePermissions Plug
  """
  @spec unauthorized(Plug.Conn.t, map) :: Plug.Conn.t
  def unauthorized(conn, _params) do
    respond(conn, response_type(conn), 401, "Unauthorized")
  end

  defp respond(conn, :json, status, msg) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Poison.encode!(%{errors: [msg]}))
  end

  defp response_type(conn) do
    accept = accept_header(conn)
    if Regex.match?(~r/json/, accept) do
      :json
    else
      :html
    end
  end

  defp accept_header(conn)  do
    value =
      conn
      |> get_req_header("accept")
      |> List.first

    value || ""
  end
end
