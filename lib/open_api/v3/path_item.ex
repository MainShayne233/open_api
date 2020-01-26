defmodule OpenAPI.V3.PathItem do
  @moduledoc false

  use Breakfast

  alias OpenAPI.V3

  cereal do
    field(:ref, String.t() | nil, default: nil, fetch: {OpenAPI.Util, {:prefixed_key, ["$"]}})
    field(:summary, String.t() | nil, default: nil)
    field(:description, String.t() | nil, default: nil)
    field(:get, {:cereal, V3.Operation} | nil, default: nil)
    field(:post, {:cereal, V3.Operation} | nil, default: nil)
  end
end
