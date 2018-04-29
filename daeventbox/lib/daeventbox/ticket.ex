defmodule Daeventbox.Ticket do
  use Ecto.Schema
  import Ecto.Changeset


  schema "tickets" do
    field :barcode, :integer
    field :barcode_zid, Ecto.UUID
    field :details, :map
    field :event_id, :integer
    field :meta1, :string
    field :meta2, :string
    field :price, :float
    field :quantity, :integer
    field :status, :string
    field :ticket_info, :map
    field :ticket_url, :string
    field :ticket_id, :integer
    field :type, :string
    field :user_id, :integer

    timestamps()
  end

  @doc false
  def changeset(ticket, attrs) do
    ticket
    |> cast(attrs, [:user_id, :event_id, :details, :ticket_url, :barcode, :barcode_zid, :status, :ticket_info, :type, :price, :quantity, :meta1, :meta2, :ticket_id])
  end
end
