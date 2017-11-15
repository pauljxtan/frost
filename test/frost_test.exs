defmodule FrostTest do
  use ExUnit.Case
  doctest Frost

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

  test "get facts from KB" do
    assert KB.facts(kb1()) == [
      KB.rule(
        KB.predicate("man", ["socrates"])
      )
    ]
  end

  test "get matching rules from KB" do
    goal = KB.predicate("mortal", ["socrates"])
    assert KB.matching_rules(kb1(), goal) == [
      KB.rule(
        KB.predicate("mortal", ["socrates"]),
        [
          KB.predicate("man", ["socrates"])
        ]
      ),
      KB.rule(
        KB.predicate("mortal", ["socrates"]),
        [
          KB.predicate("woman", ["socrates"])
        ]
      )
    ]
  end

  test "backchaining" do
    assert Backchain.backchain1(kb1(), KB.predicate("man", ["socrates"]))
    assert not Backchain.backchain1(kb1(), KB.predicate("man", ["socrate"]))
    assert Backchain.backchain1(kb1(), KB.predicate("mortal", ["socrates"]))
    assert not Backchain.backchain1(kb1(), KB.predicate("mortal", ["socrate"]))
  end

  test "string utils" do
    assert Utils.valid_var_or_const?("socrates1")
    assert not Utils.valid_var_or_const?("1socrates1")
    assert Utils.starts_with_uppercase?("Socrates")
    assert not Utils.starts_with_uppercase?("socrates")
    assert Utils.starts_with_lowercase?("socrates")
    assert not Utils.starts_with_lowercase?("Socrates")
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
      ),
      KB.rule(
        KB.predicate("mortal", ["socrates"]),
        [
          KB.predicate("woman", ["socrates"])
        ]
      )
    ]
  end
end
