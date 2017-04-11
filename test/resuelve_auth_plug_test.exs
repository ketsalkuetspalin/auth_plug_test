defmodule ResuelveAuthTest do
  use ExUnit.Case
  use Plug.Test 
  doctest ResuelveAuth

  import Mock

  alias ResuelveAuth.Plug.EnsureAuth

  defmodule TestHandler do
    @moduledoc false

    def unauthenticated(conn, _) do
      conn
      |> Plug.Conn.assign(:auth_resuelve, :unauthenticated)
      |> Plug.Conn.send_resp(401, "Unauthenticated")
    end
  end

  setup do
    conn = conn(:get, "/foo")
    {:ok, %{conn: conn}}
  end

  test "init/1 with default options" do
    options = EnsureAuth.init %{}

    assert options == %{
      handler: {ResuelveAuth.Plug.ErrorHandler , :unauthenticated},
    }
  end

  test "init/1 sets the handler option to the module that's passed in" do
    %{handler: handler_opts} = EnsureAuth.init(handler: TestHandler)

    assert handler_opts == {TestHandler, :unauthenticated}
  end

  test "when is connected", %{conn: conn} do
    with_mocks([
      {
        HTTPoison,
        [],
        [
          get!: fn(_url, _headers, _options) -> %{status_code: 200, body: "{ \"id\": \"AUTHORIZED\"}"} end
        ]
      }
    ]) do
      ensured_conn = run_plug(
        conn,
        EnsureAuth,
        handler: TestHandler
      )
      assert !ensured_conn.halted
      assert !must_authenticate? ensured_conn
    end
  end

  test "it halts the connection", %{conn: conn} do
    with_mocks([
      {
        HTTPoison,
        [],
        [
          get!: fn(_url, _headers, _options) -> %{status_code: 401, body: "{ \"id\": \"UNAUTHORIZED\"}"} end
        ]
      }
    ]) do
      ensured_conn = run_plug(
        conn,
        EnsureAuth,
        handler: TestHandler
      )
      assert  must_authenticate? ensured_conn
    end
  end

  defp must_authenticate?(conn) do
    conn.assigns[:auth_resuelve] == :unauthenticated
  end

  defp run_plug(conn, plug_module, plug_opts) do
    opts = apply(plug_module, :init, [plug_opts])
    apply(plug_module, :call, [conn, opts])
  end

end
