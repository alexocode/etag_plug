defmodule ETag.Plug do
  @moduledoc """
  A drop in plug to add support for shallow [ETags](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/ETag).

  Shallow means that it uses the whole response to generate the ETag and does
  not care about the specific content of each response. It is not context
  sensitive.

  For a deep (speak context sensitive) generation of ETags you can take a look
  at [Phoenix ETag](https://github.com/michalmuskala/phoenix_etag).

  # Usage

  You can simply use the plug without any configuration, it then defaults to the
  configuration as specified in the "Configuration" section.

      plug ETag.Plug

  You can also provide a number of options, see the "Configuration" section for details.

      plug ETag.Plug,
        generator: MyCustomGenerator,
        methods: ["GET", "HEAD"],
        status_codes: [:ok, 201, :not_modified]

  # Configuration
  ## `generator`

  Expects a module implementing the `ETag.Generator` behaviour. The plug ships
  with a number of "default" generators:
  - `ETag.Generator.MD5`
  - `ETag.Generator.SHA1`
  - `ETag.Generator.SHA512`

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

  Expects an enumerable of integers (or status atoms) which define the statuses
  for which ETags should be handled and generated.

  ### Default

      iex> Application.fetch_env!(:etag_plug, :status_codes)
      #{inspect(Application.fetch_env!(:etag_plug, :status_codes))}
  """

  import Plug.Conn,
    only: [
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

  defp should_handle_etag?(conn, opts) do
    relevant_method?(conn, opts) and relevant_status?(conn, opts)
  end

  defp relevant_method?(%Plug.Conn{method: method}, opts) do
    String.upcase(method) in Keyword.fetch!(opts, :methods)
  end

  defp relevant_status?(%Plug.Conn{status: status}, opts) do
    Plug.Conn.Status.code(status) in Keyword.fetch!(opts, :status_codes)
  end

  defp do_handle_etag(conn, opts) do
    case generate_etag(conn.resp_body, opts) do
      nil ->
        conn

      etag ->
        conn
        |> ETag.put(etag)
        |> respond_304_if_not_modified(etag)
    end
  end

  defp generate_etag(content, opts) do
    opts
    |> Keyword.fetch!(:generator)
    |> apply(:generate, [content])
  end

  defp respond_304_if_not_modified(conn, etag) do
    conn
    |> ETag.match?(etag)
    |> if do
      resp(conn, 304, "")
    else
      conn
    end
  end
end
