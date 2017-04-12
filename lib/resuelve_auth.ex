defmodule ResuelveAuth do
  @moduledoc """
  Un modulo para verifcar la authentication con el proyecto:
  Resuelve Clientes API
  """

  @jwt_key Application.get_env(:resuelve_auth, :jwt_key)

  @spec get_test_token() :: String.t
  def get_test_token do
   @jwt_key 
  end

end
