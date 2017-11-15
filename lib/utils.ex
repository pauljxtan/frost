defmodule Utils do
  def valid_var_or_const?(string) do
    starts_with_uppercase?(string) || starts_with_lowercase?(string)
  end

  def starts_with_uppercase?(string), do: String.first(string) =~ ~r/[A-Z]/
  def starts_with_lowercase?(string), do: String.first(string) =~ ~r/[a-z]/
end
