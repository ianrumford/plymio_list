defmodule ListsUtils1Test1 do

  use PlymioListHelpersTest

  test "list_2lists?: true" do

    assert PLU.list_2lists?([[1,1]])
    assert PLU.list_2lists?([[1,1], [2, 2], [3, 3]])

  end

  test "list_2lists?: false" do

    refute PLU.list_2lists?(nil)
    refute PLU.list_2lists?(42)
    refute PLU.list_2lists?(:atom)
    refute PLU.list_2lists?("string")

    refute PLU.list_2lists?([1,2,3])
    refute PLU.list_2lists?([[1,1], [2, 2], 3])
    refute PLU.list_2lists?([{1,1}])

  end

  test "list_to_keyword!: simple" do
    assert PLU.list_to_keyword!(@l_test1) == @k_test1
  end

  test "list_to_keyword!: error" do

    assert_raise(FunctionClauseError, fn ->  PLU.list_to_keyword!([42]) end)
    assert_raise(FunctionClauseError, fn ->  PLU.list_to_keyword!([:a, 1, :b]) end)

    assert_raise(FunctionClauseError, fn ->  PLU.list_to_keyword!(["a", 1, :b, 2]) end)

    assert_raise(FunctionClauseError, fn ->  PLU.list_to_keyword!(42) end)
    assert_raise(FunctionClauseError, fn ->  PLU.list_to_keyword!(:x) end)
    assert_raise(FunctionClauseError, fn ->  PLU.list_to_keyword!("x") end)

  end

  test "list_flat_just: single" do
    assert PLU.list_flat_just(@l_test1) == @l_test1
    assert PLU.list_flat_just(@l_test2) == @l_test2
    assert PLU.list_flat_just(@l_test3) == @l_test3
  end

  test "list_flat_just: multi" do

    assert PLU.list_flat_just([@l_test1, @l_test2, @l_test3]) == @l_test1 ++ @l_test2 ++ @l_test3

    assert PLU.list_flat_just([@l_test3, nil, nil, nil, @l_test2, nil, nil, @l_test1]) == @l_test3 ++ @l_test2 ++ @l_test1

  end

  test "list_flat_just: deep" do

    assert PLU.list_flat_just([@l_test3, [@l_test2, @l_test1]]) == @l_test3 ++ @l_test2 ++ @l_test1

    assert PLU.list_flat_just([[@l_test3, @l_test3], [@l_test2, @l_test1]]) == @l_test3 ++ @l_test3 ++ @l_test2 ++ @l_test1

  end

 test "list_wrap_flat_just: unit" do
    assert PLU.list_wrap_flat_just(42) == [42]
    assert PLU.list_wrap_flat_just(:x) == [:x]
    assert PLU.list_wrap_flat_just("x") == ["x"]
  end

  test "list_wrap_flat_just: single" do
    assert PLU.list_wrap_flat_just(@l_test1) == @l_test1
    assert PLU.list_wrap_flat_just(@l_test2) == @l_test2
    assert PLU.list_wrap_flat_just(@l_test3) == @l_test3
  end

  test "list_wrap_flat_just: multi" do
    assert PLU.list_wrap_flat_just([@l_test1, @l_test2, @l_test3]) == @l_test1 ++ @l_test2 ++ @l_test3

    assert PLU.list_wrap_flat_just([@l_test3, nil, nil, nil, @l_test2, nil, nil, @l_test1]) == @l_test3 ++ @l_test2 ++ @l_test1

  end

  test "list_wrap_flat_just: deep" do

    assert PLU.list_wrap_flat_just([@l_test3, [@l_test2, @l_test1]]) == @l_test3 ++ @l_test2 ++ @l_test1

    assert PLU.list_wrap_flat_just([[@l_test3, @l_test3], [@l_test2, @l_test1]]) == @l_test3 ++ @l_test3 ++ @l_test2 ++ @l_test1

  end

  test "list_to_2tuples: simple" do
    helper_assert_list_to_2tuples(@k_test1, @l_test1)
    helper_assert_list_to_2tuples(@k_test2, @l_test2)
    helper_assert_list_to_2tuples([{"a", 1}, {:b, 2}], ["a", 1, :b, 2])
  end

  test "list_to_2tuples: error" do

    assert_raise(FunctionClauseError, fn ->  PLU.list_to_2tuples([42]) end)
    assert_raise(FunctionClauseError, fn ->  PLU.list_to_2tuples([:a, 1, :b]) end)
    assert_raise(FunctionClauseError, fn ->  PLU.list_to_2tuples(42) end)
    assert_raise(FunctionClauseError, fn ->  PLU.list_to_2tuples(:x) end)
    assert_raise(FunctionClauseError, fn ->  PLU.list_to_2tuples("x") end)

  end

  test "list_insert_many_at" do

    l1 = [:a, :b, :c]
    l2 = [1, 2, 3]

    # boundaries conditions
    assert l1 ++ l2 == PLU.list_insert_many_at(l1, nil, l2)
    assert l2 ++ l1 == PLU.list_insert_many_at(l1, 0, l2)

    assert l1 ++ l2 == PLU.list_insert_many_at(l1, 99999, l2)
    assert l2 ++ l1 == PLU.list_insert_many_at(l1, -99999, l2)

    assert l1 ++ l2 == PLU.list_insert_many_at(l1, 99999, l2)

    # regular in bounds
    assert [:a, :b, 1, 2, 3, :c] == PLU.list_insert_many_at(l1, -1, l2)
    assert [:a, 1, 2, 3, :b, :c] == PLU.list_insert_many_at(l1, 1, l2)
    assert [1, 2, 3, :a, :b, :c] == PLU.list_insert_many_at(l1, 0, l2)

    assert [:a, :b, 1, 2, 3, :c] == PLU.list_insert_many_at(l1, :c, l2)
    assert [:a, 1, 2, 3, :b, :c] == PLU.list_insert_many_at(l1, :b, l2)
    assert [1, 2, 3, :a, :b, :c] == PLU.list_insert_many_at(l1, :a, l2)

    # verb
    assert l1 ++ l2 == PLU.list_insert_many_at(l1, :post, l2)
    assert l2 ++ l1 == PLU.list_insert_many_at(l1, :ante, l2)

  end

  test "list_delete_many_at" do

    l3 = @list_alphabet_a_z_tuples

    assert l3 -- [a: 1]  == PLU.list_delete_many_at(l3, 0)
    assert l3 -- [b: 2]  == PLU.list_delete_many_at(l3, 1)
    assert l3 -- [z: 26]  == PLU.list_delete_many_at(l3, 25)
    assert l3  == PLU.list_delete_many_at(l3, 26)

    assert [a: 1]  == PLU.list_delete_many_at(l3, 1, 25)
    assert []  == PLU.list_delete_many_at(l3, 0, 26)
    assert []  == PLU.list_delete_many_at(l3, 0, 999)

    assert l3 -- [i: 9, j: 10, k: 11]  == PLU.list_delete_many_at(l3, 8, 3)

    assert l3 -- [z: 26]  == PLU.list_delete_many_at(l3, -1, 25)
    assert l3 -- [z: 26]  == PLU.list_delete_many_at(l3, -1, 26)
    assert l3 -- [v: 22, w: 23]  == PLU.list_delete_many_at(l3, -5, 2)

    # before the beginning of the list => no change to list
    assert l3  == PLU.list_delete_many_at(l3, -999, 0)
    assert l3  == PLU.list_delete_many_at(l3, -999, 1)
    assert l3  == PLU.list_delete_many_at(l3, -999, 999)

  end

  test "list_replace_many_at" do

    assert [{:a, :a1}, :b_repl1, {:b_repl21, :b_repl22}, {:c, :c3}, {:d, :d4}] ==
      PLU.list_replace_many_at(
        [a: :a1, b: :b2, c: :c3, d: :d4],
        1,
        [:b_repl1, {:b_repl21, :b_repl22}])

    assert [{:a, :a1}, :b_repl1, {:b_repl21, :b_repl22}, {:c, :c3}, {:d, :d4}] ==
      PLU.list_replace_many_at(
        [a: :a1, b: :b2, c: :c3, d: :d4],
        1, 1,
        [:b_repl1, {:b_repl21, :b_repl22}])

    assert [{:a, :a1}, :b_repl1, {:b_repl21, :b_repl22}, {:c, :c3}, {:d, :d4}] ==
      PLU.list_replace_many_at(
        [a: :a1, b: :b2, c: :c3, d: :d4],
        {:b, :b2}, 1,
        [:b_repl1, {:b_repl21, :b_repl22}])

    assert [{:a, :a1}, :b_repl1, {:b_repl21, :b_repl22}] ==
      PLU.list_replace_many_at(
        [a: :a1, b: :b2, c: :c3, d: :d4],
        {:b, :b2}, 999,
        [:b_repl1, {:b_repl21, :b_repl22}])

    assert [:b_repl1, {:b_repl21, :b_repl22}, {:a, :a1}, {:b, :b2}, {:c, :c3}, {:d, :d4}] ==
      PLU.list_replace_many_at(
        [a: :a1, b: :b2, c: :c3, d: :d4],
        -999, 1,
        [:b_repl1, {:b_repl21, :b_repl22}])

    assert_raise CaseClauseError, fn ->
      PLU.list_replace_many_at(
        [a: :a1, b: :b2, c: :c3, d: :d4],
        {:unknown, 999},
        [:b_repl1, {:b_repl21, :b_repl22}])
    end

  end

end
