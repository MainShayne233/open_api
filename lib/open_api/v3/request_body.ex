defmodule OpenAPI.V3.RequestBody do
  @moduledoc false

  use Breakfast

  alias OpenAPI.V3

  cereal do
    field(:description, String.t() | nil, default: nil)
    field(:content, %{required(String.t()) => {:cereal, V3.MediaType}})
  end
end
