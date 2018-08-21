defmodule Daeventbox.Attendee do
  use Ecto.Schema
  import Ecto.Changeset


  schema "attendees" do
    field :details, :map
    field :event_id, :integer
    field :meta1, :string
    field :meta2, :string
    field :registration_id, :integer
    field :ticket_id, :integer
    field :user_id, :integer
    field :zid, Ecto.UUID

    timestamps()
  end

  @doc false
  def changeset(attendee, attrs) do
    attendee
    |> cast(attrs, [:user_id, :event_id, :ticket_id, :registration_id, :details, :meta1, :meta2, :zid])
    |> validate_required([:user_id, :event_id, :ticket_id, :registration_id, :details, :meta1, :meta2, :zid])
  end
end
