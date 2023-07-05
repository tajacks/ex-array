# ExArray

`ExArray.Array` is a module that provides Array-ish functionality to Elixir.

The `ExArray.Array` structure is useful when fast random access, by index, is needed. It can be dynamically grown 
and shrunk by removing or adding elements from any position in the structure. 

When passing indexes to any function in the module, negative integers are supported. Negative integers are treated as 
an offset from the end of the structure. For example, if the structure contains 5 elements, the index `-1` will return 
the last element, `-2` will return the second to last element, and so on. If the negative index runs over the beginning
of the structure, the appropriate failure condition will occur, either raises or an error tuple, depending on the 
method being called. In the example with 5 elements, the index `-6` will result in an error, as there is no element 
before the first element. When a positive index is passed, the index is treated as an offset from the beginning and 
the appropriate failure condition will occur if the index runs over the end of the structure.

## Construction

`ExArray.Array` can be constructed in a number of ways. The most common is to use the `new/0` 
function to create an empty structure. Alternatively, you can use the `new/1` function to create a structure
containing the elements in the given list.

```elixir 
iex> ExArray.Array.new()
%ExArray.Array{length: 0, contents: %{}}

iex> ExArray.Array.new([1,2,3])
%ExArray.Array{length: 3, contents: %{0 => 1, 1 => 2, 2 => 3}}
```

## Accessing elements

Elements can be accessed by index using either the `get/2` or `get!/2` functions. The difference between these two 
functions is that `get!/2` will raise an error if the index is out of bounds, while `get/2` will return an error 
tuple. 

```elixir
iex> ExArray.Array.get(ExArray.Array.new([1, 2, 3]), 1)
{:ok, 2}

iex> ExArray.Array.get(ExArray.Array.new([1, 2, 3]), 3)
{:error, :out_of_bounds}

iex> ExArray.Array.get!(ExArray.Array.new([1, 2, 3]), 1)
2

iex> ExArray.Array.get!(ExArray.Array.new([1, 2, 3]), 3)
** (ArgumentError) Index 3 is out of bounds for length 3
```

## Adding Elements

Adding elements to the end of the structure is fast as no other elements need to be re-indexed. This is done using 
the `add/2` function. The `add/2` function returns a new structure with the element added to the end. 

This operation should always succeed

```elixir
iex> ExArray.Array.add(ExArray.Array.new([1, 2, 3]), 4)
%ExArray.Array{length: 4, contents: %{0 => 1, 1 => 2, 2 => 3, 3 => 4}}
```

Adding elements to the beginning or middle of the structure is slower as all elements after the index need to be 
re-indexed. This is done using `add_at/3` or `add_at!/3`. These functions return a new structure with the element added at the given index. If an element existed at the given index, it and all other elements after it will be shifted one to the right. 

```elixir 
iex> ExArray.Array.add_at(ExArray.Array.new([1, 2, 3]), 1, 4) 
{:ok, %ExArray.Array{length: 4, contents: %{0 => 1, 1 => 4, 2 => 2, 3 => 3}}}

iex> ExArray.Array.add_at(ExArray.Array.new([1, 2, 3]), 4, 4)
{:error, :out_of_bounds}

iex> ExArray.Array.add_at!(ExArray.Array.new([1, 2, 3]), 1, 4)
%ExArray.Array{length: 4, contents: %{0 => 1, 1 => 4, 2 => 2, 3 => 3}}

iex> ExArray.Array.add_at!(ExArray.Array.new([1, 2, 3]), 4, 4)
** (ArgumentError) Index 4 is out of bounds for length 3
```

## Removing Elements 

Removing elements from the end of the structure is fast as no other elements need to be re-indexed. This is done 
using the `remove/1` function. The `remove/1` function returns a new structure with the last element removed. 

If the `ExArray.Array` is empty, the `remove/1` function will return the original structure.

This operation should always succeed

```elixir 
iex> ExArray.Array.remove(ExArray.Array.new([1, 2, 3]))
%ExArray.Array{length: 2, contents: %{0 => 1, 1 => 2}}

iex> ExArray.Array.remove(ExArray.Array.new())
%ExArray.Array{length: 0, contents: %{}}
```

Removing elements from the beginning or middle of the structure is slower as all elements after the index need to be
re-indexed. This is done using `remove_at/2` or `remove_at!/2`. These functions return a new structure with the 
element at the given index removed. All elements after it will be shifted one to the left. 

```elixir
iex> ExArray.Array.remove_at(ExArray.Array.new([1, 2, 3]), 1)
{:ok, %ExArray.Array{length: 2, contents: %{0 => 1, 1 => 3}}}

iex> ExArray.Array.remove_at(ExArray.Array.new([1, 2, 3]), 4)
{:error, :out_of_bounds}

iex> ExArray.Array.remove_at!(ExArray.Array.new([1, 2, 3]), 1)
%ExArray.Array{length: 2, contents: %{0 => 1, 1 => 3}}

iex> ExArray.Array.remove_at!(ExArray.Array.new([1, 2, 3]), 4)
** (ArgumentError) Index 4 is out of bounds for length 3
```

## Collectable Operations 

`ExArray.Array` implements the `Collectable` protocol. This means that it can be used with `Enum.into` and `for` 
special forms

```elixir
iex> Enum.into([1, 2, 3], ExArray.Array.new())
%ExArray.Array{length: 3, contents: %{0 => 1, 1 => 2, 2 => 3}}

iex> for x <- [1, 2, 3], into: ExArray.Array.new(), do: x
%ExArray.Array{length: 3, contents: %{0 => 1, 1 => 2, 2 => 3}}
```

## Enum Operations

`ExArray.Array` implements the `Enumerable` protocol. This means that it can be used with the functions 
in the `Enum` module. 

```elixir 
iex> ExArray.Array.new([1, 2, 3]) |> Enum.map(&(&1 * 2))
[2, 4, 6]

iex> ExArray.Array.new([1, 2, 3]) |> Enum.reduce(&(&1 + &2))
6

iex> ExArray.Array.new([1, 2, 3]) |> Enum.filter(&(&1 > 1))
[2, 3]

iex> ExArray.Array.new([1, 2, 3]) |> Enum.at(1)
2
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_array` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_array, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_array>.

## Acknowledgements

Special thanks to the following individuals for providing feedback on public API design:

- [@llalon](https://github.com/llalon)
- [@rgmz](https://github.com/rgmz)