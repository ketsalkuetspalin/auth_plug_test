defmodule ResuelveAuth.Plug.EnsurePermissionsTest do
  @moduledoc """
  This module is a mock of EnsurePermissions Plug
  You should use this when testing instead of the real one
  """

  require Logger
  @doc "Initialize plug with options"
  @spec init(map) :: map
  def init(_opts) do
  end

  @doc " "
  @spec call(Plug.Conn, map) :: Plug.Conn
  def call(conn, _opts) do
    conn
  end

end
