defmodule Stack do
  @moduledoc """
  A simple stack abstraction over lists.
  """
  def new, do: []

  def push(stack, item), do: [item | stack]}

  def peek([]), do: :empty
  def peek([top | _]), do: top

  def pop([]), do: :empty
  def pop([top | rest]), do: {top, rest}

  def size(stack), do: length(items)

  def empty?(stack), do: stack == []
end
