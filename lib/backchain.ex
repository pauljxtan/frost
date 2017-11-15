defmodule Backchain do
  @doc """
  A (very) simple backchaining algorithm that does keep track of solutions
  or unify variables with constants.
  """
  import KB
  import Utils

  def backchain1(kb, query) do
    bc1(kb, [query])
  end

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
  Otherwise, returns :cannot_unify.
  (Note: invalid variable or constant names should be already filtered out.)
  """
  def unify(list1, list2) do
    if length(list1) != length(list2) do
      :cannot_unify
    else
      {unified, matches} = List.foldl(
        List.zip([list1, list2]),
        {[], []},
        # TODO: Not loving all the if branching going on here...
        fn({s1, s2}, {unified, matches}) ->
          if starts_with_lowercase?(s1) do
            if starts_with_lowercase?(s2) do
              if s1 != s2 do
                {[:cannot_unify | unified], matches}
              else
                # Unified two constants
                {[s1 | unified], matches}
              end
            else
              # Unified constant (s1) and variable (s2)
              {[s1 | unified], [{s2, s1} | matches]}
            end
          else
            if starts_with_uppercase?(s2) do
              if s1 != s2 do
                {[:cannot_unify | unified], matches}
              else
                # Unified two variables
                {[s2 | unified], matches}
              end
            else
              # Unified variable (s1) and constant (s2)
              {[s2 | unified], [{s1, s2} | matches]}
            end
          end
        end
      )
      if Enum.member?(unified, :cannot_unify) do
        :cannot_unify
      else
        {Enum.reverse(unified), Enum.reverse(matches)}
      end
    end
  end
end
