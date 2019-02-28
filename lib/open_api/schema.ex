defmodule OpenAPI.Schema do
  use TypedStruct

  alias OpenAPI.Schema.{Info, PathItem, Server}

  typedstruct do
    field(:info, Info.t())
    field(:servers, [Server.t()])

    field(:paths, %{
      required(path_name :: String.t()) => PathItem.t()
    })
  end
end
