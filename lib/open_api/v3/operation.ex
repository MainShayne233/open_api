defmodule OpenAPI.V3.Operation do
  @moduledoc false

  use Breakfast

  alias OpenAPI.V3

  cereal do
    field(:tags, [String.t()] | nil, default: nil)
    field(:summary, String.t() | nil, default: nil)
    field(:description, String.t() | nil, default: nil)

    field(:external_docs, {:cereal, V3.ExternalDocumentation} | nil,
      default: nil,
      fetch: {OpenAPI.Util, :camel_key_fetch}
    )

    field(:operation_id, String.t() | nil, default: nil, fetch: {OpenAPI.Util, :camel_key_fetch})
    field(:parameters, [{:cereal, V3.Parameter} | {:cereal, V3.Reference}] | nil, default: nil)
  end
end
