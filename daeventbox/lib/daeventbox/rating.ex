defmodule Daeventbox.Rating do
  use Ecto.Schema
  import Ecto.Changeset


  schema "ratings" do
    field :event_id, :integer
    field :facilitator_id, :integer
    field :info, :map
    field :meta1, :string
    field :rating, :integer
    field :status, :string
    field :title, :string
    field :type, :string
    field :user_id, :integer

    timestamps()
  end

  @doc false
  def changeset(rating, attrs) do
    rating
    |> cast(attrs, [:rating, :event_id, :user_id, :type, :title, :facilitator_id, :status, :info, :meta1])
  end
end
