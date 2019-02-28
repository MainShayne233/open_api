defmodule OpenAPI.Builder do

  defstruct [:domain, :headers, ]

  defmacro __before_compile__(_env) do
    params = Module.get_attribute(__CALLER__.module, :params)
    _schema = Keyword.fetch!(params, :schema)

    quote do
      def cool do
        :cool
      end
    end
  end
end
