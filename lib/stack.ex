defmodule Stack do
  @moduledoc """
  A simple stack abstraction over lists.
  """
  def new, do: []

  def push(stack, item), do: [item | stack]
  def push_multiple(stack, items) do
    List.foldl(
      items,
      stack,
      fn(item, stack) -> push(stack, item) end
    )
  end

  def peek([]), do: :empty
  def peek([top | _]), do: top

  def pop([]), do: :empty
  def pop([top | rest]), do: {top, rest}

  def size(stack), do: length(stack)

  def empty?(stack), do: stack == []
end
