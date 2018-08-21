defmodule Daeventbox.Registrationdetails do
  use Ecto.Schema
  import Ecto.Changeset


  schema "registrationdetails" do
    field :active, :integer
    field :category, :string
    field :event_id, :integer
    field :info, :map
    field :max_quantity, :integer
    field :meta1, :string
    field :meta2, :string
    field :status, :string
    field :type, :string
    field :zid, Ecto.UUID
    field :price, :float
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(registrationdetails, attrs) do
    registrationdetails
    |> cast(attrs, [:event_id, :status, :type, :category, :active, :max_quantity, :info, :meta1, :meta2, :zid, :price, :name])
  end
end
