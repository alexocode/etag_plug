defmodule ETag.Plug.Options do
  @moduledoc """
  Applies defaults and validates the given options for the plug. Allowed options are:
  - `generator`
  - `methods`
  - `status_codes`

  For details on their usage, values and defaults take a look at the `ETag.Plug` module.
  """

  @spec sanitize!(Keyword.t()) :: Keyword.t()
  def sanitize!(opts) do
    unless Keyword.keyword?(opts) do
      raise ArgumentError,
            "Expected to receive a Keyword list as " <>
              "options but instead received: #{inspect(opts)}"
    end

    opts
    |> with_default!(:generator)
    |> with_default!(:methods)
    |> with_default!(:status_codes)
    |> do_sanitize!()
  end

  defp with_default!(opts, key) do
    Keyword.put_new_lazy(opts, key, fn -> config!(key) end)
  end

  defp config!(key), do: Application.fetch_env!(:etag_plug, key)

  defp do_sanitize!(opts) do
    opts
    |> Keyword.update!(:generator, &validate_generator!/1)
    |> Keyword.update!(:methods, &validate_and_uppercase_methods!/1)
    |> Keyword.update!(:status_codes, &validate_status_codes!/1)
  end

  defp validate_generator!(generator) do
    unless is_atom(generator) do
      raise ArgumentError,
            "Expected the generator to be a module but received: #{inspect(generator)}"
    end

    generator
  end

  defp validate_and_uppercase_methods!(methods) do
    methods =
      Enum.map(methods, fn
        method when is_binary(method) ->
          String.upcase(method)

        method ->
          raise ArgumentError,
                "Expected the methods to be strings but received: #{inspect(method)}"
      end)

    with [] <- methods do
      raise ArgumentError, "Received an empty list for `methods` which makes no sense!"
    end
  end

  defp validate_status_codes!(status_codes) do
    status_codes = Enum.map(status_codes, &Plug.Conn.Status.code/1)

    with [] <- status_codes do
      raise ArgumentError, "Received an empty list for `status_codes` which makes no sense!"
    end
  end
end
