defmodule OpenAPI do
  def cast_document!(raw_document) do
    case raw_document do
      %{"openapi" => "3.0.0"} ->
        OpenAPI.V3.Document.cast!(raw_document)

      %{"openapi" => version} ->
        raise "Version #{version} of Open API is not supported"

      %{} ->
        raise "Malformed Open API document"
    end
  end
end
