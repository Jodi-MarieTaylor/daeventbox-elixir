defmodule Daeventbox.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :sent_by, :string
      add :from, :string
      add :type, :string
      add :message, :string
      add :info, :map
      add :user_id, :integer
      add :facilitator_id, :integer
      add :event_id, :integer
      add :meta1, :string
      add :meta2, :string

      timestamps()
    end

  end
end
