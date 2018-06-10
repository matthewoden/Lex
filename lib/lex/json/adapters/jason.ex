if Code.ensure_loaded?(Jason) do
  defmodule Lex.Json.Jason do
    defdelegate encode!(data), to: Jason
    defdelegate decode!(data), to: Jason
  end
end