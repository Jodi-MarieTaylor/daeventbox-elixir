defmodule Daeventbox.Ad do
  use Ecto.Schema
  import Ecto.Changeset


  schema "ads" do
    field :days, :integer
    field :event_id, :integer
    field :facilitator_id, :integer
    field :image, :binary
    field :image_url, :string
    field :info, :map
    field :meta1, :string
    field :meta2, :string
    field :name, :string
    field :option_id, :integer
    field :price, :float
    field :type, :string
    field :user_id, :integer
    field :zid, Ecto.UUID
    field :status, :string
    field :is_deleted, :boolean

    timestamps()
  end

  @doc false
  def changeset(ad, attrs) do
    ad
    |> cast(attrs, [:id, :is_deleted, :event_id, :user_id, :facilitator_id, :info, :zid, :image, :image_url, :name, :option_id, :type, :days, :price, :meta1, :meta2, :status])
  end
end
