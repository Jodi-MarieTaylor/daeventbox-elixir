defmodule Daeventbox.SavedEvent do
  use Ecto.Schema
  import Ecto.Changeset


  schema "savedevents" do
    field :event_id, :integer
    field :info, :map
    field :meta1, :string
    field :meta2, :string
    field :user_id, :integer
    field :zid, Ecto.UUID

    timestamps()
  end

  @doc false
  def changeset(saved_event, attrs) do
    saved_event
    |> cast(attrs, [:user_id, :event_id, :info, :zid, :meta1, :meta2])
  end
end
