defmodule OpenAPI.V3.XML do
  @moduledoc false

  use Breakfast

  cereal do
    field(:name, String.t() | nil, default: nil)
    field(:namespace, String.t() | nil, default: nil)
    field(:prefix, String.t() | nil, default: nil)
    field(:attribute, boolean() | nil, default: nil)
    field(:wrapped, boolean() | nil, default: nil)
  end
end
