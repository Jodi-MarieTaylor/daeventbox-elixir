defmodule Daeventbox.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset


  schema "messages" do
    field :body, :string
    field :recipient_id, :integer
    field :sender_id, :integer
    field :subject, :string
    field :seen, :boolean

    belongs_to :room, Daeventbox.Chat.Room
    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:subject, :sender_id, :recipient_id, :body, :room_id, :seen])
    |> validate_required([:sender_id, :recipient_id, :body, :room_id])
  end
end
