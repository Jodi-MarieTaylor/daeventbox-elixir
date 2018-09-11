defmodule Daeventbox.Repo.Migrations.CreateAnnouncements do
  use Ecto.Migration

  def change do
    create table(:announcements) do
      add :from, :string
      add :message, :string
      add :recipient, :string
      add :event_id, :integer
      add :user_id, :integer
      add :type, :string
      add :name, :string
      add :status, :string
      add :info, :map
      add :meta1, :string

      timestamps()
    end

  end
end
