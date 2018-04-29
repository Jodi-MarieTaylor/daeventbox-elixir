defmodule Daeventbox.Ticketdetail do
  use Ecto.Schema
  import Ecto.Changeset


  schema "ticketdetails" do
    field :active, :string
    field :event_id, :integer
    field :name, :string
    field :price, :float
    field :status, :string
    field :type, :string
    field :category, :string
    field :info, :map
    field :meta1, :string
    field :meta2, :string
    field :max_quantity, :integer

    timestamps()
  end

  @doc false
  def changeset(ticketdetail, attrs) do
    ticketdetail
    |> cast(attrs, [:event_id, :status, :active, :name, :price, :type, :category, :info, :meta1, :meta2, :max_quantity])
  end
end
