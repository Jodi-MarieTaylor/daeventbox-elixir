defmodule Daeventbox.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :sender_id, :integer
      add :recipient_id, :integer
      add :body, :text
      add :room_id, :integer

      timestamps()
    end

  end
end
