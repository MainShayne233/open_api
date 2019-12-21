defmodule OpenAPI.V3.Parameter do
  @moduledoc false

  use Breakfast

  cereal do
    field(:name, String.t())

    field(:in, :query | :header | :path | :cookie,
      cast: {OpenAPI.Util, :cast_string_to_existing_atom}
    )

    field(:description, String.t() | nil, default: nil)
    field(:required, boolean(), default: false)
    field(:deprecated, boolean() | nil, default: nil)

    field(:allow_empty_value, boolean() | nil,
      default: nil,
      fetch: {OpenAPI.Util, :camel_key_fetch}
    )
  end
end
