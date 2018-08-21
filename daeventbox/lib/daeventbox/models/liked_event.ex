defmodule Daeventbox.LikedEvent do
  use Ecto.Schema
  import Ecto.Changeset


  schema "likedvents" do
    field :event_id, :integer
    field :info, :map
    field :meta1, :string
    field :meta2, :string
    field :user_id, :integer
    field :zid, Ecto.UUID

    timestamps()
  end

  @doc false
  def changeset(liked_event, attrs) do
    liked_event
    |> cast(attrs, [:user_id, :event_id, :info, :zid, :meta1, :meta2])
  end
end
