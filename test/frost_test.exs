defmodule FrostTest do
  use ExUnit.Case

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
      KB.fact(KB.predicate("man", ["sartre"])),
      KB.fact(KB.predicate("man", ["socrates"])),
      KB.fact(KB.predicate("woman", ["beauvoir"])),
      KB.fact(KB.predicate("woman", ["hypatia"]))
    ]
  end

  test "get matching rules from KB with unification" do
    assert KB.matching_rules(kb1(), KB.predicate("mortal", ["socrates"])) == [
      KB.rule(KB.predicate("mortal", ["X"]), [KB.predicate("person", ["X"])]),
    ]
    assert KB.matching_rules(kb1(), KB.predicate("person", ["beauvoir"])) == [
      KB.rule(KB.predicate("person", ["X"]), [KB.predicate("man", ["X"])]),
      KB.rule(KB.predicate("person", ["X"]), [KB.predicate("woman", ["X"])])
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

  test "get possible subjects from KB facts based on word" do
    assert KB.possible_subjects(kb1(), "man") == [["sartre"], ["socrates"]]
    assert KB.possible_subjects(kb1(), "woman") == [["beauvoir"], ["hypatia"]]
  end

  test "check if word matches fact in KB" do
    assert KB.matches_fact?(kb1(), "man")
    assert KB.matches_fact?(kb1(), "woman")
    refute KB.matches_fact?(kb1(), "mortal")
  end

  test "check if word matches rule in KB" do
    refute KB.matches_rule?(kb1(), "man")
    refute KB.matches_rule?(kb1(), "woman")
    assert KB.matches_rule?(kb1(), "mortal")
  end


  test "get all facts in KB matching word" do
    assert KB.lookup_fact(kb1(), "man") == [
      {:fact, {:predicate, "man", ["sartre"]}},
      {:fact, {:predicate, "man", ["socrates"]}}
    ]
    assert KB.lookup_fact(kb1(), "woman") == [
      {:fact, {:predicate, "woman", ["beauvoir"]}},
      {:fact, {:predicate, "woman", ["hypatia"]}}
    ]
  end

  test "get all rules in KB matching word" do
    assert KB.lookup_rule(kb1(), "mortal") == [
      {:rule, {:predicate, "mortal", ["X"]}, [{:predicate, "person", ["X"]}]},
    ]

    assert KB.antecedents_of_rules(KB.lookup_rule(kb1(), "mortal")) ==
      [{:predicate, "person", ["X"]}]
    assert KB.antecedents_of_rules(KB.lookup_rule(kb1(), "person")) ==
      [{:predicate, "man", ["X"]}, {:predicate, "woman", ["X"]}]
  end


  test "check if subject is constant" do
    assert Backchain.constant?("socrates")
    refute Backchain.constant?("Man")
  end

  test "check if subject is variable" do
    refute Backchain.variable?("socrates")
    assert Backchain.variable?("Man")
  end

  test "check if list of subjects includes variable(s)" do
    assert Backchain.includes_variable?(["socrates", "Person"])
    refute Backchain.includes_variable?(["socrates", "beauvoir"])
  end

  test "perform backchaining on query without variables" do
    assert Backchain.backchain(kb1(), KB.predicate("mortal", ["socrates"]))
    assert Backchain.backchain(kb1(), KB.predicate("mortal", ["beauvoir"]))
    refute Backchain.backchain(kb1(), KB.predicate("woman", ["socrates"]))
    refute Backchain.backchain(kb1(), KB.predicate("man", ["beauvoir"]))
    assert Backchain.backchain(kb1(), KB.predicate("person", ["sartre"]))

    assert Backchain.backchain(kb1(), KB.predicate("cool", ["socrates"])) == :invalid_query
  end

  test "perform backchaining on query with variables" do
    assert Backchain.backchain(kb1(), KB.predicate("cool", ["X"])) == :invalid_query

    assert Backchain.backchain(kb1(), KB.predicate("man", ["X"])) ==
      [["sartre"], ["socrates"]]
    assert Backchain.backchain(kb1(), KB.predicate("woman", ["X"])) ==
      [["beauvoir"], ["hypatia"]]

    # person(X) -> man(X) or female(X)
    assert Backchain.backchain(kb1(), KB.predicate("person", ["X"]))
      [["sartre"], ["socrates"], ["beauvoir"], ["hypatia"]]

    # mortal(X) -> person(X) -> man(X) or female(X)
    assert Backchain.backchain(kb1(), KB.predicate("mortal", ["X"]))
      [["sartre"], ["socrates"], ["beauvoir"], ["hypatia"]]
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

  #==== TEST DATA

  def kb1() do
    [
      {:fact, {:predicate, "man", ["sartre"]}},
      {:fact, {:predicate, "man", ["socrates"]}},
      {:fact, {:predicate, "woman", ["beauvoir"]}},
      {:fact, {:predicate, "woman", ["hypatia"]}},

      {:rule, 
        {:predicate, "person", ["X"]}, 
        [{:predicate, "man", ["X"]}]
      },
      {:rule, 
        {:predicate, "person", ["X"]}, 
        [{:predicate, "woman", ["X"]}]
      },

      {:rule, 
        {:predicate, "mortal", ["X"]}, 
        [{:predicate, "person", ["X"]}]
      },
    ]
  end
end
