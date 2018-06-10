defmodule Lex.Json do
  alias Lex.Config

  def encode!(data) do
    Config.get(:json_parser).encode!(data)
  end

  def decode!(data) do
    Config.get(:json_parser).decode!(data)
  end

end