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

  @required [:firstname, :lastname, :email, :password]

  @optional [:firstname, :lastname, :email, :address, :password, :phone, :username, :bio, :zid, :details, :meta1, :meta2]


  def changeset(user, attrs) do
      user
      |> cast(attrs, Enum.concat(@required, @optional))
      |> validate_required(@required)
  end

  def changeset_in(user, attrs) do
    if Map.get(user, :id) || Map.get(user, "id") do
        user
        |> cast(attrs, Enum.concat(@required, @optional))
        |> validate_format(:email, ~r/@/)
        |> validate_length(:password, min: 8)
        |> validate_confirmation(:password)
        |> unique_constraint(:email)
        |> validate_required(@required)
    else
        user
        |> cast(attrs, Enum.concat(@required, @optional))
        |> put_uid
        |> validate_format(:email, ~r/@/)
        |> validate_length(:password, min: 8)
        |> validate_confirmation(:password)
        |> hash_password
        |> unique_constraint(:email)
        |> validate_required(@required)

    end
  end

  def changepass(user, attrs) do
      user
      |> cast(attrs, Enum.concat(@required, @optional))
      |> put_uid
      |> validate_format(:email, ~r/@/)
      |> validate_length(:password, min: 8)
      |> validate_confirmation(:password)
      |> hash_password
      |> unique_constraint(:email)
      |> validate_required(@required)
  end

  defp hash_password(%{valid?: false} = changeset), do: changeset
  defp hash_password(%{valid?: true} = changeset) do
     hashed_password = Comeonin.Bcrypt.hashpwsalt(Ecto.Changeset.get_field(changeset, :password))
     Ecto.Changeset.put_change(changeset, :password, hashed_password)
  end

  def put_uid(changeset) do
    Ecto.Changeset.put_change(changeset, :uid, Ecto.UUID.generate)
  end
end
