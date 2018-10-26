defmodule ETag.Generator.SHA1 do
  @behaviour ETag.Generator

  @impl true
  def generate(content) do
    :sha
    |> :crypto.hash(content)
    |> Base.encode16()
  end
end
