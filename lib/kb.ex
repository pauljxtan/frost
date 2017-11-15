defmodule KB do
  import Utils

  def init(), do: []

  def kb_fact?(kb, fact), do: Enum.member?(facts(kb), fact)

  def facts(kb), do: Enum.filter(kb, fn rule -> fact?(rule) end)

  def matching_rules(kb, goal) do
    Enum.filter(
      kb,
      fn rule -> 
        head = rule[:head]
        head[:word] == goal[:word] && 
          can_unify?(head[:subjects], goal[:subjects])
      end
    )
  end

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
      fn(predicate, new_predicates) ->
        subjects = predicate[:subjects]
        new_subjects = List.foldl(
          subjects,
          [],
          fn(subject, new_subjects) ->
            new_subject = if subject == var, do: const, else: subject
            [new_subject | new_subjects]
          end
        )
        new_predicate = %{predicate | subjects: Enum.reverse(new_subjects)}
        [new_predicate | new_predicates]
      end
    )
    Enum.reverse(new_predicates)
  end
end
