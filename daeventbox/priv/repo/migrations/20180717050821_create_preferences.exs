defmodule Daeventbox.Repo.Migrations.CreatePreferences do
  use Ecto.Migration

  def change do
    create table(:preferences) do
      add :user_id, :integer
      add :type, :string
      add :title, :string
      add :facilitator_id, :integer
      add :status, :string
      add :info, :map
      add :meta1, :string
      add :preference, :string

      timestamps()
    end

  end
end
