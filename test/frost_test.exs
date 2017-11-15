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

  test "get matching rules from KB with unification" do
    goal = KB.predicate("mortal", ["socrates"])
    assert KB.matching_rules(kb2(), goal) == [
      KB.rule(
        KB.predicate("mortal", ["X"]),
        [
          KB.predicate("man", ["X"])
        ]
      ),
      KB.rule(
        KB.predicate("mortal", ["X"]),
        [
          KB.predicate("woman", ["X"])
        ]
      )
    ]
  end

  test "replace variables with constants" do
    predicates = [
      KB.predicate("cool", ["X", "abc"]),
      KB.predicate("awesome", ["def", "X"])
    ]
    assert KB.replace_vars_with_const(predicates, "X", "thing") == [
      KB.predicate("cool", ["thing", "abc"]),
      KB.predicate("awesome", ["def", "thing"])
    ]

  end

  test "backchaining (no unification, no solutions)" do
    assert Backchain.backchain1(kb1(), KB.predicate("man", ["socrates"]))
    refute Backchain.backchain1(kb1(), KB.predicate("woman", ["socrates"]))
    refute Backchain.backchain1(kb1(), KB.predicate("man", ["socrate"]))
    assert Backchain.backchain1(kb1(), KB.predicate("mortal", ["socrates"]))
    refute Backchain.backchain1(kb1(), KB.predicate("mortal", ["socrate"]))
  end

  test "backchaining (w/ unification, no solutions)" do
    assert Backchain.backchain2(kb2(), KB.predicate("mortal", ["socrates"]))
    assert Backchain.backchain2(kb2(), KB.predicate("mortal", ["beauvoir"]))
    #refute Backchain.backchain2(kb2(), KB.predicate("man", ["socrate"]))
    #assert Backchain.backchain2(kb2(), KB.predicate("mortal", ["socrates"]))
    #refute Backchain.backchain2(kb2(), KB.predicate("mortal", ["socrate"]))
  end

  test "backchaining (w/ unification, w/ solutions)" do
    :todo
  end

  test "unify lists" do
    assert KB.can_unify?(["a", "Y", "c"], ["X", "b", "Z"])
    refute KB.can_unify?(["W", "Y", "c"], ["X", "b", "Z"])

    assert KB.unify(["a", "b", "c"], ["a", "b", "c"]) ==
      {["a", "b", "c"], []}
    assert KB.unify(["a", "b", "c"], ["a", "b", "d"]) ==
      :cannot_unify
    assert KB.unify(["a", "b", "c"], ["a", "b", "X"]) ==
      {["a", "b", "c"], [{"X", "c"}]}
    assert KB.unify(["a", "b", "Y"], ["a", "b", "c"]) ==
      {["a", "b", "c"], [{"Y", "c"}]}
    assert KB.unify(["a", "b", "X"], ["a", "b", "X"]) ==
      {["a", "b", "X"], []}
    assert KB.unify(["a", "b", "X"], ["a", "b", "Y"]) ==
      :cannot_unify
    assert KB.unify(["Z", "b", "X"], ["a", "Y", "c"]) ==
      {["a", "b", "c"], [{"Z", "a"}, {"Y", "b"}, {"X", "c"}]}
  end

  test "string utils" do
    assert Utils.valid_var_or_const?("socrates1")
    refute Utils.valid_var_or_const?("1socrates1")
    assert Utils.starts_with_uppercase?("Socrates")
    refute Utils.starts_with_uppercase?("socrates")
    assert Utils.starts_with_lowercase?("socrates")
    refute Utils.starts_with_lowercase?("Socrates")
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

  def kb2() do
    [
      KB.rule(
        KB.predicate("man", ["socrates"])
      ),
      KB.rule(
        KB.predicate("woman", ["beauvoir"])
      ),
      KB.rule(
        KB.predicate("mortal", ["X"]),
        [
          KB.predicate("man", ["X"])
        ]
      ),
      KB.rule(
        KB.predicate("mortal", ["X"]),
        [
          KB.predicate("woman", ["X"])
        ]
      )
    ]
  end
end
