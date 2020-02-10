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
        @moduledoc """
        TODO
        """

        (unquote_splicing(
           Enum.map(document.paths, &define_path(&1, append_to_module_path(builder, [Paths])))
         ))
      end
    end
  end

  defp define_path({path, %V3.PathItem{} = path_item}, builder) do
    path_module_path = path_module_path(path)
    builder = append_to_module_path(builder, path_module_path)
    operations = V3.PathItem.defined_operations(path_item)

    quote do
      defmodule unquote(Module.concat(builder.module_path)) do
        @moduledoc """
        TODO
        """

        (unquote_splicing(Enum.map(operations, &define_operation(&1, builder))))
      end
    end
  end

  defp define_operation({operation_type, %V3.Operation{} = operation}, builder) do
    params =
      if V3.Operation.requires_request_body?(operation) do
        quote do
          [%{} = request_body]
        end
      else
        []
      end

    quote do
      @doc """
      TODO
      """
      def unquote(operation_type)(unquote_splicing(params)) do
        %OpenAPI.HTTP.Request{
          operation_type: unquote(operation_type),
          request_body: unquote(Enum.at(params, 0))
        }
      end
    end
  end

  defp quoted_params_from_names(names) do
    names
    |> length()
    |> Macro.generate_arguments(nil)
    |> Enum.zip(names)
    |> Enum.map(fn {{_, opts, mod}, name} ->
      {name, opts, mod}
    end)
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
