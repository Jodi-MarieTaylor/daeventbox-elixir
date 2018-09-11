defmodule Paginate do
  import Ecto.Query
  alias Daeventbox.Repo

  @doc """
  Paginate.query
  paginates query based on number of rows

  ## Examples
      iex> number_of_rows = 2
      2
      iex> Paginate.query(ecto_query, number_of_rows)
      [%{id: 1, name: "Jodi Taylor", type: "THICC AF"}, %{id: 2, name: "Fitz", kind: "PRO Developer"}]

  """
  def query(pre_query, num_rows) do
    records =
      pre_query
      |> order_by(desc: :id)
      |> limit(^num_rows)
      |> Repo.all
  end

  @doc """
  Paginate.query
  paginates query based on number of rows

  ## Examples
      iex> number_of_rows = 2
      2
      iex> page = 5
      5
      iex> Paginate.query(ecto_query, number_of_rows, page)
      [%{id: 10, name: "Tamara", type: "Statament Jodi Approves Of"},%{id: 11, name: "Jesse", kind: "The Jacket"}]

  """
  def query(pre_query, number_of_rows, page) when not is_nil(page) do
    with {:ok, page_num} <- integer_parse(page),
        {:ok, num_rows} <- integer_parse(number_of_rows)
     do
       offset = (page_num - 1) * num_rows
       records =
         pre_query
         |> offset(^offset)
         |> order_by(desc: :id)
         |> limit(^num_rows)
         |> Repo.all
     else
       _ ->
        query(pre_query, number_of_rows)
     end
  end

  def integer_parse(var) when is_integer(var) do
    {:ok, var}
  end

  def integer_parse(var) when is_bitstring(var) do
    case Integer.parse(var) do
      {:error, reason} ->
          {:error, reason}
      {int, string} ->
          {:ok, int}
    end
  end

end
