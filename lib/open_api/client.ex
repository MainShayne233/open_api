defmodule OpenAPI.Client do
  @moduledoc false

  defmacro __using__(opts) do
    opts
    |> Keyword.fetch!(:document_path)
    |> File.read!()
    |> Jason.decode!()
    |> OpenAPI.cast_document!()

    :ok
  end
end
