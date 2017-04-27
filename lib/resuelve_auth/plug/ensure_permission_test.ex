defmodule ResuelveAuth.Plug.EnsurePermissionsTest do
  @moduledoc """
  Ths module is to avoid matching permissions when developing
  """

  require Logger

  @spec init(map) :: map
  def init(_opts) do
  end

  @doc "Bridge to api permissions matching"
  @spec call(Plug.Conn, map) :: Plug.Conn
  def call(conn, _opts) do
    conn
  end

end
