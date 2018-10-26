defmodule ETag.Generator.MD5Test do
  use ExUnit.Case, async: true

  import ETag.Generator.MD5, only: [generate: 1]

  describe ".generate" do
    test "with an empty string returns the expected hash" do
      assert generate("") == "D41D8CD98F00B204E9800998ECF8427E"
    end

    test "with a \"foo bar\" string returns the expected hash" do
      assert generate("foo bar") == "327B6F07435811239BC47E1544353273"
    end
  end
end
