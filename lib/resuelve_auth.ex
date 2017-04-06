defmodule ResuelveAuth do
  @moduledoc """
  Un modulo para verifcar la authentication con el proyecto:
  Resuelve Clientes API
  """

  @doc """
  Refresh the token. The token will be renewed and receive a new:
  * `jti` - JWT id
  * `iat` - Issued at
  * `exp` - Expiry time.
  * `nbf` - Not valid before time
  The current token will be revoked when the new token is successfully created.
  Note: A valid token must be used in order to be refreshed.
  """
  @spec refresh!(String.t) :: {:ok, String.t, map} | {:error, any}
  def refresh!(jwt), do: refresh!(jwt, %{}, %{})

  @doc """
  As refresh!/1 but allows the claims to be updated.
  Specifically useful is the ability to set the ttl of the token.
      Guardian.refresh(existing_jwt, existing_claims, %{ttl: { 5, :minutes}})
  Once the new token is created, the old one will be revoked.
  """
  @spec refresh!(String.t, map, map) :: {:ok, String.t, map} |
                                            {:error, any}
  def refresh!(_jwt, _claims, _params \\ %{}) do
  end

end
