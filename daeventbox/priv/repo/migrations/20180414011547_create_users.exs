defmodule Daeventbox.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :firstname, :string
      add :lastname, :string
      add :email, :string
      add :address, :string
      add :password, :string
      add :phone, :string
      add :username, :string
      add :bio, :string
      add :zid, :uuid
      add :details, :map
      add :meta1, :string
      add :meta2, :string

      timestamps()
    end

  end
end
