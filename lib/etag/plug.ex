defmodule ETag.Plug do
  @moduledoc """
  This plug generates shallow ETags.

  Shallow means that it uses the whole response to generate the ETag and does
  not care about the specific content of each response. It is not context
  sensitive.

  For a deep (speak context sensitive) generation of ETags you can take a look
  at [Phoenix ETag](https://github.com/michalmuskala/phoenix_etag).

  # Configuration
  ## `generator`

  Expects a module implementing the `ETag.Generator` behaviour. The plug ships
  with a number of "default" generators:
  - `ETag.MD5`
  - `ETag.SHA1`
  - `ETag.SHA512`

  ### Default

      iex> Application.fetch_env!(:etag_plug, :generator)
      #{inspect(Application.fetch_env!(:etag_plug, :generator))}

  ## `methods`

  Expects a list of strings, describing the HTTP methods for which ETags
  should be generated and evaluated.

  ### Default

      iex> Application.fetch_env!(:etag_plug, :methods)
      #{inspect(Application.fetch_env!(:etag_plug, :methods))}

  ## `status_codes`

  Expects an enumerable of integers which define the statuses for which ETags
  should be handled and generated.

  ### Default

      iex> Application.fetch_env!(:etag_plug, :status_codes)
      #{inspect(Application.fetch_env!(:etag_plug, :status_codes))}
  """

  import Plug.Conn,
    only: [
      get_req_header: 2,
      put_resp_header: 3,
      register_before_send: 2,
      resp: 3
    ]

  require Logger

  defdelegate init(opts), to: ETag.Plug.Options, as: :sanitize!

  def call(conn, opts) do
    register_before_send(conn, &handle_etag(&1, opts))
  end

  def handle_etag(conn, opts) do
    if should_handle_etag?(conn, opts) do
      do_handle_etag(conn, opts)
    else
      conn
    end
  end

  def should_handle_etag?(conn, opts) do
    valid_method?(conn, opts) and valid_status?(conn, opts)
  end

  defp valid_method?(%Plug.Conn{method: method}, opts) do
    String.upcase(method) in Keyword.fetch!(opts, :methods)
  end

  defp valid_status?(%Plug.Conn{status: status}, opts) do
    Plug.Conn.Status.code(status) in Keyword.fetch!(opts, :status_codes)
  end

  defp do_handle_etag(conn, opts) do
    case generate_etag(conn.resp_body, opts) do
      nil ->
        conn

      etag ->
        conn
        |> add_etag(etag)
        |> respond_304_if_not_modified(etag)
    end
  end

  defp generate_etag(content, opts) do
    opts
    |> Keyword.fetch!(:generator)
    |> apply(:generate, [content])
  end

  defp add_etag(conn, etag), do: put_resp_header(conn, "etag", etag)

  defp respond_304_if_not_modified(conn, etag) do
    conn
    |> get_req_header("if-none-match")
    |> etags_match?(etag)
    |> if do
      resp(conn, 304, "")
    else
      conn
    end
  end

  defp etags_match?([], _etag), do: false
  defp etags_match?(etag, etag), do: true

  defp etags_match?(received_etags, etag) when is_list(received_etags),
    do: etag in received_etags

  defp etags_match?(other, _etag) do
    Logger.warn(fn ->
      "Unexpected 'if-none-match' header value: #{inspect(other)}"
    end)

    false
  end
end
