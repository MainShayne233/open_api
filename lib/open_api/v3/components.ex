defmodule OpenAPI.V3.Components do
  @moduledoc false

  use Breakfast

  alias OpenAPI.V3

  cereal do
    field(
      :schemas,
      %{
        required(name :: String.t()) => {:cereal, V3.Schema} | {:cereal, V3.Reference}
      }
      | nil,
      default: nil
    )

    field(
      :security_schemes,
      %{
        required(name :: String.t()) => {:cereal, V3.SecuritySchema} | {:cereal, V3.Reference}
      }
      | nil,
      default: nil,
      fetch: {OpenAPI.Util, :camel_key_fetch}
    )
  end
end
