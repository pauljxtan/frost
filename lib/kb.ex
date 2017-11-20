defmodule KB do
  import Utils

  #---- Knowledge base

  @doc """
  Initializes an empty knowledge base.
  """
  def init(), do: []

  @doc """
  Returns all facts in the knowledge base.
  """
  def facts(kb), do: Enum.filter(kb, fn thing -> elem(thing, 0) == :fact end)

  @doc """
  Returns all rules in the knowledge base.
  """
  def rules(kb), do: Enum.filter(kb, fn thing -> elem(thing, 0) == :rule end)

  @doc """
  Checks if the given fact is in the knowledge base.
  """
  def kb_fact?(kb, fact), do: Enum.member?(facts(kb), fact)
  end

  @doc """
  Returns all facts matching the given word.
  """
  def lookup_fact(kb, word) do
    Enum.filter(facts(kb), fn {:fact, {:predicate, fact_word, _}} -> fact_word == word end)
  end

  @doc """
  Returns all rules matching the given word.
  """
  def lookup_rule(kb, word) do
    Enum.filter(rules(kb), fn {:rule, {:predicate, rule_word, _}, _} -> rule_word == word end)
  end

  @doc """
  Returns all rules matching the given query.
  """
  def matching_rules(kb, {:predicate, word, subjects}) do
    Enum.filter(
      rules(kb),
      fn rule -> 
        {:rule, {:predicate, rule_word, rule_subjects}, _} = rule
        rule_word == word && can_unify?(rule_subjects, subjects)
      end
    )
  end

  @doc """
  Checks if the given word matches a fact in the database.
  """
  def matches_fact?(kb, word) do
    Enum.any?(facts(kb), fn {:fact, {:predicate, fact_word, _}} -> fact_word == word end)
  end
  
  @doc """
  Checks if the given word matches a rule in the database.
  """
  def matches_rule?(kb, word) do
    Enum.any?(rules(kb), fn {:rule, {:predicate, rule_word, _}, _} -> rule_word == word end)
  end

  @doc """
  Returns all possible subjects for a predicate with the given word.
  (To be more precise, it returns "sets of subjects".)
  """
  def possible_subjects(kb, word) do
    List.foldl(
      facts(kb),
      [],
      fn({:fact, {:predicate, fact_word, fact_subjects}}, subjects) ->
        if fact_word == word, do: subjects ++ [fact_subjects], else: subjects
      end
    )
  end


  #---- Predicate

  @doc """
  Constructs a predicate with one or more subjects.
  E.g. cityOf(toronto, canada)
    -> word: cityOf
    -> subjects: toronto, canada
  """
  def predicate(word, subjects), do: {:predicate, word, subjects}

  def replace_vars_with_const(predicates, var, const) do
    List.foldl(
      predicates,
      [],
      fn({:predicate, word, subjects}, new_predicates) ->
        new_subjects = List.foldl(
          subjects,
          [],
          fn(subject, new_subjects) ->
            new_subjects ++ [(if subject == var, do: const, else: subject)]
          end
        )
        new_predicates ++ [{:predicate, word, new_subjects}]
      end
    )
  end


  #---- Fact

  @doc """
  Constructs a fact consisting of a predicate.
  """
  def fact(predicate), do: {:fact, predicate}


  #---- Rule
  
  @doc """
  Constructs a rule with a consequent (head predicate)
  and one or more antecedents (body predicates).
  E.g. mortal(X) :- man(X).
    -> consequent: mortal(X)
    -> antecedent: man(X)
  """
  def rule(head, body), do: {:rule, head, body}

  @doc """
  Returns the antecedents of the given rule.
  """
  def antecedents_of_rule({:rule, _, antecedents}), do: antecedents

  @doc """
  Returns the antecedents of the given rules.
  """
  def antecedents_of_rules(rules) do
    List.foldl(
      rules,
      [],
      fn(rule, all_antecedents) ->
        all_antecedents ++ antecedents_of_rule(rule)
      end
    )
  end


  #---- Unification

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
                {unified ++ [:cannot_unify], matches}
              else
                # Unified two constants
                {unified ++ [s1], matches}
              end
            else
              # Unified constant (s1) and variable (s2)
              {unified ++ [s1], matches ++ [{s2, s1}]}
            end
          else
            if starts_with_uppercase?(s2) do
              if s1 != s2 do
                {unified ++ [:cannot_unify], matches}
              else
                # Unified two variables
                {unified ++ [s2], matches}
              end
            else
              # Unified variable (s1) and constant (s2)
              {unified ++ [s2], matches ++ [{s1, s2}]}
            end
          end
        end
      )
      if Enum.member?(unified, :cannot_unify) do
        :cannot_unify
      else
        {unified, matches}
      end
    end
  end
end
