
defmodule Lex.Json.Adapter do

  @type json :: map() | list()

  @callback decode!(String.t) :: json
  @callback encode!(json) :: String.t

end