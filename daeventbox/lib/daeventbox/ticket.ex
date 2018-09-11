defmodule Daeventbox.Ticket do
  use Ecto.Schema
  import Ecto.Changeset


  schema "tickets" do
    field :barcode, :string
    field :barcode_zid, Ecto.UUID
    field :details, :map
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
    belongs_to :event, Daeventbox.Event
  end

  @doc false
  def changeset(ticket, attrs) do
    ticket
    |> cast(attrs, [:user_id, :event_id, :details, :ticket_url, :barcode, :barcode_zid, :status, :ticket_info, :type, :price, :quantity, :meta1, :meta2, :ticket_id])
    |> validate_required([:user_id, :event_id, :ticket_url, :barcode])
  end

  def create(ticket) do
    %Daeventbox.Ticket{}
    |> changeset(ticket)
    |> Daeventbox.Repo.insert()
  end

end
