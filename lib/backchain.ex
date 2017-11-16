defmodule Backchain do
  import KB

  @doc """
  A simple backchaining algorithm.
  """
  def backchain(kb, query), do: bc(kb, [query])

  def bc(kb, stack) do
    if Stack.empty?(stack) do
      # Base case: all goals satisfied
      true
    else
      {goal, stack} = Stack.pop(stack)
      if kb_fact?(kb, goal) do
        # Current goal satisfied, test the rest
        bc(kb, stack)
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
            [bc(kb, stack) | results]
          end
        )
        Enum.any?(results)
      end
    end
  end
end
