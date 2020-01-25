defmodule OpenAPI.V3.Response do
  @moduledoc false

  use Breakfast

  alias OpenAPI.V3

  cereal do
    field(:description, String.t())

    field(
      :content,
      %{
        required(media_type :: String.t()) => {:cereal, V3.MediaType}
      }
      | nil,
      default: nil
    )
  end
end
