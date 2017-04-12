defmodule ResuelveAuth.Plug.EnsureAuthTest do
  @moduledoc """
  Validation Plug for test enviroments
  """

  @spec init(map) :: map
  def init(_opts) do
  end

  @spec call(Plug.Conn, map) :: Plug.conn
  def call(conn, _opts) do
    conn
  end

end
