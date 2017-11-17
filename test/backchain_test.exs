defmodule BackchainTests do
  use ExUnit.Case

  import TestData

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
end
