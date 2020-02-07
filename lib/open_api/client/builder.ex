defmodule OpenAPI.Client.Builder do
  @builder_mapping %{
    "3.0.0" => OpenAPI.Client.Builder.V3
  }

  @supported_versions Map.keys(@builder_mapping)

  def build_client(document, module) do
    case Map.fetch(@builder_mapping, document.openapi) do
      {:ok, builder_module} ->
        apply(builder_module, :build_client, [document, module])

      :error ->
        raise """


        Version #{document.openapi || "<none-specified>"} is not currently supported.

        Supported versions are: #{Enum.join(@supported_versions, ",")}
        """
    end
  end
end
