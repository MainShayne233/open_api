defmodule OpenAPI.V3.Document do
  @doc """
  TODO
  """

  use Breakfast

  cereal do
  end

  def cast(document) do
    case Breakfast.decode(__MODULE__, document) do
      %Breakfast.Yogurt{errors: [], struct: struct} ->
        {:ok, struct}

      _other ->
        :error
    end
  end
end
