defmodule ExArray.ArrayTest do
  use ExUnit.Case, async: true

  doctest ExArray.Array, import: true

  alias ExArray.Array

  @test_array Array.new(["1", "2", "3"])

  test "can make new empty array" do
    assert Array.new() == %Array{}
    assert Array.new().length == 0
    assert Array.new().contents == %{}
  end

  test "can make array from list" do
    assert Array.new(["test", "test2"]) == %Array{
             length: 2,
             contents: %{0 => "test", 1 => "test2"}
           }
  end

  test "can add element to end of an array" do
    assert Array.add(@test_array, "4") == %Array{
             length: 4,
             contents: %{0 => "1", 1 => "2", 2 => "3", 3 => "4"}
           }

    assert Array.add_at!(@test_array, 3, "4") == %Array{
             length: 4,
             contents: %{0 => "1", 1 => "2", 2 => "3", 3 => "4"}
           }

    assert Array.add_at(@test_array, 3, "4") ==
             {:ok, %Array{length: 4, contents: %{0 => "1", 1 => "2", 2 => "3", 3 => "4"}}}
  end

  test "can add element to middle of an array" do
    expected = %Array{length: 4, contents: %{0 => "1", 1 => "4", 2 => "2", 3 => "3"}}
    assert {:ok, ^expected} = Array.add_at(@test_array, 1, "4")
    assert {:ok, ^expected} = Array.add_at(@test_array, -2, "4")
    assert ^expected = Array.add_at!(@test_array, 1, "4")
    assert ^expected = Array.add_at!(@test_array, -2, "4")
  end

  test "adding element outside size fails" do
    assert {:error, :out_of_bounds} = Array.add_at(@test_array, 4, "4")
    assert {:error, :out_of_bounds} = Array.add_at(@test_array, -5, "4")

    assert_raise ArgumentError, fn ->
      Array.add_at!(@test_array, 4, "4")
    end

    assert_raise ArgumentError, fn ->
      Array.add_at!(@test_array, -5, "4")
    end
  end

  test "can get element within array" do
    assert {:ok, "1"} = Array.get(@test_array, 0)
    assert {:ok, "2"} = Array.get(@test_array, 1)
    assert {:ok, "3"} = Array.get(@test_array, 2)
    assert {:ok, "3"} = Array.get(@test_array, -1)
    assert {:ok, "2"} = Array.get(@test_array, -2)
    assert {:ok, "1"} = Array.get(@test_array, -3)

    assert "1" == Array.get!(@test_array, 0)
    assert "2" == Array.get!(@test_array, 1)
    assert "3" == Array.get!(@test_array, 2)
    assert "3" == Array.get!(@test_array, -1)
    assert "2" == Array.get!(@test_array, -2)
    assert "1" == Array.get!(@test_array, -3)
  end

  test "getting element outside size fails" do
    assert {:error, :out_of_bounds} = Array.get(@test_array, 3)
    assert {:error, :out_of_bounds} = Array.get(@test_array, -4)

    assert_raise ArgumentError, fn ->
      Array.get!(@test_array, 3)
    end

    assert_raise ArgumentError, fn ->
      Array.get!(@test_array, -4)
    end
  end

  test "can remove elements from the end of the array" do
    assert %Array{length: 2, contents: %{0 => "1", 1 => "2"}} = Array.remove(@test_array)
    assert %Array{length: 0, contents: %{}} = Array.remove(Array.new())
    assert %Array{length: 2, contents: %{0 => "1", 1 => "2"}} = Array.remove_at!(@test_array, 2)

    assert {:ok, %Array{length: 2, contents: %{0 => "1", 1 => "2"}}} =
             Array.remove_at(@test_array, 2)
  end

  test "can remove elements from the middle of the array" do
    assert {:ok, %Array{length: 2, contents: %{0 => "1", 1 => "3"}}} =
             Array.remove_at(@test_array, 1)

    assert {:ok, %Array{length: 2, contents: %{0 => "1", 1 => "3"}}} =
             Array.remove_at(@test_array, -2)

    assert %Array{length: 2, contents: %{0 => "1", 1 => "3"}} = Array.remove_at!(@test_array, 1)
    assert %Array{length: 2, contents: %{0 => "1", 1 => "3"}} = Array.remove_at!(@test_array, -2)
  end

  test "removing elements outside size fails" do
    assert {:error, :out_of_bounds} = Array.remove_at(@test_array, 3)
    assert {:error, :out_of_bounds} = Array.remove_at(@test_array, -4)

    assert_raise ArgumentError, fn ->
      Array.remove_at!(@test_array, 3)
    end

    assert_raise ArgumentError, fn ->
      Array.remove_at!(@test_array, -4)
    end
  end

  test "can convert to list" do
    assert ["1", "2", "3"] == Array.to_list(@test_array)
  end
end
