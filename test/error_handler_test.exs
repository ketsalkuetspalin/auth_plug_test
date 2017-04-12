defmodule ResuelveAuth.Plug.ErrorHandlerTest do
  @moduledoc false
  use ExUnit.Case, async: true
  use Plug.Test

  alias ResuelveAuth.Plug.ErrorHandler

  setup do
    conn = conn(:get, "/foo")
    {:ok, %{conn: conn}}
  end

  test "unauthenticated/2 sends a 401 response when json", %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")

    {status, headers, body} =
      conn
      |> ErrorHandler.unauthenticated(%{})
      |> sent_resp

    assert status == 401
    assert content_type(headers) == "application/json"
    assert body ==  Poison.encode!(%{errors: ["Unauthenticated"]})
  end

  defp content_type(headers) do
    {:ok, type, subtype, _params} =
      headers
      |> header_value("content-type")
      |> Plug.Conn.Utils.content_type
    "#{type}/#{subtype}"
  end

  defp header_value(headers, key) do
    headers
    |> Enum.filter(fn({k, _}) -> k == key end)
    |> Enum.map(fn({_, v}) -> v end)
    |> List.first
  end
end
