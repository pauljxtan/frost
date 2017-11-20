defmodule TestData do
  # Predicates are the lowest-level objects
  # Facts and rules are objects made up of predicates
  # A knowledge base is a collections of facts and rules
  def kb1() do
    [
      {:fact, {:predicate, "man", ["sartre"]}},
      {:fact, {:predicate, "man", ["socrates"]}},
      {:fact, {:predicate, "woman", ["beauvoir"]}},
      {:fact, {:predicate, "woman", ["hypatia"]}},

      {:rule, {:predicate, "person", ["X"]}, [{:predicate, "man", ["X"]}]},
      {:rule, {:predicate, "person", ["X"]}, [{:predicate, "woman", ["X"]}]},
      {:rule, {:predicate, "mortal", ["X"]}, [{:predicate, "person", ["X"]}]},
    ]
  end 
end
