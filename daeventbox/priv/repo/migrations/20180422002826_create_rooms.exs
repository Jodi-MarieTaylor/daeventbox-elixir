defmodule Daeventbox.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :name, :string
      add :owner_id, :integer
      add :recipient_id, :integer

      timestamps()
    end

  end
end
