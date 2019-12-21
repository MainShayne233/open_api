defmodule OpenAPI.Util do
  @moduledoc false

  def camel_key_fetch(params, key) do
    {first_char, rest} = key |> to_string() |> Macro.camelize() |> String.split_at(1)
    camel_key = String.downcase(first_char) <> rest
    Map.fetch(params, camel_key)
  end
end
