defmodule Backchain do
  import KB

  @doc """
  A (very) simple backchaining algorithm that does keep track of solutions
  or unify variables with constants.
  """
  def backchain1(kb, query), do: bc1(kb, [query])

  def bc1(kb, stack) do
    if Stack.empty?(stack) do
      # Base case: all goals satisfied
      true
    else
      {goal, stack} = Stack.pop(stack)
      if kb_fact?(kb, goal) do
        # Current goal satisfied, test the rest
        bc1(kb, stack)
      else
        # Go through matching rules and test their antecedents
        results = List.foldl(
          matching_rules(kb, goal),
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

  @doc """
  A slightly smarter backchaining algorithm that unifies variables with constants,
  but still does not keep track of solutions.
  """
  def backchain2(kb, query), do: bc2(kb, [query])

  def bc2(kb, stack) do
    if Stack.empty?(stack) do
      # Base case: all goals satisfied
      true
    else
      {goal, stack} = Stack.pop(stack)
      if kb_fact?(kb, goal) do
        # Current goal satisfied, test the rest
        bc2(kb, stack)
      else
        # Go through matching rules and test their antecedents
        results = List.foldl(
          matching_rules(kb, goal),
          [],
          fn(rule, results) ->
            {_, matches} = unify(rule[:head][:subjects], goal[:subjects])
            # For each match, replace all instances of the variable with the constant
            antecedents = List.foldl(
              matches,
              rule[:body],
              fn({var, const}, antecedents) ->
                replace_vars_with_const(antecedents, var, const)
              end
            )
            stack = Stack.push_multiple(stack, antecedents)
            [bc2(kb, stack) | results]
          end
        )
        Enum.any?(results)
      end
    end
  end
end
