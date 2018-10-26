defmodule ETag.Generator do
  @moduledoc """
  The ETag generator behaviour. Simply defines a `generate/1` callback which
  expects a string and returns a string.
  """

  @type content :: String.t()
  @type etag :: String.t()

  @callback generate(content()) :: etag()
end
