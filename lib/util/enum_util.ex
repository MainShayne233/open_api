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
end
