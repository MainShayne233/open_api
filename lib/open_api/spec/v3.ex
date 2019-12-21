defmodule OpenAPI.Spec.Util do
  def camel_key_fetch(params, key) do
    {first_char, rest} = key |> to_string() |> Macro.camelize() |> String.split_at(1)
    camel_key = String.downcase(first_char) <> rest
    Map.fetch(params, camel_key)
  end

  def fetch_ref(params, :ref), do: Map.fetch(params, "$ref")

  def maybe_map(enum, map) do
    Enum.reduce_while(enum, [], fn value, acc ->
      case map.(value) do
        {:ok, mapped_value} -> {:cont, [mapped_value | acc]}
        :error -> {:halt, :error}
      end
    end)
    |> case do
      acc when is_list(acc) -> {:ok, Enum.reverse(acc)}
      :error -> :error
    end
  end
end

defmodule OpenAPI.Spec.V3 do
  use Breakfast

  defmodule Info do
    use Breakfast

    defmodule Contact do
      use Breakfast

      cereal do
        field(:name, String.t(), default: "")
        field(:url, String.t(), default: "")
        field(:email, String.t(), default: "")
      end
    end

    defmodule License do
      use Breakfast

      cereal do
        field(:name, String.t())
        field(:url, String.t() | nil, default: nil)
      end
    end

    cereal do
      field(:title, String.t())
      field(:description, String.t() | nil, default: nil)

      field(:terms_of_service, String.t() | nil,
        fetch: {OpenAPI.Spec.Util, :camel_key_fetch},
        default: nil
      )

      field(:contact, {:cereal, Contact} | nil, default: nil)
      field(:license, {:cereal, License} | nil, default: nil)

      field(:version, String.t())
    end
  end

  defmodule Server do
    use Breakfast

    cereal do
      field(:url, String.t())
      field(:description, String.t() | nil, default: nil)
    end
  end

  defmodule PathItem do
    use Breakfast

    defmodule Operation do
      use Breakfast

      defmodule RequestBody do
        use Breakfast

        cereal do
          field(:description, String.t() | nil, default: nil)
        end
      end

      defmodule Reference do
        use Breakfast

        cereal do
          field(:description, String.t() | nil, default: nil)
        end
      end

      cereal do
        field(:tags, [String.t()], default: [])
        field(:description, String.t() | nil, default: nil)
        field(:summary, String.t() | nil, default: nil)

        field(
          :request_body,
          {:cereal, RequestBody} | {:cereal, Reference},
          fetch: {OpenAPI.Spec.Util, :camel_key_fetch}
        )
      end
    end

    cereal do
      field(:ref, String.t() | nil, default: nil, fetch: {OpenAPI.Spec.Util, :fetch_ref})
      field(:description, String.t() | nil, default: nil)
      field(:get, {:cereal, Operation} | nil, default: nil)
      field(:post, {:cereal, Operation} | nil, default: nil)
    end
  end

  cereal do
    field(:openapi, String.t())
    field(:info, {:cereal, Info})
    field(:servers, list({:cereal, Server}))
    field(:paths, %{required(String.t()) => {:cereal, PathItem}})
  end
end
