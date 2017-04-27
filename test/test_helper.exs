defmodule ResuelveAuth.TestHelper do
@moduledoc """
Helper module for test operations
"""

  @doc """
  Helper for running a plug.
  Calls the plug module's `init/1` function with
  no arguments and passes the results to `call/2`
  as the second argument.
  """
  def run_plug(conn, plug_module) do
    opts = apply(plug_module, :init, [])
    apply(plug_module, :call, [conn, opts])
  end

  @doc """
  Helper for running a plug.
  Calls the plug module's `init/1` function with
  the value of `plug_opts` and passes the results to
  `call/2` as the second argument.
  """
  def run_plug(conn, plug_module, plug_opts) do
    opts = apply(plug_module, :init, [plug_opts])
    apply(plug_module, :call, [conn, opts])
  end

end

ExUnit.start()
