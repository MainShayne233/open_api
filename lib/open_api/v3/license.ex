defmodule OpenAPI.V3.License do
  @moduledoc false

  use Breakfast

  cereal do
    field(:name, String.t() | nil, default: nil)
    field(:url, String.t() | nil, default: nil)
  end
end
