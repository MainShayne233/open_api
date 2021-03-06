defmodule OpenAPI.Schema.DataSchema do
  use TypedStruct

  alias OpenAPI.Schema.DataSchema

  @type type :: :string | :object | :integer | :float | :array | :boolean

  typedstruct do
    field(:type, type())

    field(:properties, %{
      required(property_name :: String.t()) => DataSchema.t()
    })

    field(:items, DataSchema.t())
  end
end
