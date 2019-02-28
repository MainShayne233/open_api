defmodule OpenAPI.Util.EnumUtil do
  @doc """
  Works like `Enum.map/3``, but will only continue prepending to the `acc` if
  the resulting value from the `fun` is in the form `{:ok, value}`, and will
  early return with whatever value that didn't match otherwise.

  ## Examples

      iex> OpenAPI.Util.EnumUtil.maybe_map([1, 2, 3, 4], fn number ->
      ...>   {:ok, 2 * number}
      ...> end)
      {:ok, [2, 4, 6, 8]}

      iex> OpenAPI.Util.EnumUtil.maybe_map([1, 2, 3, 4], fn
      ...>   number when rem(number, 2) == 0 ->
      ...>     {:ok, 2 * number}
      ...>   _number ->
      ...>     {:error, :unexpected_odd_number}
      ...> end)
      {:error, :unexpected_odd_number}
  """
  @spec maybe_map([any] | map(), function, [any]) :: {:ok, [any]} | any
  def maybe_map(list, fun, acc \\ [])

  def maybe_map([], _fun, acc) when is_list(acc), do: {:ok, Enum.reverse(acc)}

  def maybe_map([item | rest_of_items], fun, acc) when is_function(fun) and is_list(acc) do
    with {:ok, value} <- fun.(item) do
      maybe_map(rest_of_items, fun, [value | acc])
    end
  end

  @type process :: (any() -> any())

  @doc """
  Takes an initial value and list of processes, and runs the value through
  each process until either:

    - There are no more process, in which the processed struct is returned

    - A value other than {:ok, any()} is returned, in which the unmatched value is returned early


  ## Examples

      iex> OpenAPI.Util.EnumUtil.process_map(0, [&({:ok, &1 + 1}), &({:ok, &1 * 2})])
      {:ok, 2}
      iex> OpenAPI.Util.EnumUtil.process_map(0, [&({:ok, &1 + 1}), fn _ -> :oops end, &({:ok, &1 * 2})])
      :oops
  """
  @spec process_map(any(), [process()]) :: {:ok, any()} | any()
  def process_map(value, []) do
    {:ok, value}
  end

  def process_map(value, [next_process | rest]) when is_function(next_process, 1) do
    with {:ok, next_value} <- next_process.(value) do
      process_map(next_value, rest)
    end
  end
end
