defmodule KB do
  import Utils

  def init(), do: []

  def kb_fact?(kb, fact) do
    Enum.member?(facts(kb), fact)
  end

  def facts(kb), do: Enum.filter(kb, fn thing -> elem(thing, 0) == :fact end)
  def rules(kb), do: Enum.filter(kb, fn thing -> elem(thing, 0) == :rule end)

  def matching_rules(kb, goal) do
    Enum.filter(
      rules(kb),
      fn rule -> 
        {:rule, {:predicate, rule_word, rule_subjects}, _} = rule
        {:predicate, goal_word, goal_subjects} = goal
        rule_word == goal_word && can_unify?(rule_subjects, goal_subjects)
      end
    )
  end

  @doc """
  Constructs a fact consisting of a predicate.
  """
  def fact(predicate), do: {:fact, predicate}

  @doc """
  Constructs a rule with a consequent (head) and one or more antecedents (body).
  E.g. mortal(X) :- man(X).
    -> consequent: mortal(X)
    -> antecedent: man(X)
  """
  def rule(head, body), do: {:rule, head, body}

  @doc """
  Constructs a predicate with one or more subjects.
  E.g. cityOf(toronto, canada)
    -> word: cityOf
    -> subjects: toronto, canada
  """
  def predicate(word, subjects), do: {:predicate, word, subjects}

  @doc """
  Checks if two lists can be unified.
  """
  def can_unify?(list1, list2), do: unify(list1, list2) != :cannot_unify

  @doc """
  Attempts to unify two lists.
  If successful, returns the unified list along with the variable resolutions.
  Otherwise, returns :cannot_unify.
  (Note: invalid variable or constant names should be already filtered out.)
  """
  def unify(list1, list2) do
    IO.puts((inspect list1) <> (inspect list2))
    if length(list1) != length(list2) do
      :cannot_unify
    else
      {unified, matches} = List.foldl(
        List.zip([list1, list2]),
        {[], []},
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

  def replace_vars_with_const(predicates, var, const) do
    new_predicates = List.foldl(
      predicates,
      [],
      fn({:predicate, word, subjects}, new_predicates) ->
        new_subjects = List.foldl(
          subjects,
          [],
          fn(subject, new_subjects) ->
            new_subject = if subject == var, do: const, else: subject
            [new_subject | new_subjects]
          end
        )
        new_predicate = {:predicate, word, Enum.reverse(new_subjects)}
        [new_predicate | new_predicates]
      end
    )
    Enum.reverse(new_predicates)
  end
end
