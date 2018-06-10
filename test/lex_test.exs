defmodule LexTest do
  use ExUnit.Case
  doctest Lex

  test "greets the world" do
    assert Lex.hello() == :world
  end
end
