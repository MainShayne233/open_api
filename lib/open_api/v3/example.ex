defmodule OpenAPI.V3.Example do
  @moduledoc false

  use Breakfast

  cereal do
    field(:summary, String.t() | nil, default: nil)
    field(:description, String.t() | nil, default: nil)
    field(:value, any(), default: nil)

    field(:external_value, String.t() | nil, default: nil, fetch: {OpenAPI.Util, :camel_key_fetch})
  end
end
