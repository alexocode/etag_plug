defmodule ETag.Generator.SHA1Test do
  use ExUnit.Case, async: true

  import ETag.Generator.SHA1, only: [generate: 1]

  describe ".generate" do
    test "with an empty string returns the expected hash" do
      assert generate("") == "DA39A3EE5E6B4B0D3255BFEF95601890AFD80709"
    end

    test "with a \"foo bar\" string returns the expected hash" do
      assert generate("foo bar") == "3773DEA65156909838FA6C22825CAFE090FF8030"
    end
  end
end
