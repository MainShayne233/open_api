defmodule OpenAPI.Util do
  @moduledoc false

  def camel_key_fetch(params, key) do
    {first_char, rest} = key |> to_string() |> Macro.camelize() |> String.split_at(1)
    camel_key = String.downcase(first_char) <> rest
    Map.fetch(params, camel_key)
  end

  def prefixed_key(params, key, [prefix]) do
    key = prefix <> to_string(key)
    Map.fetch(params, key)
  end

  def cast_string_to_existing_atom(value) do
    {:ok, String.to_existing_atom(value)}
  rescue
    _ in ArgumentError ->
      :error
  end
end
