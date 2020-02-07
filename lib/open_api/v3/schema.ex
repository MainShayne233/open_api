defmodule OpenAPI.V3.Schema do
  @moduledoc false

  use Breakfast

  alias OpenAPI.V3

  cereal do
    field(:title, String.t() | nil, default: nil)
    field(:required, [String.t()], default: [])
    field(:type, String.t())

    field(:properties, %{required(name :: String.t()) => {:cereal, V3.Schema}} | nil, default: nil)

    field(:example, any(), default: nil)
    field(:nullable, boolean(), default: false)
    field(:discriminator, {:cereal, V3.Discriminator} | nil, default: nil)
    field(:read_only, boolean(), default: false, fetch: {OpenAPI.Util, :camel_key_fetch})
    field(:read_only, boolean(), default: false, fetch: {OpenAPI.Util, :camel_key_fetch})
    field(:write_only, boolean(), default: false, fetch: {OpenAPI.Util, :camel_key_fetch})
    field(:xml, {:cereal, V3.XML} | nil, default: nil)

    field(:external_docs, {:cereal, V3.ExternalDocumentation} | nil,
      fetch: {OpenAPI.Util, :camel_key_fetch},
      default: nil
    )

    field(:deprecated, boolean(), default: false)
  end
end
