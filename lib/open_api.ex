defmodule OpenAPI do
  @moduledoc """
  Defines the OpenAPI macro to be `use`d in an API module.
  """

  import OpenAPI.Parse, only: [is_spec_file: 1]

  @type params :: [OpenAPI.Parse.spec_file()]

  @spec __using__(params()) :: :ok
  def __using__(params) do
    generate(params)
  end

  @doc """
  Generates the API for the given spec.
  """
  @spec generate([{:spec, OpenAPI.Parse.spec_file()}]) :: :ok | no_return
  def generate([{:spec, spec_file}]) when is_spec_file(spec_file) do
    with {:ok, %OpenAPI.Spec{} = spec} <- OpenAPI.Parse.parse_spec_file(spec_file) do
      {:ok, spec}
    end
  end
end
