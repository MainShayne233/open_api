defmodule OpenAPI.Client do
  @moduledoc false

  defmacro __using__(opts) do
    opts
    |> Keyword.fetch!(:document_path)
    |> File.read!()
    |> Jason.decode!()
    |> OpenAPI.cast_document!()
    |> OpenAPI.Client.Builder.build_client(__CALLER__.module)
  end
end
