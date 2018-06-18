defmodule Daeventbox.Repo.Migrations.CreateFollowers do
  use Ecto.Migration

  def change do
    create table(:followers) do
      add :info, :map
      add :user_id, :integer
      add :facilitator_id, :integer
      add :meta1, :string
      add :meta2, :string

      timestamps()
    end

  end
end
