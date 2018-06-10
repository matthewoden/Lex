defmodule Lex.Http.HTTPotion do
  def adapter(), do: HttpBuilder.Adapters.HTTPotion

  def format_response({:ok, %{ status_code: status, body: body } }) do
    { status, body }
  end
  
end