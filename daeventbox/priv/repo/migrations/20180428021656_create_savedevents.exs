defmodule Daeventbox.Repo.Migrations.CreateSavedevents do
  use Ecto.Migration

  def change do
    create table(:savedevents) do
      add :user_id, :integer
      add :event_id, :integer
      add :info, :map
      add :zid, :uuid
      add :meta1, :string
      add :meta2, :string

      timestamps()
    end

  end
end
