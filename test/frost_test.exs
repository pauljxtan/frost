defmodule FrostTest do
  use ExUnit.Case
  doctest Frost

  test "get facts from KB" do
    assert KB.facts(kb1()) == [
      KB.rule(
        KB.predicate("man", ["socrates"])
      )
    ]
  end

  test "stack operations" do
    stack = Stack.new()
    assert Stack.empty?(stack)
    stack = stack |> Stack.push(1)
    assert Stack.peek(stack) == 1
    stack = stack |> Stack.push(2) |> Stack.push(3)
    assert Stack.peek(stack) == 3
    {top, stack} = Stack.pop(stack)
    assert Stack.peek(stack) == 2
    assert top == 3
  end

  def kb1() do
    [
      KB.rule(
        KB.predicate("man", ["socrates"])
      ),
      KB.rule(
        KB.predicate("mortal", ["socrates"]),
        [
          KB.predicate("man", ["socrates"])
        ]
      )
    ]
  end
end
