defmodule Daeventbox.Complaints do
  use Ecto.Schema
  import Ecto.Changeset


  schema "complaints" do
    field :event_id, :integer
    field :info, :map
    field :message, :string
    field :meta1, :string
    field :status, :string
    field :title, :string
    field :type, :string
    field :user_id, :integer
    field :facilitator_id, :integer

    timestamps()
  end

  @doc false
  def changeset(complaints, attrs) do
    complaints
    |> cast(attrs, [:message, :event_id, :user_id, :type, :title, :status, :info, :meta1, :facilitator_id])
  end
end
