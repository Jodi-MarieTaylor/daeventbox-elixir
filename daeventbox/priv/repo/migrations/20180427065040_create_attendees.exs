defmodule Daeventbox.Repo.Migrations.CreateAttendees do
  use Ecto.Migration

  def change do
    create table(:attendees) do
      add :user_id, :integer
      add :event_id, :integer
      add :ticket_id, :integer
      add :registration_id, :integer
      add :details, :map
      add :meta1, :string
      add :meta2, :string
      add :zid, :uuid


      timestamps()
    end

  end
end
