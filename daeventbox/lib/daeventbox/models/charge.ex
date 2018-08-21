defmodule Daeventbox.Charge do
  use Ecto.Schema
  import Ecto.Changeset


  schema "charges" do
    field :assigned_to, :string
    field :charges, :float
    field :info, :map
    field :meta1, :string
    field :name, :string
    field :status, :string
    field :type, :string

    timestamps()
  end

  @doc false
  def changeset(charge, attrs) do
    charge
    |> cast(attrs, [:charges, :type, :name, :status, :info, :meta1, :assigned_to])
  end
end
