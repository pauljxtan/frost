defmodule Backchain do
  @doc """
  A (very) simple backchaining algorithm that does keep track of solutions
  or unify variables with constants.
  """
  def backchain1(kb, query) do
    bc1(kb, [query])
  end

  def bc1(kb, stack) do
    if Stack.empty?(stack) do
      # Base case: all goals satisfied
      true
    else
      {goal, stack} = Stack.pop(stack)
      if KB.kb_fact?(kb, goal) do
        # Current goal satisfied, test the rest
        bc1(kb, stack)
      else
        # Go through matching rules and test their antecedents
        results = List.foldl(
          KB.matching_rules(kb, goal),
          [],
          fn(rule, results) ->
            stack = Stack.push_multiple(stack, rule[:body])
            [bc1(kb, stack) | results]
          end
        )
        Enum.any?(results)
      end
    end
  end

  def test_antecedents(kb, stack, rule) do
    antecedents = rule[:body]
    stack = List.foldl(
      antecedents,
      stack,
      fn(antecedent, stack) -> Stack.push(stack, antecedent) end
    )
    {stack, bc1(kb, stack)}
  end

  @doc """
  Attempts to unify two lists.
  If successful, returns the unified list along with the variable resolutions.
  Otherwise, returns :not_unifiable.
  """
  def unify(list1, list2) do
    :todo
  end
end
