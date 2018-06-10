defmodule Lex.Http.IBrowse do
  def adapter(), do: HttpBuilder.Adapters.IBrowse

  def format_response({:ok, status, _, body}) do
    status = String.to_integer(to_string(status))
    { status, body }
  end
  
end
