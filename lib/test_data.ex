defmodule TestData do
  def kb1() do
    [
      {:fact, {:predicate, "man", ["sartre"]}},
      {:fact, {:predicate, "man", ["socrates"]}},
      {:fact, {:predicate, "woman", ["beauvoir"]}},
      {:fact, {:predicate, "woman", ["hypatia"]}},

      {:rule, {:predicate, "person", ["X"]},
        [{:predicate, "man", ["X"]}]
      },
      {:rule, {:predicate, "person", ["X"]},
        [{:predicate, "woman", ["X"]}]
      },

      {:rule, {:predicate, "mortal", ["X"]},
        [{:predicate, "person", ["X"]}]
      },
    ]
  end 
end
