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
    assert KB.facts(kb()) == [
      KB.fact(KB.predicate("man", ["sartre"])),
      KB.fact(KB.predicate("man", ["socrates"])),
      KB.fact(KB.predicate("woman", ["beauvoir"])),
      KB.fact(KB.predicate("woman", ["hypatia"]))
    ]
  end

  test "get matching rules from KB with unification" do
    goal = KB.predicate("mortal", ["socrates"])
    assert KB.matching_rules(kb(), goal) == [
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

  test "KB misc" do
    assert KB.possible_subjects(kb(), "man") == [["sartre"], ["socrates"]]
    assert KB.possible_subjects(kb(), "woman") == [["beauvoir"], ["hypatia"]]

    assert KB.matches_fact?(kb(), "man")
    assert KB.matches_fact?(kb(), "woman")
    refute KB.matches_fact?(kb(), "mortal")
    refute KB.matches_rule?(kb(), "man")
    refute KB.matches_rule?(kb(), "woman")
    assert KB.matches_rule?(kb(), "mortal")

    assert KB.lookup_fact(kb(), "man") == [
      {:fact, {:predicate, "man", ["sartre"]}},
      {:fact, {:predicate, "man", ["socrates"]}}
    ]
    assert KB.lookup_fact(kb(), "woman") == [
      {:fact, {:predicate, "woman", ["beauvoir"]}},
      {:fact, {:predicate, "woman", ["hypatia"]}}
    ]
    assert KB.lookup_rule(kb(), "mortal") == [
      {:rule, {:predicate, "mortal", ["X"]}, [{:predicate, "man", ["X"]}]},
      {:rule, {:predicate, "mortal", ["X"]}, [{:predicate, "woman", ["X"]}]}
    ]

    assert KB.antecedents_of_rules(KB.lookup_rule(kb(), "mortal")) ==
      [{:predicate, "man", ["X"]}, {:predicate, "woman", ["X"]}]
  end


  test "backchaining misc" do
    assert Backchain.constant?("socrates")
    refute Backchain.constant?("Man")
    refute Backchain.variable?("socrates")
    assert Backchain.variable?("Man")

    assert Backchain.includes_variable?(["socrates", "Person"])
    refute Backchain.includes_variable?(["socrates", "beauvoir"])
  end

  test "backchaining (w/ unification, no solutions)" do
    assert Backchain.backchain(kb(), KB.predicate("mortal", ["socrates"]))
    assert Backchain.backchain(kb(), KB.predicate("mortal", ["beauvoir"]))
    refute Backchain.backchain(kb(), KB.predicate("woman", ["socrates"]))
    refute Backchain.backchain(kb(), KB.predicate("man", ["beauvoir"]))
  end

  test "backchaining (w/ unification, w/ solutions)" do
    assert Backchain.backchain(kb(), KB.predicate("man", ["X"])) ==
      [["sartre"], ["socrates"]]
    assert Backchain.backchain(kb(), KB.predicate("woman", ["X"])) ==
      [["beauvoir"], ["hypatia"]]
    #assert Backchain.backchain(kb(), KB.predicate("mortal", ["X"])) ==
    #  [["sartre"], ["socrates"], ["beauvoir"], ["hypatia"]]
    assert Backchain.backchain(kb(), KB.predicate("cool", ["X"])) == :invalid_query
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

  def kb() do
    [
      {:fact, {:predicate, "man", ["sartre"]}},
      {:fact, {:predicate, "man", ["socrates"]}},
      {:fact, {:predicate, "woman", ["beauvoir"]}},
      {:fact, {:predicate, "woman", ["hypatia"]}},

      {:rule, 
        {:predicate, "mortal", ["X"]}, 
        [{:predicate, "man", ["X"]}]
      },
      {:rule, 
        {:predicate, "mortal", ["X"]}, 
        [{:predicate, "woman", ["X"]}]
      }
    ]
  end
end
