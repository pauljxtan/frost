defmodule KB do
  def init(), do: []

  def kb_fact?(kb, fact), do: Enum.member?(facts(kb), fact)

  def facts(kb), do: Enum.filter(kb, fn rule -> fact?(rule) end)

  def matching_rules(kb, goal), do: Enum.filter(kb, fn rule -> rule[:head] == goal end)

  @doc """
  Represents a rule with optional antecedents.
  E.g. mortal(X) :- man(X).
    -> consequent: mortal(X)
    -> antecedent: man(X)
  """
  def rule(head), do: %{head: head, body: []}
  def rule(head, body), do: %{head: head, body: body}

  @doc """
  A rule with no body (antecedents) is a fact.
  """
  def fact?(rule), do: rule[:body] == []

  @doc """
  Represents a predicate, with one or more subjects.
  E.g. cityOf(toronto, canada)
    -> word: city
    -> subjects: toronto, canada
  """
  def predicate(word, subjects), do: %{word: word, subjects: subjects}
end
