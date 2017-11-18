# frost

A logical inference engine based on [backward chaining](https://en.wikipedia.org/wiki/Backward_chaining) that can be extended to applications like [situation calculus](https://en.wikipedia.org/wiki/Situation_calculus) or the [General Problem Solver](https://en.wikipedia.org/wiki/General_Problem_Solver) developed by Simon, Shaw and Newell. Essentially, a simplified and naive variant of Prolog that can be integrated into Elixir applications.

## Components

We use the following building blocks to represent concepts or "knowledge", from low- to high-level:
1. __Predicate__: a word describing one or more subjects.
  * Example: The predicate "X is a man" consists of the word "man" and the subject "X".
2. __Fact__: a predicate resolved onto a real-world object.
  * Example: "Socrates is a man".
3. __Rule__: a hypothetical proposition consisting of a consequent (predicate) implied by one or more antecedents (predicates). In plainer English, "if _[antecedents]_, then _[consequent]_".
  * Example: In the rule "if X is a man, then X is mortal", "X is a man" is the consequent and "X is mortal" is the antecedent.
4. __Knowledge base (KB)__: a collection of facts and rules - see below for an example.

## Conventions

The naming convention follows Prolog: constants start with lower-case ("socrates") and variables start with upper-case ("Person").

## Example

Consider a tiny knowledge base comprising the following facts and rules:

| English                               | Prolog-style notation     |
| ------------------------------------- | ------------------------- |
| "Sartre is a man"                     | `man(sartre).`            |
| "Socrates is a man"                   | `man(socrates).`          |
| "Beauvoir is a woman"                 | `woman(beauvoir).`        |
| "Hypatia is a woman"                  | `woman(hypatia).`         |
| "If X is a man, then X is a person"   | `person(X) :- man(X).`    |
| "If X is a woman, then X is a person" | `person(X) :- woman(X).`  |
| "If X is a person, then X is mortal"  | `mortal(X) :- person(X).` |

The engine may be queried in two ways: establishing the truth of a given fact, or obtaining the subjects that satisfy a given predicate.

Based on the above KB, these are the results of some example queries:

| Query                   | Prolog-style notation  | Answer                           |
| ----------------------- | ---------------------- | -------------------------------- |
| "Is Sartre a man?"      | `?- man(sartre).`      | `true`                           |
| "Is Socrates a woman?"  | `?- woman(socrates).`  | `false`                          |
| "Is Beauvoir a person?" | `?- person(beauvoir).` | `true`                           |
| "Is Hypatia mortal?"    | `?- mortal(hypatia).`  | `true`                           |
| "Is Plato mortal?"      | `?- mortal(plato).`    | `false`                          |
| "Is Socrates male?"     | `?- male(socrates).`   | `:invalid_query` [1]             |
| "Who is a man?"         | `?- man(X).`           | `[["sartre"], "[socrates"]]` [2] |
| "Who is a woman?"       | `?- woman(X).`         | `[["beauvoir"], ["hypatia"]]`    |

### Notes

1. While it's obvious to our highly-evolved human brains that Socrates is male, our KB does not even know what "male" means - we would need additional rules such as `male(X) :- man(X)`, `male(X) :- boy(X)`, `male(X) :- son(X)` and so on.
2. Solutions are returned as _sets of_ subjects. In this particular example we only deal with one subject at a time, but a query like `?- city_of(X, Y)` would return `[["toronto", "canada"], ["newyork", "usa"], ...`.

## API

At the moment, we can just pass a predicate directly to the backchaining function, e.g.
```elixir
kb = some_knowledge_base()
query = KB.predicate("mortal", ["X"])
solutions = Backchain.backchain(kb, KB.predicate("mortal", ["X"]))
# --> [["sartre"], ["socrates"], ["beauvoir"], ["hypatia"]]
```

There should always be lots of relevant examples in the unit tests.

## Features

* [x] Backward chaining
* [ ] Forward chaining
* [ ] Applications to problem solving / planning
