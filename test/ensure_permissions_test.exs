defmodule ResuelveAuth.Plug.EnsurePermissionTest do
  @moduledoc false
  use ExUnit.Case, async: true
  use Plug.Test

  import Mock
  import ResuelveAuth.TestHelper

  alias ResuelveAuth.Plug.EnsurePermissions

  defmodule TestPermissionHandler do
    @moduledoc """
    Tests for ResuelveAuth.Plug.EnsurePermissions plug
    """

    @doc "
    A function that handle when permissions are invalid
    Creates a mark to validate a connection pass through this
    "
    def unauthorized(conn, _) do
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

  test "init/1 uses handler and a single set of perms" do
    opts = EnsurePermissions.init([handler: TestPermissionHandler, admin: [:write]])

    assert opts ==  %{handler: {TestPermissionHandler,:unauthorized},
                      key: :default,
                      perm_sets: [%{admin: [:write]}]}
  end

  test "init/1 uses the one_of option and multiple perms" do
    opts = EnsurePermissions.init([handler: TestPermissionHandler,
                                   one_of: [%{default: [:read, :write]}, %{other: [:read]}]])

    assert opts ==  %{handler: {TestPermissionHandler,:unauthorized},
                      key: :default,
                      perm_sets: [%{default: [:read, :write]}, %{other: [:read]}]}
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
        [
          handler: TestPermissionHandler,
          one_of: %{"sets" => [%{"admin" => ["read"]}, %{"client" => ["read"]}]}
        ]
      )
      refute expected_conn.halted
      refute unauthorized?(expected_conn)
    end
  end

  test "call when not parameters are sent", %{conn: conn} do
    expected_conn = run_plug(
      conn,
      EnsurePermissions,
      [
        handler: TestPermissionHandler
      ]
    )
    refute expected_conn.halted
    refute unauthorized?(expected_conn)
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
        [
          handler: TestPermissionHandler,
          one_of: %{"sets" => [%{"admin" => ["read"]}, %{"client" => ["read"]}]}
        ]
      )
      assert  unauthorized? expected_conn
    end
  end

  
  def unauthorized?(conn) do
    conn.assigns[:resuelve_spec] == :forbidden
  end
end
