defmodule OpenAPI.V3.Reference do
  @moduledoc false

  use Breakfast

  cereal do
    field(:ref, String.t(), fetch: {OpenAPI.Util, {:prefixed_key, ["$"]}})
  end
end
