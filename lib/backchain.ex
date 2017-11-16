defmodule Backchain do
  import KB
  import Utils

  @doc """
  A simple backchaining algorithm.
  """
  def backchain(kb, query) do
    {:predicate, word, subjects} = query
    # If the query includes variables, we need to try subbing in possible subjects
    if includes_variable?(subjects) do
      List.foldl(
        possible_subjects(kb, word),
        [], # solutions
        fn(test_subjects, solutions) ->
          if backchain(kb, {:predicate, word, test_subjects}) do
            # TODO: keep just the subjects that were subtituted
            #       (not constants already in the query)
            solutions ++ [test_subjects]
          else
            solutions
          end
        end
      )
    else
      bc(kb, [query])
    end
  end

  def bc(kb, stack) do
    if Stack.empty?(stack) do
      # Base case: all goals satisfied
      true
    else
      {goal, stack} = Stack.pop(stack)
      if kb_fact?(kb, {:fact, goal}) do
        # Current goal satisfied, test the rest
        bc(kb, stack)
      else
        # If no facts match, go through matching rules and test their antecedents
        results = List.foldl(
          matching_rules(kb, goal),
          [],
          fn({:rule, {:predicate, _, rule_subjects}, rule_body}, results) ->
            {:predicate, _, goal_subjects} = goal
            {_, matches} = unify(rule_subjects, goal_subjects)
            # For each match, replace all instances of the variable with the constant
            antecedents = List.foldl(
              matches,
              rule_body,
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

  @doc """
  Checks if the subject is a constant (e.g. "socrates").
  """
  def constant?(subject), do: starts_with_lowercase?(subject)

  @doc """
  Checks if the subject is a variable (e.g. "Person").
  """
  def variable?(subject), do: starts_with_uppercase?(subject)

  @doc """
  Checks if the given subjects includes a variable.
  """
  def includes_variable?(subjects), do: Enum.any?(subjects, &variable?/1)
end
