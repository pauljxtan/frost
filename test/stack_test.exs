defmodule StackTests do
  use ExUnit.Case

  test "create new, check empty, peek, push, pop" do
    stack = Stack.new()
    assert Stack.empty?(stack)
    assert Stack.peek(stack) == :empty
    stack = stack |> Stack.push(1)
    assert Stack.peek(stack) == 1
    stack = stack |> Stack.push(2) |> Stack.push(3)
    assert Stack.peek(stack) == 3
    {top, stack} = Stack.pop(stack)
    assert Stack.peek(stack) == 2
    assert top == 3
  end
end
