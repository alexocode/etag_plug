defmodule ETag.PlugTest do
  use ExUnit.Case, async: true

  import ETag.Plug, only: [call: 2, handle_etag: 2]

  describe ".call" do
    test "sets a before_send callback" do
      conn = conn()
      opts = opts()

      assert %Plug.Conn{before_send: [_handle_etag_function]} = call(conn, opts)
    end
  end

  describe "request method sensitivity" do
    for method <- ["POST", "PUT", "DELETE"] do
      test "with #{inspect(method)} as method it leaves the conn untouched" do
        conn = conn(method: unquote(method))
        opts = opts()

        assert handle_etag(conn, opts) == conn
      end
    end

    test "with \"GET\" as method it updates the conn" do
      conn = conn(method: "GET")
      opts = opts()

      assert handle_etag(conn, opts) != conn
    end
  end

  describe "response status code sensitivity" do
    for status_code <- [201, 300, 400, 500] do
      test "with #{inspect(status_code)} as status_code it leaves the conn untouched" do
        conn = conn(status: unquote(status_code))
        opts = opts()

        assert handle_etag(conn, opts) == conn
      end
    end

    test "with 200 as status code it updates the conn" do
      conn = conn(status: 200)
      opts = opts()

      assert handle_etag(conn, opts) != conn
    end
  end

  describe "etag generation" do
    test "for a GET request and 200 status code it generates the etag for the response body" do
      conn = conn(method: "GET", status: 200, resp_body: "foo bar baz")
      opts = opts(generator: ETag.Generator.MD5)

      assert ["AB07ACBB1E496801937ADFA772424BF7"] ==
               conn
               |> handle_etag(opts)
               |> Plug.Conn.get_resp_header("etag")
    end
  end

  describe "etag evaluation and handling" do
    test "for a GET request, with 200 status code and a fitting if-none-match header it sends a 304 status code and empty response body" do
      conn =
        conn(
          req_headers: [{"if-none-match", "AB07ACBB1E496801937ADFA772424BF7"}],
          method: "GET",
          status: 200,
          resp_body: "foo bar baz"
        )

      opts = opts(generator: ETag.Generator.MD5)

      assert %Plug.Conn{status: 304, resp_body: ""} = handle_etag(conn, opts)
    end

    test "for a GET request, with 200 status code and a not fitting if-none-match header it leaves the status code and response body be" do
      conn =
        conn(
          req_headers: [{"if-none-match", "this does not match"}],
          method: "GET",
          status: 200,
          resp_body: "foo bar baz"
        )

      opts = opts(generator: ETag.Generator.MD5)

      assert %Plug.Conn{status: 200, resp_body: "foo bar baz"} = handle_etag(conn, opts)
    end
  end

  defp conn(params \\ []) do
    %Plug.Conn{}
    |> Map.merge(%{method: "GET", status: 200, resp_body: ""})
    |> Map.merge(Map.new(params))
  end

  defp opts(opts \\ []) do
    opts
    |> Keyword.put_new(:methods, ["GET"])
    |> Keyword.put_new(:status_codes, [200])
    |> ETag.Plug.init()
  end
end
