defmodule Backchain do
  import KB
  import Utils

  @doc """
  Applies backward chaining (reasoning) on a query (phrased as a predicate).

  If the query subject(s) contain only constants, returns true or false.
  E.g.,
    Query: man(socrates) -> true
    Query: mortal(hypatia) -> true

  If the query subject(s) contain variables, returns all solutions,
  i.e. constants for which the query holds.
  E.g.,
    Query: man(X) -> ["sartre", "socrates"]
    Query: mortal(X) -> ["sartre", "socrates", "beauvoir", "hypatia"]
    Query: city_of(X, canada) -> [["toronto", "canada"], ["montreal", "canada"], ...]
  """
  def backchain(kb, query) do
    {:predicate, word, subjects} = query
    # If the query includes variables, we need to try subbing in possible subjects
    if includes_variable?(subjects) do
      if matches_fact?(kb, word) do
        List.foldl(
          possible_subjects(kb, word),
          [],
          fn(test_subjects, solutions) ->
            if backchain(kb, {:predicate, word, test_subjects}) do
              solutions ++ [test_subjects]
            else
              solutions
            end
          end
        )
      else 
        if matches_rule?(kb, word) do
          rules = lookup_rule(kb, word)
          List.foldl(
            rules,
            [],
            fn({:rule, _, antecedents}, solutions) ->
              List.foldl(
                antecedents,
                solutions,
                fn(antecedent, solutions) ->
                  solutions ++ backchain(kb, antecedent)
                end
              )
            end
          )
        else
          # Query does not match a fact or rule in the KB
          :invalid_query
        end
      end
    else
      # Query only contains constants (no variables), so no substitutions required
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
