defmodule Daeventbox.Chat.Room do
  use Ecto.Schema
  import Ecto.Changeset


  schema "rooms" do
    field :name, :string
    field :owner_id, :integer
    field :recipient_id, :integer

    has_many :messages, Daeventbox.Chat.Message
    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :owner_id, :recipient_id])
    |> validate_required([:owner_id, :recipient_id])
  end
end
