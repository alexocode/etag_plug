defmodule ETag.Generator.SHA512Test do
  use ExUnit.Case, async: true

  import ETag.Generator.SHA512, only: [generate: 1]

  describe ".generate" do
    test "with an empty string returns the expected hash" do
      assert generate("") ==
               "CF83E1357EEFB8BDF1542850D66D8007D620E4050B5715DC83F4A921D36CE9CE47D0D13C5D85F2B0FF8318D2877EEC2F63B931BD47417A81A538327AF927DA3E"
    end

    test "with a \"foo bar\" string returns the expected hash" do
      assert generate("foo bar") ==
               "65019286222ACE418F742556366F9B9DA5AAF6797527D2F0CBA5BFE6B2F8ED24746542A0F2BE1DA8D63C2477F688B608EB53628993AFA624F378B03F10090CE7"
    end
  end
end
