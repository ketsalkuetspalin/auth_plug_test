# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :resuelve_auth, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:resuelve_auth, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

config :resuelve_auth, jwt_key: "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL3Jlc3VlbHZlLm14Iiwic3ViIjoibWFpbHRvOmFkbWluQHJlc3VlbHZlLm14IiwibmJmIjoxNDkxOTQ0OTU5LCJleHAiOjE1MjM0ODA5NTksImlhdCI6MTQ5MTk0NDk1OSwianRpIjoiaWQxMjM0NTYiLCJ0eXAiOiJodHRwczovL3Jlc3VlbHZlLm14L3JlZ2lzdGVyIn0.k4T3wpHAhUCeWBhgwLafLhVajJOULtM1BDJku8VPZ391obXpa78tAEHzrYcXU36A3SPRWLYiv39t85orMWbK8wKUNDIrHnSKRkwX4Jd4HAj52lg_9j0nyc1uz4YpXw0BcykRGYi5BYLYsSVPmXgF0Fbq_vaK92qyxv9p71EQEgIhJYYRKsqLhwa615JHXMcKbrgIS2jz-Nx7RBzZqI98o02P-MN6jBBatNokLl_T_xgX0utPfxk3g8yFwJfm-n7-mR4t04WoNlAA1HcdxbgorZL9ZkxGE1dApYnU2cJoCWD6kq4mVF1m0cpcVZaBhi_UoIjA6JXA0BLf3xXHDzvzCA"
