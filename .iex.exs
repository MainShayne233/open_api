defmodule ExampleApp do
  use OpenAPI.Client, document_path: "support/example_api_server/open_api_document.json"
end
