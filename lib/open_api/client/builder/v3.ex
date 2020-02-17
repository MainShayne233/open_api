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

        (unquote_splicing(Enum.map(operations, &define_operation_module(&1, builder))))
      end
    end
  end

  defp define_operation_module({operation_type, %V3.Operation{} = operation}, builder) do
    builder = append_to_module_path(builder, [upcase_atom(operation_type)])

    maybe_request_body_schema = maybe_request_body_schema(operation, builder)

    quote do
      defmodule unquote(Module.concat(builder.module_path)) do
        unquote(maybe_define_request_body_module(maybe_request_body_schema, builder))

        unquote(define_responses_module(operation, builder))

        def new_request(_request_body, _options \\ []) do
          :ok
        end

        def make_request(_request) do
          :ok
        end
      end
    end
  end

  defp define_responses_module(operation, builder) do
    builder = append_to_module_path(builder, [Responses])

    quote do
      defmodule unquote(Module.concat(builder.module_path)) do
        (unquote_splicing(Enum.map(operation.responses, &define_response_module(&1, builder))))
      end
    end
  end

  defp define_response_module({status_code, response}, builder) do
    module_path_chunk =
      case Integer.parse(status_code) do
        {_, ""} ->
          :"Elixir.StatusCode#{status_code}"

        :error when status_code == "default" ->
          Default

        other ->
          raise "Expected a valid HTTP status code (string integer, or \"default\"), got: #{
                  inspect(other)
                }"
      end

    builder = append_to_module_path(builder, [module_path_chunk])

    quote do
      defmodule unquote(Module.concat(builder.module_path)) do
      end
    end
  end

  defp maybe_define_request_body_module(:none, _builder), do: nil

  defp maybe_define_request_body_module({:ok, %V3.Schema{} = schema}, builder) do
    builder = append_to_module_path(builder, [RequestBody])

    quote do
      defmodule unquote(Module.concat(builder.module_path)) do
        unquote(V3.Schema.to_cereal(schema))

        def new(params) do
          :ok
        end
      end
    end
  end

  defp maybe_request_body_schema(operation, _builder) do
    with {:parameters, []} <-
           {:parameters,
            Enum.filter(operation.parameters, &match?(%V3.Parameter{in: "path"}, &1))},
         {:request_body, nil} <- {:request_body, operation.request_body} do
      :none
    else
      {:parameters, _} ->
        raise "REQUEST BODY FROM PATH PARAMS NOT IMPLEMENTED"

      {:request_body,
       %V3.RequestBody{
         content: %{
           "application/x-www-form-urlencoded" => %OpenAPI.V3.MediaType{
             schema: %OpenAPI.V3.Schema{} = schema
           }
         }
       }} ->
        {:ok, schema}
    end
  end

  defp upcase_atom(atom) do
    upcased =
      atom
      |> Atom.to_string()
      |> String.capitalize()

    :"Elixir.#{upcased}"
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
