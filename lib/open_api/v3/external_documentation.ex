defmodule OpenAPI.V3.ExternalDocumentation do
  @moduledoc false

  use Breakfast

  cereal do
    field(:url, String.t())
    field(:description, String.t() | nil, default: nil)
  end
end
