defmodule OpenAPI.V3.Contact do
  @moduledoc false

  use Breakfast

  cereal do
    field(:name, String.t() | nil, default: nil)
    field(:url, String.t() | nil, default: nil)
    field(:email, String.t() | nil, default: nil)
  end
end
