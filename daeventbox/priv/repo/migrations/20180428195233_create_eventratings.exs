defmodule Daeventbox.Repo.Migrations.CreateEventratings do
  use Ecto.Migration

  def change do
    create table(:eventratings) do
      add :user_id, :integer
      add :event_id, :integer
      add :rating, :integer
      add :info, :map
      add :zid, :uuid
      add :meta1, :string
      add :meta2, :string

      timestamps()
    end

  end
end
