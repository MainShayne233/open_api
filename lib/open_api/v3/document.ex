defmodule OpenAPI.V3.Document do
  @moduledoc """
  TODO
  """

  use Breakfast

  alias OpenAPI.V3

  cereal do
    field(:openapi, String.t())
    field(:info, {:cereal, V3.Info})
    field(:servers, list({:cereal, V3.Server}))
    field(:paths, %{required(path :: String.t()) => {:cereal, V3.PathItem}})
    field(:components, {:cereal, V3.Components} | nil, default: nil)
  end

  def cast(document) do
    case Breakfast.decode(__MODULE__, document) do
      %Breakfast.Yogurt{errors: [], struct: struct} ->
        {:ok, struct}

      %Breakfast.Yogurt{errors: errors} ->
        {:error, errors}
    end
  end

  def cast!(document) do
    case cast(document) do
      {:ok, document} ->
        document

      {:error, errors} ->
        raise "Failed to cast Open API Document. Errors: #{inspect(errors)}"
    end
  end
end
