defmodule FrostTest do
  use ExUnit.Case
  doctest Frost

  test "greets the world" do
    assert Frost.hello() == :world
  end
end
