defmodule OpenAPI do
  @moduledoc """
  Defines the OpenAPI macro to be `use`d in an API module.
  """

  @type spec_file :: {file_path :: String.t(), :json}

  @type map_spec :: map()

  @type spec :: any()

  @type params :: [spec_file]

  @spec __using__(params()) :: :ok
  def __using__(params) do
    generate(params)
  end

  defguardp(
    is_json_spec_file(maybe_json_spec_file)
    when elem(maybe_json_spec_file, 1) == :json and elem(maybe_json_spec_file, 0) |> is_binary()
  )

  defguardp(is_spec_file(maybe_spec_file) when is_json_spec_file(maybe_spec_file))

  @doc """
  Generates the API for the given spec.
  """
  @spec generate([{:spec, spec_file()}]) :: :ok | no_return
  def generate([{:spec, spec_file}]) when is_spec_file(spec_file) do
    with {:ok, %OpenAPI.Spec{} = spec} <- parse_spec_file(spec_file) do
      {:ok, spec}
    end
  end

  @doc """
  Produces an OpenAPI.Spec.t() for the given spec_file()
  """
  @spec parse_spec_file(spec_file()) :: {:ok, OpenAPI.Spec.t()} | {:error, atom()}
  def parse_spec_file({json_file_path, :json} = spec_file) when is_json_spec_file(spec_file) do
    with {:ok, file} <- File.read(json_file_path),
         {:ok, %{} = map_spec} <- Jason.decode(file),
         {:ok, openapi} <- parse_openapi(map_spec),
         {:ok, paths} <- parse_paths(map_spec) do
      %OpenAPI.Spec{openapi: openapi, paths: paths}
      |> return()
    end
  end

  @spec parse_openapi(map_spec()) :: {:ok, String.t()} | {:error, :missing_openapi}
  defp parse_openapi(%{"openapi" => openapi}) when is_binary(openapi) do
    {:ok, openapi}
  end

  defp parse_openapi(%{}) do
    {:error, :missing_openapi}
  end

  @spec parse_paths(map_spec()) :: {:ok, [OpenAPI.Spec.Path.t()]} | {:error, :missing_paths}
  defp parse_paths(%{"paths" => %{} = paths}) when map_size(paths) > 0 do
    paths
    |> Map.to_list()
    |> OpenAPI.Util.EnumUtil.maybe_map(fn
      {path_name, _path_body} ->
        {:ok, %OpenAPI.Spec.Path{name: path_name}}

      _other ->
        :error
    end)
  end

  @spec return(any()) :: {:ok, any()}
  def return(value), do: {:ok, value}
end
