ExUnit.start()

defmodule PlymioListBootstrapTest do

  use ExUnit.Case, async: true

  def helper_list_to_keyword(value)  do
    value
    |> Enum.chunk(2)
    |> Enum.map(fn [k,v] -> {k,v} end)
    |> Keyword.new
  end

  defmacro __using__(_opts \\ []) do
    quote do
      import PlymioListBootstrapTest
    end
  end

end

defmodule PlymioListAttributesTest do

  use PlymioListBootstrapTest

  defmacro __using__(_opts \\ []) do

    quote do

      @l_test1 [:a, 1, :b, 2, :c, 3]
      @l_test1a [:a, 9, :b, 10, :c, 11]
      @l_test2 [:x, 10, :y, 11, :z, 12]
      @l_test3 ["p", 100, %{q: 1}, 101, :r, 102]

      @k_test1 helper_list_to_keyword(@l_test1)

      @k_test1a helper_list_to_keyword(@l_test1a)

      @k_test2 helper_list_to_keyword(@l_test2)

      @l2t_edit_test1 [:wrap, :x, [:x_ante1, :x_post1]]

      @list_alphabet_a_z ?a .. ?z |> Enum.map(fn x -> << x :: utf8 >> end) |> Enum.map(&String.to_atom/1)

      @list_alphabet_a_z_tuples Enum.zip(@list_alphabet_a_z, 1 .. 26)

    end

  end

end

defmodule PlymioListHelpersTest do

  use ExUnit.Case, async: true

  alias Plymio.List.Utils, as: PLU

  use PlymioListAttributesTest

  def helper_assert_list_to_2tuples(result, enum) do
    assert result == PLU.list_to_2tuples(enum)
  end

  defmacro __using__(_opts \\ []) do

    quote do
      use ExUnit.Case, async: true
      alias Plymio.List.Utils, as: PLU
      use PlymioListBootstrapTest
      use PlymioListAttributesTest
      import PlymioListHelpersTest
    end

  end

end
