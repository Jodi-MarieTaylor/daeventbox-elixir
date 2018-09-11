defmodule Daeventbox.Follower do
  use Ecto.Schema
  import Ecto.Changeset


  schema "followers" do
    field :facilitator_id, :integer
    field :info, :map
    field :meta1, :string
    field :meta2, :string
    field :user_id, :integer

    timestamps()
  end

  @doc false
  def changeset(follower, attrs) do
    follower
    |> cast(attrs, [:info, :user_id, :facilitator_id, :meta1, :meta2])
  end
end
