defmodule ETag do
  @moduledoc """
  This module provides a number of util functions to interact with ETags in a `Plug.Conn`.

  It allows you to fetch the sent ETag (`if-none-match`-header), set the generated
  ETag (`etag`-header) and compare a given ETag with the ETag in the `Plug.Conn`.

  ## Functions
  - `get_all/1`
  - `get_first/1`
  - `put/2`
  - `match?/2`
  """

  @doc """
  Returns all ETags of the given connection contained in the `if-none-match`
  header(s).

  Uses `Plug.Conn.get_req_header/1` under the hood.

  ## Examples

      iex> conn = %Plug.Conn{req_headers: [{"if-none-match", "foo bar baz"}]}
      iex> ETag.get_all(conn)
      ["foo bar baz"]

      iex> resp_headers = [{"if-none-match", "foo bar baz"}, {"if-none-match", "stuff"}]
      iex> conn = %Plug.Conn{req_headers: resp_headers}
      iex> ETag.get_all(conn)
      ["foo bar baz", "stuff"]

      iex> conn = %Plug.Conn{}
      iex> ETag.get_all(conn)
      []
  """
  def get_all(%Plug.Conn{} = conn) do
    Plug.Conn.get_req_header(conn, "if-none-match")
  end

  @doc """
  Returns the first result (or `nil`) returned from `ETag.get_all/1`.

  ## Examples

      iex> conn = %Plug.Conn{req_headers: [{"if-none-match", "foo bar baz"}]}
      iex> ETag.get_first(conn)
      "foo bar baz"

      iex> resp_headers = [{"if-none-match", "foo bar baz"}, {"if-none-match", "stuff"}]
      iex> conn = %Plug.Conn{req_headers: resp_headers}
      iex> ETag.get_first(conn)
      "foo bar baz"

      iex> conn = %Plug.Conn{}
      iex> ETag.get_first(conn)
      nil
  """
  def get_first(%Plug.Conn{} = conn) do
    conn
    |> get_all()
    |> List.first()
  end

  @doc """
  Puts the given ETag into the `etag`-header. Uses `Plug.put_resp_header/3`
  under the hood.

  ## Examples

      iex> conn = %Plug.Conn{resp_headers: []}
      iex> ETag.put(conn, "foo bar")
      %Plug.Conn{resp_headers: [{"etag", "foo bar"}]}

      iex> conn = %Plug.Conn{resp_headers: [{"etag", "stuff"}]}
      iex> ETag.put(conn, "foo bar")
      %Plug.Conn{resp_headers: [{"etag", "foo bar"}]}
  """
  def put(%Plug.Conn{} = conn, etag) do
    Plug.Conn.put_resp_header(conn, "etag", etag)
  end

  @doc """
  Compares the given ETag with all contained ETags in the conn. Uses
  `ETag.get_all/1` under the hood.

  ## Examples

      iex> ETag.match?("foo bar", "foo bar")
      true

      iex> ETag.match?(["stuff", "foo bar"], "foo bar")
      true

      iex> ETag.match?(:foo_bar, "foo bar")
      false

      iex> conn = %Plug.Conn{req_headers: []}
      iex> ETag.match?(conn, "foo bar")
      false

      iex> req_headers = [{"if-none-match", "stuff"}]
      iex> conn = %Plug.Conn{req_headers: req_headers}
      iex> ETag.match?(conn, "foo bar")
      false

      iex> req_headers = [{"if-none-match", "foo bar"}]
      iex> conn = %Plug.Conn{req_headers: req_headers}
      iex> ETag.match?(conn, "foo bar")
      true

      iex> req_headers = [{"if-none-match", "stuff"}, {"if-none-match", "foo bar"}]
      iex> conn = %Plug.Conn{req_headers: req_headers}
      iex> ETag.match?(conn, "foo bar")
      true
  """
  def match?(%Plug.Conn{} = conn, etag) do
    conn
    |> ETag.get_all()
    |> ETag.match?(etag)
  end

  def match?([], _etag), do: false
  def match?(etags, etag) when is_list(etags), do: etag in etags
  def match?(expected, actual), do: expected == actual
end
