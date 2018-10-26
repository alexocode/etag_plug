defmodule EtagPlugTest do
  use ExUnit.Case
  doctest EtagPlug

  test "greets the world" do
    assert EtagPlug.hello() == :world
  end
end
