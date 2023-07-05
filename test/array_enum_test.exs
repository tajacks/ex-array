defmodule ExArray.ArrayEnumTest do
  use ExUnit.Case

  alias ExArray.Array

  @test_array 0..9 |> Enum.to_list() |> Array.new()

  test "can count" do
    assert Enum.count(Array.new()) == 0
    assert Enum.count(@test_array) == 10
  end

  test "can test membership" do
    assert Enum.member?(@test_array, 2)
    refute Enum.member?(@test_array, 10)
  end

  test "can slice" do
    assert Enum.slice(@test_array, 0, 3) == [0, 1, 2]
    assert Enum.slice(@test_array, 3, 3) == [3, 4, 5]
    assert Enum.slice(@test_array, 9, 10) == [9]
    assert Enum.slice(@test_array, 0..3) == [0, 1, 2, 3]
    assert Enum.slice(@test_array, 0..5//2) == [0, 2, 4]
  end

  test "can reduce" do
    assert Enum.reduce(@test_array, 0, &(&1 + &2)) == 45
    assert Enum.reduce(@test_array, 0, fn x, acc -> x + acc end) == 45
  end

  test "can filter" do
    assert Enum.filter(@test_array, fn x -> rem(x, 2) == 0 end) == [0, 2, 4, 6, 8]
  end

  test "can take while" do
    assert Enum.take_while(@test_array, fn x -> x < 5 end) == [0, 1, 2, 3, 4]
  end

  test "can get at" do
    assert Enum.at(@test_array, 3) == 3
    assert Enum.at(@test_array, 10) == nil
  end

  test "can insert into collectable" do
    assert Enum.into([1, 2, 3], Array.new()) == %Array{
             length: 3,
             contents: %{0 => 1, 1 => 2, 2 => 3}
           }
  end
end
