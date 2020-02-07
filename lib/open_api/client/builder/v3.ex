defmodule OpenAPI.Client.Builder.V3 do
  alias OpenAPI.V3

  @enforce_keys [:document, :module_path]

  defstruct @enforce_keys

  def build_client(document, module) do
    builder = %__MODULE__{
      document: document,
      module_path: [module]
    }

    quote do
      defmodule Paths do
        (unquote_splicing(
           Enum.map(document.paths, &define_path(&1, append_to_module_path(builder, [Paths])))
         ))
      end
    end
  end

  defp define_path({path, %V3.PathItem{}}, builder) do
    path_module_path = path_module_path(path)
    builder = append_to_module_path(builder, path_module_path)

    quote do
      defmodule unquote(Module.concat(builder.module_path)) do
      end
    end
  end

  defp path_module_path("/") do
    path_module_path("/root")
  end

  defp path_module_path(path) do
    path
    |> String.split("/")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&:"Elixir.#{String.capitalize(&1)}")
  end

  defp append_to_module_path(builder, path) when is_list(path) do
    %__MODULE__{builder | module_path: builder.module_path ++ path}
  end
end
