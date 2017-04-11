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
    {:resuelve_auth, git: "git@bitbucket.org:resuelve/resuelveauth.git"}
  ]
  
by adding `resuelve_auth` to your list of dependencies in `mix.exs`:
end
```

Para que mix pueda descargar la dependencia, debe tener correctamente configurado su acceso por llave ssh.

# Entorno 

Se necesita una variable de entorno 

```bash
export AUTH_HOST=http://localhost:4000
```

Debe contener la direccion del servidor de autenticacion

# Controlador

Solo es necesario agregar la referencia del plug.

```elixir
plug ResuelveAuth.Plug.EnsureAuth, handler: delegadoController
```

El controlador delegado debe implementar el metodo:

**unauthenticated(String.t, map)**

## Desarrollo

# Agregar hook pre-commit para pruebas unitarias y credo
```shell
cp pre-commit.dist .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```
_Generar coverage de pruebas unitarias en cover/excoveralls.html_
```shell
MIX_ENV=test mix coveralls.html
```
