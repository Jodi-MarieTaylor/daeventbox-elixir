defmodule Daeventbox.Announcement do
  use Ecto.Schema
  import Ecto.Changeset


  schema "announcements" do
    field :event_id, :integer
    field :from, :string
    field :info, :map
    field :message, :string
    field :meta1, :string
    field :name, :string
    field :recipient, :string
    field :status, :string
    field :type, :string
    field :user_id, :integer
    field :from_id, :integer
    timestamps()
  end

  @doc false
  def changeset(announcement, attrs) do
    announcement
    |> cast(attrs, [:from, :message, :recipient, :event_id, :user_id, :type, :name, :status, :info, :meta1, :from_id])
  end
end
