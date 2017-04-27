# ResuelveAuth

## ¿Que hace?
Es un plug diseñado para validar el token de autenticacion en el servidor donde se genero dicho token

## ¿Como lo hace?
Toma el token de la cabecera
Lo envia al servidor de autenticacion
Si es valido, permite a la conexion continuar

## Uso

# Configuración
Agregar lo siguiente al listado de dependencias del proyecto

```elixir
def deps do
  [
    {:resuelve_auth, git: "git@github.com:resuelve/resuelve_auth_plug.git"}
  ]
end
```

Para que mix pueda descargar la dependencia, debe tener correctamente configurado su acceso por llave ssh.

# Entorno 

Se necesita una variable de entorno 

```bash
export AUTH_HOST=http://localhost:4000
```
Debe contener la direccion del servidor de autenticacion

# EnsureAuth Plug

Este plug nos sirve para dar acceso a conexiones que tengan un token valido en el header de Autenticación

## Configuracion

Se debe configurar el nombre del modulo dependiendo del entorno.
Para esto se usara una variable  de la aplicación

### In config/dev.exs
```elixir
config :my_app, :auth_plug, ResuelveAuth.Plug.EnsureAuth
```

### In config/test.exs
```elixir
config :my_app, :auth_plug, ResuelveAuth.Plug.EnsureAuthTest
```

### In config/prod.exs
```elixir
config :my_app, :auth_plug, ResuelveAuth.Plug.EnsureAuth
```

## Uso

Solo es necesario agregar la referencia del plug.

```elixir
@auth_plug Application.get_env(:my_app, :auth_plug)
plug @auth_plug, handler: MyHandlerController
```

El controlador delegado debe implementar el metodo:

**unauthenticated(String.t, map)**

# EnsurePermissions Plug

Este plug sirve para saber si un usuario autenticado tiene permisos para cierto recurso

## Configuración

Se debe configurar el nombre del modulo dependiendo del entorno.
Para esto se usara una variable  de la aplicación

### In config/dev.exs
```elixir
config :my_app, :perm_plug, ResuelveAuth.Plug.EnsurePermissions
```

### In config/test.exs
```elixir
config :my_app, :perm_plug, ResuelveAuth.Plug.EnsurePermissionsTest
```

### In config/prod.exs
```elixir
config :my_app, :perm_plug, ResuelveAuth.Plug.EnsurePermissions
```

## Uso

Es necesario agregar la referencia del plug.
Es recomendable agregar un modulo como handler

```elixir
  @perm_plug Application.get_env(:my_app, :perm_plug)

  plug @perm_plug,
    [handler: MyModuleHandler, one_of: [%{admin: [:write]}, %{client: [:write]}]]
    when action in [:update, :delete]

```

El modulo delegado debe implementar el metodo:

**unathorized(String.t, map)**

## Desarrollo

_Agregar hook pre-commit para pruebas unitarias y credo_
```shell
cp pre-commit.dist .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```
_Generar coverage de pruebas unitarias en cover/excoveralls.html_
```shell
MIX_ENV=test mix coveralls.html
```
