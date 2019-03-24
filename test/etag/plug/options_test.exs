defmodule ETag.Plug.OptionsTest do
  use ExUnit.Case, async: true

  import ETag.Plug.Options, only: [sanitize!: 1, defaults: 0]

  describe ".sanitize!" do
    test "with a bullshit atom, returns the defaults" do
      assert_raise ArgumentError, fn -> sanitize!(:bullshit) end
    end

    test "with empty options, returns the defaults" do
      assert_equal(sanitize!([]), defaults())
    end

    test "with one option applies the remaining defaults but does not override the one value" do
      opts = [generator: ETag.Generator.MD5]
      expected = Keyword.merge(defaults(), opts)

      assert_equal(sanitize!(opts), expected)
    end

    test "with full options does not care about the defaults" do
      opts = [
        generator: ETag.Generator.MD5,
        methods: ["FOO"],
        status_codes: [201]
      ]

      assert_equal(sanitize!(opts), opts)
    end

    # Methods

    test "with an atom method raises an ArgumentError" do
      opts = [methods: [:foo_bar]]

      assert_raise ArgumentError, fn -> sanitize!(opts) end
    end

    test "with a empty list for methods raises an ArgumentError" do
      opts = [methods: []]

      assert_raise ArgumentError, fn -> sanitize!(opts) end
    end

    test "with lowercase methods casts them to uppercase" do
      opts = [methods: ["foo"]]

      assert sanitize!(opts)[:methods] == ["FOO"]
    end

    # Generator

    test "with a string as generator raises an ArgumentError" do
      opts = [generator: "foo bar"]

      assert_raise ArgumentError, fn -> sanitize!(opts) end
    end

    # Status Codes

    test "with atom status_methods tries to resolve them to status code numbers" do
      opts = [status_codes: [:ok]]

      assert sanitize!(opts)[:status_codes] == [200]
    end

    test "with a bullshit atom status_methods raises an error" do
      opts = [status_codes: [:bullshit]]

      assert_raise FunctionClauseError, fn -> sanitize!(opts) end
    end

    test "with a empty list for status codes raises an ArgumentError" do
      opts = [status_codes: []]

      assert_raise ArgumentError, fn -> sanitize!(opts) end
    end
  end

  defp assert_equal(expected, actual) do
    expected = Enum.sort(expected)
    actual = Enum.sort(actual)

    assert expected == actual
  end
end
