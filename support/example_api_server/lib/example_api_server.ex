defmodule Before do
  use Maru.Middleware

  def call(conn, _opts) do
    conn
    |> Map.fetch!(:req_headers)
    |> Enum.find_value(:error, fn
      {"authorization", "Bearer i-am-a-bearer-token"} ->
        :ok

      _ ->
        false
    end)
    |> case do
      :ok ->
        conn

      :error ->
        raise "Unauthorized"
    end
  end
end

defmodule ExampleApiServer do
  use Maru.Server, otp_app: :example_api_server
end

defmodule Router do
  use ExampleApiServer

  resources do
    get do
      json(conn, %{hello: :world})
    end

    namespace :math do
      params do
        requires(:lhs, type: Integer)
        requires(:rhs, type: Integer)
        requires(:operation, type: String)
      end

      post do
        case params do
          %{lhs: lhs, rhs: rhs, operation: "add"} ->
            json(conn, %{result: lhs + rhs})

          %{} ->
            conn
            |> put_status(400)
            |> json(error: "Invalid operation")
        end

        IO.inspect(params, label: "Params")
        json(conn, params)
      end
    end
  end
end

defmodule ExampleApiServer.API do
  use ExampleApiServer

  before do
    plug(Plug.Logger)
    plug(Plug.Static, at: "/static", from: "/my/static/path/")
  end

  plug(Plug.Parsers,
    pass: ["*/*"],
    json_decoder: Jason,
    parsers: [:urlencoded, :json, :multipart]
  )

  plug(Before)

  mount(Router)

  rescue_from Unauthorized, as: e do
    IO.inspect(e)

    conn
    |> put_status(401)
    |> text("Unauthorized")
  end

  rescue_from([MatchError, RuntimeError], with: :custom_error)

  rescue_from :all, as: e do
    IO.inspect(e)

    conn
    |> put_status(Plug.Exception.status(e))
    |> text("Server Error")
  end

  defp custom_error(conn, exception) do
    conn
    |> put_status(500)
    |> text(exception.message)
  end
end
