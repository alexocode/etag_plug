defmodule ETag.Generator.SHA512 do
  @behaviour ETag.Generator

  @impl true
  def generate(content) do
    :sha512
    |> :crypto.hash(content)
    |> Base.encode16()
  end
end
