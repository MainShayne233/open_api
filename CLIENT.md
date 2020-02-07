# Client

This describes how the client module should be defined.

```elixir
defmodule APIModule do

  defmodule Auth do
  end

  defmodule Paths do
  
    defmodule Root do
    
      def get do
        ...
      end
    
      defmodule Math do
        def post(payload) do
        end
      end
      ...
      
      defmodule User do
        defmodule Edit do
          def 
        end
      end
    end
  end
end
```
