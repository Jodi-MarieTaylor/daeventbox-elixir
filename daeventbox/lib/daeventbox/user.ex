defmodule Daeventbox.User do
  use Ecto.Schema
  import Ecto.Changeset


  schema "users" do
    field :address, :string
    field :bio, :string
    field :details, :map
    field :email, :string
    field :firstname, :string
    field :lastname, :string
    field :meta1, :string
    field :meta2, :string
    field :password, :string
    field :phone, :string
    field :username, :string
    field :zid, Ecto.UUID

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:firstname, :lastname, :email, :address, :password, :phone, :username, :bio, :zid, :details, :meta1, :meta2])
    |> validate_required([:firstname, :lastname, :email, :password])
  end
end
