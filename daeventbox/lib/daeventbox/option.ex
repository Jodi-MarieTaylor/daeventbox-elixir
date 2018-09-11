defmodule Daeventbox.Option do
  use Ecto.Schema
  import Ecto.Changeset


  schema "options" do
    field :description, :string
    field :info, :map
    field :max_days, :integer
    field :meta1, :string
    field :meta2, :string
    field :name, :string
    field :position, :string
    field :price, :float
    field :size, :string
    field :type, :string
    field :zid, Ecto.UUID
    field :status, :string
    field :image_url, :string

    timestamps()
  end

  @doc false
  def changeset(option, attrs) do
    option
    |> cast(attrs, [:info, :position, :description, :zid, :size, :name, :type, :max_days, :price, :meta1, :meta2, :status, :image_url])
  end
end
