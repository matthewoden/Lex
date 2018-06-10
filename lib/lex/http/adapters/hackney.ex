defmodule Lex.Http.Hackney do

  @moduledoc """
  HTTP Adapter for hackney. Used for HTTPBuilder and parsing the response
  """
  @behaviour Lex.Http.Adapter

  def adapter(), do: HttpBuilder.Adapters.Hackney

  def format_response({:ok, status, _headers, ref}) do
    {:ok, body} = :hackney.body(ref)
    {status, body}
  end
  
end