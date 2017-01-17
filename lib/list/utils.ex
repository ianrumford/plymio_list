defmodule Plymio.List.Utils do

  @moduledoc ~S"""
  Utility functions for lists
  """

  require Logger

  @doc ~S"""
  Returns `true` if value is a list of lists of size 2, else `false`

  ## Examples

      iex> [1,[21, 22],3] |> list_2tuples?
      false

      iex> [a: 1, b: 2, c: 3] |> list_2tuples?
      true

      iex> [{:a, 1}, {:b, 2}, {:c, 3}] |> list_2tuples?
      true

      iex> [{:a, 1}, {:b, 2}, {:c, 3}] |> Stream.map(&(&1)) |> list_2tuples?
      false

      iex> 42 |> list_2tuples?
      false
  """

  @spec list_2tuples?(any) :: true | false

  # header
  def list_2tuples?(value)

  def list_2tuples?(value) when is_list(value) do
    value
    |> Enum.all?(
    fn
      {_, _} -> true
      _ -> false
    end)
  end

  # default
  def list_2tuples?(_value) do
    false
  end

  @doc ~S"""
  Returns `true` if value is a list of lists of size 2, else `false`

  ## Examples

      iex> [1,[21, 22],3] |> list_2lists?
      false

      iex> [[11, 12], [21, 22], [31, 32]] |> list_2lists?
      true

      iex> %{a: 1} |> list_2lists?
      false

      iex> [[11, 12], [21, 22], [31, 32]] |> Stream.map(&(&1)) |> list_2lists?
      false

      iex> 42 |> list_2lists?
      false
  """

  @spec list_2lists?(any) :: true | false

  # header
  def list_2lists?(value)

  def list_2lists?(value) when is_list(value) do
    Enum.all?(value,
      fn
        [_, _] -> true
        _ -> false
      end)
  end

  # default
  def list_2lists?(_value), do: false

  @doc ~S"""
  Converts a list into a list of 2tuples.

  ## Examples

      iex> ["a", 1, :b, 2, 31, 32] |> list_to_2tuples
      [{"a", 1}, {:b, 2}, {31, 32}]

      iex> [{:a, 1}, {:b, 2}, {:c, 3}, {:d, 4}] |> list_to_2tuples
      [{{:a, 1}, {:b, 2}}, {{:c, 3}, {:d, 4}}]

      iex> [:a, 1, :b, 2, :c, 3, :a, 4, :c, 5] |> list_to_2tuples
      [{:a, 1}, {:b, 2}, {:c, 3}, {:a, 4}, {:c, 5}]
  """

  @spec list_to_2tuples(list) :: [{any,any}]

  def list_to_2tuples(list) when is_list(list) do

    list
    # must be even no. of elements
    |> length
    |> rem(2)
    |> case do
         # is even
         0 -> list
         _ ->
           message = "#{inspect __MODULE__}.list_to_2tuples: list not even #{inspect list}"
           Logger.error message
           raise FunctionClauseError
       end
       |> Enum.chunk(2)
    |> Enum.map(fn [k,v] -> {k,v} end)

  end

  @doc ~S"""
  Converts a list into a `Keyword`

  Raise a `FunctionClauseError` exception if any of the keys are not an `Atom`.

  ## Examples

      iex> [:a, 1, :b, 2, :c, 3, :a, 4, :c, 5] |> list_to_keyword!
      [a: 1, b: 2, c: 3, a: 4, c: 5]

      iex> error = assert_raise FunctionClauseError, fn ->
      ...>  ["a", 1, :b, 2, 31, 32] |> list_to_keyword!
      ...> end
      iex> match?(%FunctionClauseError{}, error)
      true
  """

  @spec list_to_keyword!(list) :: Keyword.t | no_return

  def list_to_keyword!(list) when is_list(list) do

    list
    |> list_to_2tuples
    # ensure atom keys
    |> Stream.map(fn {k, v} when is_atom(k) -> {k, v} end)
    # use Enum.into to preserve order and duplicate keys
    |> Enum.into(Keyword.new)

  end

  @doc ~S"""
  Converts a list into a `Map` by creating 2tuples from pairs of values.

  The last value of a repeated key wins (i.e same as `Enum.into/2`)

  ## Examples

      iex> [:a, 1, :b, 2, :c, 3] |> list_to_map
      %{a: 1, b: 2, c: 3}

      iex> ["a", 1, :b, 2, 31, 32] |> list_to_map
      %{"a" => 1, :b => 2, 31 => 32}
  """

  @spec list_to_map(list) :: map

  def list_to_map(list) when is_list(list) do

    list
    |> list_to_2tuples
    |> Enum.into(%{})

  end

  @doc ~S"""
  Flattens a list and removes `nils` at the *first / top* level.

  ## Examples

      iex> [{:a, 1}, nil, [{:b1, 12}, nil, {:b2, [nil, 22, nil]}], nil, {:c, 3}] |> list_flat_just
      [a: 1, b1: 12, b2: [nil, 22, nil], c: 3]
  """

  @spec list_flat_just(list) :: list

  def list_flat_just(list) when is_list(list) do
    list
    |> List.flatten
    |> Enum.reject(&is_nil/1)
  end

  @doc ~S"""
  Wraps a value (if not already a list), flattens and removes `nils` at the *first / top* level.

  ## Examples

      iex> [{:a, 1}, nil, [{:b1, 12}, nil, {:b2, [nil, 22, nil]}], nil, {:c, 3}] |> list_wrap_flat_just
      [a: 1, b1: 12, b2: [nil, 22, nil], c: 3]

      iex> [[[nil, 42, nil]]] |> list_wrap_flat_just
      [42]
  """

  @spec list_wrap_flat_just(any) :: list

  def list_wrap_flat_just(list) do
    list
    |> List.wrap
    |> List.flatten
    |> Enum.reject(&is_nil/1)
  end

  @doc ~S"""
  Flattens a list, removes `nils` at
  the *first / top* level, and deletes duplicates (using `Enum.uniq/1`).

  ## Examples

      iex> [{:a, 1}, nil, [{:b1, 12}, nil, {:b2, [nil, 22, nil]}], nil, {:c, 3}, {:a, 1}, {:b1, 12}] |> list_flat_just_uniq
      [a: 1, b1: 12, b2: [nil, 22, nil], c: 3]

      iex> [nil, [42, [42, 42, nil]], 42] |> list_flat_just_uniq
      [42]
  """

  @spec list_flat_just_uniq(list) :: list

  def list_flat_just_uniq(list) when is_list(list) do
    list
    |> List.flatten
    |> Stream.reject(&is_nil/1)
    |> Enum.uniq
  end

  @doc ~S"""
  Wraps a value (if not already a list), flattens, removes `nils` at
  the *first / top* level, and deletes duplicates (using `Enum.uniq/1`)

  ## Examples

      iex> [{:a, 1}, nil, [{:b1, 12}, nil, {:b2, [nil, 22, nil]}], nil, {:c, 3}, {:a, 1}, {:b1, 12}] |> list_wrap_flat_just_uniq
      [a: 1, b1: 12, b2: [nil, 22, nil], c: 3]

      iex> [nil, [42, [42, 42, nil]], 42] |> list_wrap_flat_just_uniq
      [42]
  """

  @spec list_wrap_flat_just_uniq(any) :: list

  def list_wrap_flat_just_uniq(list) do
    list
    |> List.wrap
    |> List.flatten
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq
  end

  @doc ~S"""
  Wraps a value (if not already a list) and  removes `nils` at the *first / top* level.

  ## Examples

      iex> [{:a, 1}, nil, [{:b1, 12}, nil, {:b2, [nil, 22, nil]}], nil, {:c, 3}, {:a, 1}, {:b1, 12}] |> list_wrap_just
      [{:a, 1}, [{:b1, 12}, nil, {:b2, [nil, 22, nil]}], {:c, 3}, {:a, 1}, {:b1, 12}]

      iex> 42 |> list_wrap_just
      [42]

      iex> nil |> list_wrap_just
      []

      iex> [nil, nil, nil] |> list_wrap_just
      []
  """

  @spec list_wrap_just(any) :: list

  def list_wrap_just(any) do
    any |> List.wrap |> Enum.reject(&is_nil/1)
  end

  @doc ~S"""
  Wraps a value (if not already a list) and flattens.

  Note: nil |> List.wrap returns an empty list

  ## Examples

      iex> [{:a, 1}, nil, [{:b1, 12}, nil, {:b2, [nil, 22, nil]}], nil, {:c, 3}, {:a, 4}, {:c, 5}] |> list_wrap_flat
      [{:a, 1}, nil, {:b1, 12}, nil, {:b2, [nil, 22, nil]}, nil, {:c, 3}, {:a, 4}, {:c, 5}]

      iex> 42 |> list_wrap_flat
      [42]

      iex> nil |> list_wrap_flat
      []

      iex> [nil, [nil, nil, nil], nil] |> list_wrap_flat
      [nil, nil, nil, nil, nil]
  """

  @spec list_wrap_flat(any) :: list

  def list_wrap_flat(any) do
    any |> List.wrap |> List.flatten
  end

  @doc ~S"""
  Removes `nils` at the *first / top* level.

  ## Examples

      iex> [{:a, 1}, nil, [{:b1, 12}, nil, {:b2, [nil, 22, nil]}], nil, {:c, 3}, {:a, 4}, {:c, 5}] |> list_just
      [{:a, 1}, [{:b1, 12}, nil, {:b2, [nil, 22, nil]}], {:c, 3}, {:a, 4}, {:c, 5}]

      iex> [nil, [nil, nil, nil], nil] |> list_just
      [[nil, nil, nil]]
  """

  @spec list_just(list) :: list

  def list_just(list) when is_list(list) do
    list |> Enum.reject(&is_nil/1)
  end

  @doc ~S"""
  Returns the one and only entry in a list. Raises a` FunctionClauseError` exception if not.

  ## Examples

      iex> [42] |> list_fetch_singleton!
      42

      iex> error = assert_raise FunctionClauseError, fn ->
      ...>  [42, 42] |> list_fetch_singleton!
      ...> end
      iex> match?(%FunctionClauseError{}, error)
      true

      iex> error = assert_raise FunctionClauseError, fn ->
      ...>  [] |> list_fetch_singleton!
      ...> end
      iex> match?(%FunctionClauseError{}, error)
      true
  """

  @spec list_fetch_singleton!(list) :: any | no_return

  def list_fetch_singleton!(list)
  when is_list(list) and length(list) == 1 do
    list |> List.first
  end

  @doc ~S"""
  Returns the one and only entry in a list which must be a `Keyword`.
  Raises a `FunctionClauseError` exception if not.

  ## Examples

      iex> [[a: 1, b: 2, c: 3]] |> list_fetch_keyword_singleton!
      [a: 1, b: 2, c: 3]

      iex> error = assert_raise FunctionClauseError, fn ->
      ...>  [42] |> list_fetch_keyword_singleton!
      ...> end
      iex> match?(%FunctionClauseError{}, error)
      true

      iex> error = assert_raise FunctionClauseError, fn ->
      ...>  [] |> list_fetch_keyword_singleton!
      ...> end
      iex> match?(%FunctionClauseError{}, error)
      true
  """

  @spec list_fetch_keyword_singleton!(list) :: Keyword.t | no_return

  def list_fetch_keyword_singleton!(list) when is_list(list) do

    value = list_fetch_singleton!(list)

    cond do
      Keyword.keyword?(value) -> value
      true -> raise FunctionClauseError
    end

  end

  @doc ~S"""
  Returns the last entry in a list which must be a `Keyword`. Raises a
  `FunctionClauseError` exception if not.

  ## Examples

      iex> [[a: 1, b: 2, c: 3]] |> list_fetch_keyword_last!
      [a: 1, b: 2, c: 3]

      iex> error = assert_raise FunctionClauseError, fn ->
      ...>  [42] |> list_fetch_keyword_last!
      ...> end
      iex> match?(%FunctionClauseError{}, error)
      true

      iex> error = assert_raise FunctionClauseError, fn ->
      ...>  [] |> list_fetch_keyword_last!
      ...> end
      iex> match?(%FunctionClauseError{}, error)
      true
  """

  @spec list_fetch_keyword_last!(list) :: Keyword.t | no_return

  def list_fetch_keyword_last!(list) when is_list(list) do

    value = List.last(list)

    cond do
      Keyword.keyword?(value) -> value
      true -> raise FunctionClauseError
    end

  end

  def list_find_key_index(list, key) do

    # find matching entry; may not exists ==> return nil
    ndx = list
    |> Enum.find_index(fn v -> v == key end)

    ndx

  end

  def list_find_key_index!(list, key) do
    case list_find_key_index(list, key) do
      x when is_integer(x) -> x
      # no default
    end
  end

  @plymio_lists_verb_many_insert [:insert]
  @plymio_lists_verb_many_delete_replace [:delete, :replace]

  # when inserting a tuple index is the value to find not a {index, length}
  defp list_verb_many_at_resolve_index_and_count(verb, list, value)
  when verb in @plymio_lists_verb_many_insert and is_tuple(value) do
    {list_find_key_index!(list, value), 1}
  end

  defp list_verb_many_at_resolve_index_and_count(_verb, list, value)

  defp list_verb_many_at_resolve_index_and_count(_verb, _list, index) when is_integer(index) do
    {index, 1}
  end

  defp list_verb_many_at_resolve_index_and_count(verb, _list, {index, count})
  when verb in @plymio_lists_verb_many_delete_replace and is_integer(index) and is_integer(count) do
    {index, count}
  end

  defp list_verb_many_at_resolve_index_and_count(verb, _list, {index})
  when verb in @plymio_lists_verb_many_delete_replace and is_integer(index) do
    {index, 1}
  end

  defp list_verb_many_at_resolve_index_and_count(verb, list, {key, count})
  when verb in @plymio_lists_verb_many_delete_replace and is_integer(count) do
    {list_find_key_index!(list, key), count}
  end

  defp list_verb_many_at_resolve_index_and_count(verb, list, {value})
    when verb in @plymio_lists_verb_many_delete_replace do
    {list_find_key_index!(list, value), 1}
  end

  defp list_verb_many_at_resolve_index_and_count(_verb, list, value) do
    {list_find_key_index!(list, value), 1}
  end

  defp list_verb_many_at_resolve_index_and_count!(verb, list, value) do
    case list_verb_many_at_resolve_index_and_count(verb, list, value) do
      {ndx, len} when is_integer(ndx) and is_integer(len) and len >= 0 -> {ndx, len}
      # no default
    end
  end

  defp list_verb_many_at_resolve_new_values(values)

  defp list_verb_many_at_resolve_new_values(values) when is_list(values) do
    values
  end

  defp list_verb_many_at_resolve_new_values(%Stream{} = values) do
    values |> Enum.to_list
  end

  defp list_verb_many_at_resolve_new_values(values) when is_map(values) do
    [values]
  end

  defp list_verb_many_at_resolve_new_values(values) do
    values |> List.wrap
  end

  @doc ~S"""
  Returns a list with the `value(s)` inserted at the specified `index`.

  Similar to `List.insert_at/3` but takes one or more (i.e an enumerable) `values`.

  Note a `Map` `value` is *not* treated as an enumerable.

  ## Index Specification

  Supports the same zero-based (`Integer`) index values as `List.insert_at/3`.

  Also supports these extra index specifications:

    * `:ante` - prepend the new values
    * `:post` - append the new values
    * `nil` - append the values
    * an existing value - new values inserted *before* the existing value

  ## Examples

      iex> [1, 2, 3] |> list_insert_many_at(3, 42)
      [1, 2, 3, 42]

      iex> [1, 2, 3] |> list_insert_many_at(-1, 42)
      [1, 2, 42, 3]

      iex> [1, 2, 3] |> list_insert_many_at(2, %{x: 1})
      [1, 2, %{x: 1}, 3]

      iex> [1, 2, 3] |> list_insert_many_at(1, [4, 5, 6])
      [1, 4, 5, 6, 2, 3]

      iex> stream = [4, 5, 6] |> Stream.map(&(&1))
      iex> [1, 2, 3] |> list_insert_many_at(0, stream)
      [4, 5, 6, 1, 2, 3]

      iex> [1, 2, 3] |> list_insert_many_at(3, 42)
      [1, 2, 3, 42]

      iex> [1, 2, 3] |> list_insert_many_at(:ante, [4, 5, 6])
      [4, 5, 6, 1, 2, 3]

      iex> [1, 2, 3] |> list_insert_many_at(:post, [4, 5, 6])
      [1, 2, 3, 4, 5, 6]

      iex> [:a, :b, :c] |> list_insert_many_at(:b, 42)
      [:a, 42, :b, :c]

      iex> stream = [4, 5, 6] |> Stream.map(&(&1))
      iex> [:a, :b, :c] |> list_insert_many_at(:c, stream)
      [:a, :b, 4, 5, 6, :c]

      iex> stream = [4, 5, 6] |> Stream.map(&(&1))
      iex> [a: 1, b: 2, c: 3] |> list_insert_many_at({:b, 2}, stream)
      [{:a, 1}, 4, 5, 6, {:b, 2}, {:c, 3}]

      iex> stream = [d: 4, e: 5, f: 6] |> Stream.map(&(&1))
      iex> [a: 1, b: 2, c: 3] |> list_insert_many_at({:b, 2}, stream)
      [{:a, 1}, {:d, 4}, {:e, 5}, {:f, 6}, {:b, 2}, {:c, 3}]
  """

  @type list_insert_many_at_index_spec ::
  :post |
  :ante |
  integer |
  nil |
  any

  @spec list_insert_many_at(list, list_insert_many_at_index_spec, any) :: list

  # header
  def list_insert_many_at(base_list, index_spec \\ nil, values)

  def list_insert_many_at(base_list, nil, values) when is_list(base_list) do
    base_list ++ list_verb_many_at_resolve_new_values(values)
  end

  def list_insert_many_at(base_list, :post, values) do
    base_list ++ list_verb_many_at_resolve_new_values(values)
  end

  def list_insert_many_at(base_list, :ante, values) do
    list_verb_many_at_resolve_new_values(values) ++ base_list
  end

  def list_insert_many_at(base_list, index_spec, values) when is_list(base_list)  do

    # resolve the index
    {base_ndx, _} = :insert |> list_verb_many_at_resolve_index_and_count!(base_list, index_spec)

    # split the base_list at the index
    {ante_list, post_list} = base_list |> Enum.split(base_ndx)

    # 'insert' the new one(s) between the ante and post lists
    ante_list ++ list_verb_many_at_resolve_new_values(values) ++ post_list

  end

  @doc ~S"""
  Returns a list with the `value(s)` deleted starting from the specified `index` and continuing for the specified `count`.

  Similar to `List.delete_at/2` but can delete multiple, consecutive values.

  Supports the same zero-based (`Integer`) index values as `List.delete_at/2`.

  ## Examples

      iex> [1, 2, 3] |> list_delete_many_at(2, 1)
      [1, 2]

      iex> [1, 2, 3] |> list_delete_many_at(1)
      [1, 3]

      iex> [1, 2, 3] |> list_delete_many_at(3, 999)
      [1, 2, 3]

      iex> [1, 2, 3] |> list_delete_many_at(-2, 2)
      [1]

      iex> [:a, :b, :c] |> list_delete_many_at(:b, 2)
      [:a]

      iex> [:a, :b, :c] |> list_delete_many_at(:c, 999)
      [:a, :b]

      iex> [a: 1, b: 2, c: 3] |> list_delete_many_at({:b, 2}, 2)
      [a: 1]
  """

  @type list_delete_many_at_index_spec :: integer | any

  @type list_delete_many_at_index_count :: non_neg_integer

  @spec list_delete_many_at(list, list_delete_many_at_index_spec, list_delete_many_at_index_count) :: list

  # header
  def list_delete_many_at(base_list, index, count \\ 1)

  def list_delete_many_at(base_list, index, count) when is_list(base_list) do

    # resolve the index and length / count
    {base_ndx, base_len} = :delete |> list_verb_many_at_resolve_index_and_count!(base_list, {index,count})

    case base_ndx do

      # if index is -ve and before start of base_list, do nothing
      # i.e same semantics as e.g. List.delete_at
      x when x < 0 and abs(x) > length(base_list) -> base_list

      _ ->

        case base_len do

          # nothing to delete => nothing to do
          0 -> base_list

          _ ->

          # split the base_list
          {ante_base_list, post_base_list} = base_list |> Enum.split(base_ndx)

            # now drop from the front of the post base_list and reconstitute base_list
            ante_base_list ++ Enum.drop(post_base_list, base_len)

        end

    end

  end

  @doc ~S"""
  Returns a list with the `value(s)` deleted, starting from the specified `index` and continuing for the specified `count`.

  Similar to `List.replace_at/3` but can replace multiple, consecutive
  values with one or more (ie. an enumerable) values.

  Supports the same zero-based (`Integer`) index values as `List.replace_at/3`.

  ## Examples

      iex> [1, 2, 3] |> list_replace_many_at(2, 1, 42)
      [1, 2, 42]

      iex> [1, 2, 3] |> list_replace_many_at(0, 2, [4, 5, 6])
      [4, 5, 6, 3]

      iex> [a: 1, b: 2, c: 3] |> list_replace_many_at({:b, 2}, 2, [x: 10, y: 11, z: 12])
      [a: 1, x: 10, y: 11, z: 12]

      iex> stream = [x: 10, y: 11, z: 12] |> Stream.map(&(&1))
      iex> [a: 1, b: 2, c: 3] |> list_replace_many_at({:b, 2}, 2, stream)
      [a: 1, x: 10, y: 11, z: 12]
  """

  @type list_replace_many_at_index_spec :: integer | any

  @type list_replace_many_at_index_count :: non_neg_integer

  @spec list_replace_many_at(list, list_replace_many_at_index_spec, list_replace_many_at_index_count, any) :: list

  # header
  def list_replace_many_at(base_list, index, count \\ 1, values)

  def list_replace_many_at(base_list, index, count, values)
  when is_list(base_list) do

    # resolve the index and length / count
    {base_ndx, base_len} = :replace |> list_verb_many_at_resolve_index_and_count!(base_list, {index, count})

    base_list
    |> list_delete_many_at(base_ndx, base_len)
    |> list_insert_many_at(base_ndx, values)

  end

end

