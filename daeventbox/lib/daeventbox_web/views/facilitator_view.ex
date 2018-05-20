defmodule DaeventboxWeb.FacilitatorView do
  use DaeventboxWeb, :view
  alias Elixlsx.{Workbook, Sheet}
  @header [
      "Name",
      "Email",
      "Date",
      "Type",
      "Quantity",
      "Total Paid"
    ]
  def render("report.html", %{items: items}) do
      IO.puts "IN REPORT"
      report_generator(items)
      |> Elixlsx.write_to_memory("report.xlsx")
      |> elem(1)
      |> elem(1)
  end
  def report_generator(items) do
      rows = items |> Enum.map(&(row(&1)))
      %Workbook{sheets: [%Sheet{name: "Items" , rows: [@header] ++ rows}]}
    end
  def row(item) do
      [
        item.name,
        item.email,
        item.date,
        item.email,
        item.quanity,
        "$0.00"

      ]
    end

end
