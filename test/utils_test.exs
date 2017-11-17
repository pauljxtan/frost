defmodule UtilsTests do
  use ExUnit.Case

  test "string utils" do
    assert Utils.valid_var_or_const?("socrates1")
    refute Utils.valid_var_or_const?("1socrates1")
    assert Utils.starts_with_uppercase?("Socrates")
    refute Utils.starts_with_uppercase?("socrates")
    assert Utils.starts_with_lowercase?("socrates")
    refute Utils.starts_with_lowercase?("Socrates")
  end
end
