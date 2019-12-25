defmodule OpenAPI.V3.Schema do
  @moduledoc false

  use Breakfast

  alias OpenAPI.V3

  cereal do
    field(:nullable, boolean() | nil, default: nil)
    field(:discriminator, {:cereal, V3.Discriminator})
    field(:read_only, boolean() | nil, default: nil, fetch: {OpenAPI.Util, :camel_key_fetch})
    field(:write_only, boolean() | nil, default: nil, fetch: {OpenAPI.Util, :camel_key_fetch})
    field(:xml, {:cereal, V3.XML} | nil, default: nil)

    field(:external_docs, {:cereal, V3.ExternalDocumentation} | nil,
      default: nil,
      fetch: {OpenAPI.Util, :camel_key_fetch}
    )

    field(:example, any(), default: nil)
    field(:deprecated, boolean(), default: nil)
  end
end
