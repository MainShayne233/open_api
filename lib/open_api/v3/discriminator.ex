defmodule OpenAPI.V3.Discriminator do
  @moduledoc false

  use Breakfast

  cereal do
    field(:property_name, String.t(), fetch: {OpenAPI.Util, :camel_key_fetch})
    field(:mapping, %{required(String.t()) => String.t()} | nil, default: nil)
  end
end
