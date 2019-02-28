defmodule OpenAPI.Builder do

  defstruct [:domain, :headers, ]

  defmacro __before_compile__(env) do
    params = Module.get_attribute(__CALLER__.module, :params)
    schema = Keyword.fetch!(params, :schema)

    quote do
      def cool do
        :cool
      end
    end
  end
end
