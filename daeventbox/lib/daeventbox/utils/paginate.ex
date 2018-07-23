defmodule Paginate do
  import Ecto.Query
  alias Daeventbox.Repo

  def query(pre_query, num_rows) do
    records =
      pre_query
      |> order_by(desc: :id)
      |> limit(^num_rows)
      |> Repo.all
  end

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
