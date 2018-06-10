defmodule Lex.Http.HTTPoison do

  def adapter(), do: HttpBuilder.Adapters.HTTPoison

  def format_response({ :ok, %{status_code: status, body: body}}) do
    { status, body }
  end

end