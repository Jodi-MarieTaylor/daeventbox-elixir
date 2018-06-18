defmodule Daeventbox.Notification do
  use Ecto.Schema
  import Ecto.Changeset


  schema "notifications" do
    field :event_id, :integer
    field :facilitator_id, :integer
    field :from, :string
    field :info, :map
    field :message, :string
    field :meta1, :string
    field :meta2, :string
    field :sent_by, :string
    field :type, :string
    field :seen, :boolean
    field :hide, :boolean
    field :user_id, :integer

    timestamps()
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:sent_by, :from, :type, :message, :info, :user_id, :facilitator_id, :event_id, :meta1, :meta2, :seen, :hide])
  end
end
