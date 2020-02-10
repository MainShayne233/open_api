defmodule OpenAPI.V3.PathItem do
  @moduledoc false

  use Breakfast

  alias OpenAPI.V3

  @operation_types [:get, :post]

  cereal do
    field(:ref, String.t() | nil, default: nil, fetch: {OpenAPI.Util, {:prefixed_key, ["$"]}})
    field(:summary, String.t() | nil, default: nil)
    field(:description, String.t() | nil, default: nil)
    field(:get, {:cereal, V3.Operation} | nil, default: nil)
    field(:post, {:cereal, V3.Operation} | nil, default: nil)
  end

  def defined_operations(path_item) do
    Enum.reduce(@operation_types, [], fn operation_type, acc ->
      case Map.fetch!(path_item, operation_type) do
        operation = %V3.Operation{} ->
          [{operation_type, operation} | acc]

        nil ->
          acc
      end
    end)
  end
end
