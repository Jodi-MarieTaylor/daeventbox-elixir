defmodule Daeventbox.EventRating do
  use Ecto.Schema
  import Ecto.Changeset


  schema "eventratings" do
    field :event_id, :integer
    field :info, :map
    field :meta1, :string
    field :meta2, :string
    field :rating, :integer
    field :user_id, :integer
    field :zid, Ecto.UUID

    timestamps()
  end

  @doc false
  def changeset(event_rating, attrs) do
    event_rating
    |> cast(attrs, [:user_id, :event_id, :rating, :info, :zid, :meta1, :meta2])
    |> validate_required([:user_id, :event_id, :rating, :info, :zid, :meta1, :meta2])
  end
end
