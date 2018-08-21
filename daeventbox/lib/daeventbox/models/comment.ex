defmodule Daeventbox.Comment do
  use Ecto.Schema
  import Ecto.Changeset


  schema "comments" do
    field :event_id, :integer
    field :from, :string
    field :hide, :boolean, default: false
    field :message, :string
    field :meta1, :string
    field :meta2, :string
    field :sent_by, :string
    field :type, :string
    field :user_id, :integer

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:hide, :type, :message, :sent_by, :from, :user_id, :event_id, :meta1, :meta2])
  end
end
