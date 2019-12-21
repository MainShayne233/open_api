defmodule OpenAPI.V3.Info do
  @moduledoc """
  TODO
  """

  use Breakfast

  alias OpenAPI.V3

  cereal do
    field(:title, String.t())
    field(:description, String.t() | nil, default: nil)

    field(:terms_of_service, String.t() | nil,
      default: nil,
      fetch: {OpenAPI.Util, :camel_key_fetch}
    )

    field(:contact, {:cereal, V3.Contact} | nil, default: nil)
    field(:license, {:cereal, V3.License} | nil, default: nil)
    field(:version, String.t())
  end
end
