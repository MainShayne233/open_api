defmodule OpenAPI.Parse do
  @moduledoc """
  Functions for parsing API specs.
  """

  @type spec_file :: {file_path :: String.t(), :json}

  @type map_spec :: map()

  @type spec :: any()

  @type request_body :: OpenAPI.Spec.Content.JSONContent.t()

  defguardp(
    is_json_spec_file(maybe_json_spec_file)
    when elem(maybe_json_spec_file, 1) == :json and elem(maybe_json_spec_file, 0) |> is_binary()
  )

  defguard(is_spec_file(maybe_spec_file) when is_json_spec_file(maybe_spec_file))

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
      {path_name, path_body} ->
        with {:ok, path_actions} <- parse_path_actions(path_body) do
          %OpenAPI.Spec.Path{name: path_name, actions: path_actions}
          |> return()
        end

      _other ->
        {:error, :missing_paths}
    end)
  end

  @spec parse_path_actions(map()) :: {:ok, [OpenAPI.Spec.Action.t()]} | {:error, :missing_actions}
  defp parse_path_actions(%{} = path_body) do
    path_body
    |> Map.to_list()
    |> OpenAPI.Util.EnumUtil.maybe_map(fn
      {action_type, action_body} ->
        with {:ok, parsed_action_type} <- parse_action_type(action_type),
             {:ok, request_body} <- parse_request_body(action_body) do
          %OpenAPI.Spec.Action{type: parsed_action_type, request_body: request_body}
          |> return()
        end

      _other ->
        {:error, :missing_actions}
    end)
  end

  @spec parse_request_body(map()) :: {:ok, request_body()} | {:error, :missing_request_body}
  defp parse_request_body(%{"requestBody" => %{"content" => %{"application/json" => %{} = content_body}}}) do
    {:ok, %OpenAPI.Spec.Content.JSONContent{body: %{}}}
  end

  @spec parse_action_type(String.t()) ::
          {:ok, OpenAPI.Spec.Action.action_type()} | {:error, :missing_action_type}
  defp parse_action_type("post"), do: {:ok, :post}
  defp parse_action_type(_other), do: {:error, :missing_action_type}

  @spec return(any()) :: {:ok, any()}
  def return(value), do: {:ok, value}
end
