defmodule OpenAPI.V3.Server do
  @moduledoc false

  use Breakfast

  alias OpenAPI.V3

  cereal do
    field(:url, String.t() | nil, default: nil)
    field(:description, String.t() | nil, default: nil)
    field(:variables, %{required(String.t()) => {:cereal, V3.ServerVariable}} | nil, default: nil)
  end
end
