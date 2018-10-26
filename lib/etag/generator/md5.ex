defmodule ETag.Generator.MD5 do
  @behaviour ETag.Generator

  @impl true
  def generate(content) do
    :md5
    |> :crypto.hash(content)
    |> Base.encode16()
  end
end
