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

    field(:request_body, {:cereal, V3.RequestBody} | {:cereal, V3.Reference} | nil,
      default: nil,
      fetch: {OpenAPI.Util, :camel_key_fetch}
    )

    field(:responses, %{
      required(status_code :: String.t()) => {:cereal, V3.Response} | {:cereal, V3.Reference},
      optional(default :: String.t()) => {:cereal, V3.Response} | {:cereal, V3.Reference}
    })
  end

  @doc false
  @spec requires_request_body?(breakfast_t()) :: boolean()
  def requires_request_body?(operation) do
    case operation do
      %V3.Operation{parameters: [], request_body: nil} ->
        false

      %V3.Operation{} ->
        true
    end
  end
end
