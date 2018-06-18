defmodule Daeventbox.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :hide, :boolean, default: false, null: false
      add :type, :string
      add :message, :string
      add :sent_by, :string
      add :from, :string
      add :user_id, :integer
      add :event_id, :integer
      add :meta1, :string
      add :meta2, :string

      timestamps()
    end

  end
end
