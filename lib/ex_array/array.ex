defmodule ExArray.Array do
  defstruct length: 0, contents: %{}

  @moduledoc """
  An `ExArray.Array` is a data structure that contains a collection of elements. 

  Elements are stored in a Map with their index as the key. This allows for fast 
  random access to elements by index, but slower insertion and deletion operations, 
  unless the element is being added or deleted to the end of the `Array`.
  """

  @type t :: %__MODULE__{
          length: non_neg_integer,
          contents: map
        }

  # Public API #

  # Construction Operations #

  @doc """
  Creates an `ExArray.Array` with a length of zero, containing no elements. 

  ## Examples

      iex> ExArray.Array.new()
      %ExArray.Array{length: 0, contents: %{}}
  """
  @spec new() :: t
  def new do
    %ExArray.Array{}
  end

  @doc """
  Creates an `ExArray.Array` with the given list of elements.

  ## Examples

      iex> ExArray.Array.new([1, 2, 3])
      %ExArray.Array{length: 3, contents: %{0 => 1, 1 => 2, 2 => 3}}
  """
  @spec new(list(any())) :: t
  def new(list) when is_list(list) do
    Enum.reduce(list, new(), fn element, acc -> add(acc, element) end)
  end

  # Add Operations #

  @doc """
  Adds the given element to the end of the Array

  ## Examples

      iex> ExArray.Array.new([1, 2, 3]) |> ExArray.Array.add(4)
      %ExArray.Array{length: 4, contents: %{0 => 1, 1 => 2, 2 => 3, 3 => 4}}
  """
  @spec add(t, any()) :: t
  def add(%__MODULE__{} = array, element) do
    add_element_at(array, element, array.length)
  end

  def add_at!(%__MODULE__{} = array, index, element) when index == array.length do
    add(array, element)
  end

  @doc """
  Adds the given element to the Array at the given index. 

  If the given index is greater than the length of the Array,
  an `ArgumentError` is raised. If the given index is negative, it will be evaluated
  as an offset from the end of the Array.

  If an element currently exists at the given index, it, and all following 
  elements, are shifted right.t()

  ## Examples

      iex> ExArray.Array.new([1, 2, 3]) |> ExArray.Array.add_at!(1, 4)
      %ExArray.Array{length: 4, contents: %{0 => 1, 1 => 4, 2 => 2, 3 => 3}}

      iex> ExArray.Array.new([1, 2, 3]) |> ExArray.Array.add_at!(-2, 4)
      %ExArray.Array{length: 4, contents: %{0 => 1, 1 => 4, 2 => 2, 3 => 3}}

      iex> ExArray.Array.new([1, 2, 3]) |> ExArray.Array.add_at!(4, 4)
      ** (ArgumentError) Index 4 is out of bounds for length 3
  """
  @spec add_at!(t, integer(), any()) :: t
  def add_at!(%__MODULE__{} = array, index, element) when is_integer(index) do
    case add_at(array, index, element) do
      {:ok, array} -> array
      {:error, :out_of_bounds} -> raise_out_of_bounds(index, array.length)
    end
  end

  def add_at(%__MODULE__{} = array, index, element) when index == array.length do
    {:ok, add(array, element)}
  end

  @doc """
  Adds the given element to the Array at the given index.

  If the given index is greater than the length of the Array,
  an {:error, :out_of_bounds} tuple is returned. If the given index is negative, 
  it will be evaluated as an offset from the end of the Array.

  If an element currently exists at the given index, it, and all following
  elements, are shifted right. 

  ## Examples

      iex> ExArray.Array.new([1, 2, 3]) |> ExArray.Array.add_at(1, 4)
      {:ok, %ExArray.Array{length: 4, contents: %{0 => 1, 1 => 4, 2 => 2, 3 => 3}}}

      iex> ExArray.Array.new([1, 2, 3]) |> ExArray.Array.add_at(-2, 4)
      {:ok, %ExArray.Array{length: 4, contents: %{0 => 1, 1 => 4, 2 => 2, 3 => 3}}}

      iex> ExArray.Array.new([1, 2, 3]) |> ExArray.Array.add_at(4, 4)
      {:error, :out_of_bounds}
  """
  @spec add_at(t, integer(), any()) :: {:ok, t} | {:error, :out_of_bounds}
  def add_at(%__MODULE__{} = array, index, element) when is_integer(index) do
    index_safe_operation(array, index, fn i -> add_element_at(array, element, i) end)
  end

  # Retrieval Operations #

  @doc """
  Returns `{:ok, element}` if the given index is within the bounds of the Array, 
  otherwise returns `{:error, :out_of_bounds}`.

  If the given index is negative, it will be evaluated as an offset from the end of the Array.

  ## Examples

      iex> ExArray.Array.new([1, 2, 3]) |> ExArray.Array.get(1)
      {:ok, 2}

      iex> ExArray.Array.new([1, 2, 3]) |> ExArray.Array.get(-1)
      {:ok, 3}

      iex> ExArray.Array.new([1, 2, 3]) |> ExArray.Array.get(4)
      {:error, :out_of_bounds}
  """
  @spec get(t, integer()) :: {:ok, any()} | {:error, :out_of_bounds}
  def get(%__MODULE__{} = array, index) when is_integer(index) do
    index_safe_operation(array, index, fn i -> Map.get(array.contents, i) end)
  end

  @doc """
  Returns the element at the given index if it exists, otherwise raises an `ArgumentError`

  If the given index is negative, it will be evaluated as an offset from the end of the Array.

  ## Examples

      iex> ExArray.Array.new([1, 2, 3]) |> ExArray.Array.get!(1)
      2

      iex> ExArray.Array.new([1, 2, 3]) |> ExArray.Array.get!(-1)
      3

      iex> ExArray.Array.new([1, 2, 3]) |> ExArray.Array.get!(4)
      ** (ArgumentError) Index 4 is out of bounds for length 3
  """
  @spec get!(t, integer()) :: any()
  def get!(%__MODULE__{} = array, index) when is_integer(index) do
    case get(array, index) do
      {:ok, element} -> element
      {:error, :out_of_bounds} -> raise_out_of_bounds(index, array.length)
    end
  end

  @doc """
  Sets the element at the given index to the given element. 

  If the given index is negative, it will be evaluated as an offset from the end of the Array.
  The element must exist and the index must be in bounds, otherwise returns `{:error, :out_of_bounds}`

  ## Examples

      iex> ExArray.Array.new([1, 2, 3]) |> ExArray.Array.set(1, 4)
      {:ok, %ExArray.Array{length: 3, contents: %{0 => 1, 1 => 4, 2 => 3}}}

      iex> ExArray.Array.new([1, 2, 3]) |> ExArray.Array.set(-1, 4)
      {:ok, %ExArray.Array{length: 3, contents: %{0 => 1, 1 => 2, 2 => 4}}}

      iex> ExArray.Array.new([1, 2, 3]) |> ExArray.Array.set(4, 4)
      {:error, :out_of_bounds}
  """
  @spec set(t, integer(), any()) :: {:ok, t} | {:error, :out_of_bounds}
  def set(%__MODULE__{} = array, index, element) do
    index_safe_operation(array, index, fn i -> replace_element_at(array, i, element) end)
  end

  @doc """
  Sets the element at the given index to the given element.

  If the given index is negative, it will be evaluated as an offset from the end of the Array.
  The element must exist and the index must be in bounds, otherwise raises an `ArgumentError`

  ## Examples

      iex> ExArray.Array.new([1, 2, 3]) |> ExArray.Array.set!(1, 4)
      %ExArray.Array{length: 3, contents: %{0 => 1, 1 => 4, 2 => 3}}

      iex> ExArray.Array.new([1, 2, 3]) |> ExArray.Array.set!(-1, 4)
      %ExArray.Array{length: 3, contents: %{0 => 1, 1 => 2, 2 => 4}}

      iex> ExArray.Array.new([1, 2, 3]) |> ExArray.Array.set!(4, 4)
      ** (ArgumentError) Index 4 is out of bounds for length 3

  """
  @spec set!(t, integer(), any()) :: t
  def set!(%__MODULE__{} = array, index, element) when is_integer(index) do
    case set(array, index, element) do
      {:ok, array} -> array
      {:error, :out_of_bounds} -> raise_out_of_bounds(index, array.length)
    end
  end

  # Removal Operations #

  @doc """
  Removes the last element from the Array and returns the resulting Array. 

  If the array is empty, the original Array is returned. 

  ## Examples

      iex> ExArray.Array.new([1, 2, 3]) |> ExArray.Array.remove()
      %ExArray.Array{length: 2, contents: %{0 => 1, 1 => 2}}

      iex> ExArray.Array.new([]) |> ExArray.Array.remove()
      %ExArray.Array{length: 0, contents: %{}}

  """
  @spec remove(t) :: t
  def remove(%__MODULE__{} = array) when array.length == 0 do
    array
  end

  def remove(%__MODULE__{} = array) do
    {:ok, arr} = remove_at(array, array.length - 1)
    arr
  end

  @doc """
  Removes the element at the given index from the Array and returns the resulting Array. 

  If the given index is invalid, an {:error, :out_of_bounds} tuple is returned. If the given index is negative,
  it will be evaluated as an offset from the end of the Array. 

  ## Examples

      iex> ExArray.Array.new([1, 2, 3]) |> ExArray.Array.remove_at(1)
      {:ok, %ExArray.Array{length: 2, contents: %{0 => 1, 1 => 3}}}

      iex> ExArray.Array.new([1, 2, 3]) |> ExArray.Array.remove_at(-1)
      {:ok, %ExArray.Array{length: 2, contents: %{0 => 1, 1 => 2}}}

      iex> ExArray.Array.new([1, 2, 3]) |> ExArray.Array.remove_at(4)
      {:error, :out_of_bounds}
  """
  @spec remove_at(t, integer()) :: {:ok, t} | {:error, :out_of_bounds}
  def remove_at(%__MODULE__{} = array, index) when index == array.length - 1 do
    {:ok, remove_element_at(array, index)}
  end

  def remove_at(%__MODULE__{} = array, index) when is_integer(index) do
    index_safe_operation(array, index, fn i -> remove_element_at(array, i) end)
  end

  @doc """
  Removes the element at the given index from the Array and returns the resulting Array. 

  If the given index is invalid, an `ArgumentError` is raised. If the given index is negative,
  it will be evaluated as an offset from the end of the Array. 

  ## Examples

      iex> ExArray.Array.new([1, 2, 3]) |> ExArray.Array.remove_at!(1)
      %ExArray.Array{length: 2, contents: %{0 => 1, 1 => 3}}

      iex> ExArray.Array.new([1, 2, 3]) |> ExArray.Array.remove_at!(-1)
      %ExArray.Array{length: 2, contents: %{0 => 1, 1 => 2}}

      iex> ExArray.Array.new([1, 2, 3]) |> ExArray.Array.remove_at!(4)
      ** (ArgumentError) Index 4 is out of bounds for length 3
  """
  @spec remove_at!(t, integer()) :: t
  def remove_at!(%__MODULE__{} = array, index) do
    case remove_at(array, index) do
      {:ok, array} -> array
      {:error, :out_of_bounds} -> raise_out_of_bounds(index, array.length)
    end
  end

  # Transformation Operations # 

  @doc """
  Returns a `List` of all the elements in the Array. Ordering is retained.

  ## Examples

      iex> ExArray.Array.new([1, 2, 3]) |> ExArray.Array.to_list()
      [1, 2, 3]
  """
  @spec to_list(t) :: list(any())
  def to_list(%__MODULE__{length: length, contents: contents}) do
    for i <- 0..(length - 1), into: [], do: Map.get(contents, i)
  end

  # Protocol Implementations #

  defimpl Enumerable, for: __MODULE__ do
    alias ExArray.Array

    def count(%Array{length: length}) do
      {:ok, length}
    end

    def member?(_a, _b), do: {:error, __MODULE__}

    def slice(%Array{} = arr) do
      {:ok, arr.length, fn start, length, step -> do_slice(start, length, step, arr) end}
    end

    def reduce(%Array{} = arr, acc, fun) do
      do_reduce(arr, acc, fun, 0)
    end

    defp do_reduce(arr, {_term, val}, _fun, index) when index == arr.length do
      {:done, val}
    end

    defp do_reduce(arr, {:cont, acc}, fun, index) do
      do_reduce(arr, fun.(Map.get(arr.contents, index), acc), fun, index + 1)
    end

    defp do_reduce(_arr, {:halt, acc}, _fun, _index) do
      {:halted, acc}
    end

    defp do_reduce(arr, {:suspend, acc}, fun, index) do
      {:suspended, acc, &do_reduce(arr, &1, fun, index)}
    end

    defp do_slice(start, length, step, arr) do
      last_index = start + (length - 1) * step
      do_slice_helper(last_index, length, step, 0, arr, [])
    end

    defp do_slice_helper(_position, amount, _step, current, _arr, acc) when current == amount do
      acc
    end

    defp do_slice_helper(position, amount, step, current, arr, acc) do
      do_slice_helper(position - step, amount, step, current + 1, arr, [
        Map.get(arr.contents, position) | acc
      ])
    end
  end

  defimpl Collectable, for: __MODULE__ do
    alias ExArray.Array

    def into(%Array{} = arr) do
      collector_fun = fn
        acc, {:cont, element} -> Array.add(acc, element)
        acc, :done -> acc
        _acc, :halt -> :halted
      end

      {arr, collector_fun}
    end
  end

  # Private API #

  # Adding to the end of the array
  defp add_element_at(arr, element, index) when index == arr.length do
    %__MODULE__{length: arr.length + 1, contents: Map.put(arr.contents, index, element)}
  end

  # Adding to any spot but the end of the array, requires re-indexing
  @spec add_element_at(t(), any(), integer()) :: t()
  defp add_element_at(arr, element, index) do
    shifted_contents = shift_map_keys_after(arr.contents, index, &increment_one/1)
    %__MODULE__{length: arr.length + 1, contents: Map.put(shifted_contents, index, element)}
  end

  # Removing the last element of the array
  defp remove_element_at(arr, index) when index == arr.length - 1 do
    {_element, with_removed_element} = Map.pop!(arr.contents, index)

    %__MODULE__{length: arr.length - 1, contents: with_removed_element}
  end

  # Removing any element but the last element of the array, requires re-indexing
  @spec remove_element_at(t(), integer()) :: t()
  defp remove_element_at(arr, index) do
    {_element, with_removed_element} = Map.pop!(arr.contents, index)

    %__MODULE__{
      length: arr.length - 1,
      contents: shift_map_keys_after(with_removed_element, index, &decrement_one/1)
    }
  end

  # Replacing an element doesn't change the length
  @spec replace_element_at(t(), integer(), any()) :: t()
  defp replace_element_at(arr, index, element) do
    %__MODULE__{arr | contents: Map.put(arr.contents, index, element)}
  end

  # Returns {:ok, result} if the index is within the bounds of the array, 
  # after evaluating the given operation function,
  # otherwise returns {:error, :out_of_bounds}
  @spec index_safe_operation(t(), integer(), (integer() -> any())) ::
          {:ok, any()} | {:error, :out_of_bounds}
  defp index_safe_operation(array, index, operation) do
    index = if index < 0, do: array.length + index, else: index

    case index < 0 or index >= array.length do
      true -> {:error, :out_of_bounds}
      false -> {:ok, operation.(index)}
    end
  end

  @spec raise_out_of_bounds(integer(), integer()) :: no_return()
  defp raise_out_of_bounds(index, length) do
    raise(ArgumentError, "Index #{index} is out of bounds for length #{length}")
  end

  # Ideally we could only shift the keys that are after the index we are adding to
  # Look into when it becomes more efficient to shift vs. creating a new map
  @spec shift_map_keys_after(map, integer(), (integer() -> integer())) :: map()
  defp shift_map_keys_after(map, index_after, mapping_fun) do
    Map.new(map, fn
      {k, v} when k < index_after -> {k, v}
      {k, v} -> {mapping_fun.(k), v}
    end)
  end

  defp increment_one(x), do: x + 1

  defp decrement_one(x), do: x - 1
end
