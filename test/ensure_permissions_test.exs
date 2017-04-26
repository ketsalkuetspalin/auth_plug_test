defmodule Resuelve.Plug.EnsurePermissionTest do
  @moduledoc false
  use ExUnit.Case, async: true
  use Plug.Test
  
  import Mock
  import ResuelveAuth.TestHelper

  alias ResuelveAuth.Plug.EnsurePermissions

  defmodule TestPermissionHandler do
    @moduledoc false

    def unauthorized(conn, _) do
      IO.puts "Unauth"
      conn
      |> Plug.Conn.assign(:resuelve_spec, :forbidden)
      |> Plug.Conn.send_resp(401, "Unauthorized")
    end
  end

  setup do
    conn = conn(:post, "/test")
    {:ok, %{conn: conn}}
  end

  test "init/1 with default options" do
    options = EnsurePermissions.init %{}

    assert options == %{
      handler: {ResuelveAuth.Plug.ErrorHandler, :unauthorized}, key: :default, perm_sets: []
    }
  end

  test "init/1 sets the handler option to the module that's passed in" do
    %{handler: handler_opts} = EnsurePermissions.init(handler: TestPermissionHandler)

    assert handler_opts == {TestPermissionHandler, :unauthorized}
  end

  test "call when is authorized", %{conn: conn} do
    with_mocks([
      {
        HTTPoison,
        [],
        [
          post!: fn(_url, _body, _headers, _options) -> %{status_code: 200, body: "{ \"id\": \"AUTHORIZED\"}"} end
        ]
      }
    ]) do
      expected_conn = run_plug(
        conn,
        EnsurePermissions,
        handler: TestPermissionHandler
      )
      refute expected_conn.halted
      refute unauthorized?(expected_conn)
    end
  end

  test "call when is not authorized", %{conn: conn} do
    with_mocks([
      {
        HTTPoison,
        [],
        [
          post!: fn(_url, _body, _headers, _options) -> %{status_code: 401, body: "{ \"id\": \"UNAUTHORIZED\"}"} end
        ]
      }
    ]) do
      expected_conn = run_plug(
        conn,
        EnsurePermissions,
        handler: TestPermissionHandler
      )
      assert  unauthorized? expected_conn
    end
  end

  
  def unauthorized?(conn) do
    conn.assigns[:resuelve_spec] == :forbidden
  end
end
