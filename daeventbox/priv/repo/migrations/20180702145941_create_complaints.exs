defmodule Daeventbox.Repo.Migrations.CreateComplaints do
  use Ecto.Migration

  def change do
    create table(:complaints) do
      add :message, :string
      add :event_id, :integer
      add :user_id, :integer
      add :type, :string
      add :title, :string
      add :status, :string
      add :info, :map
      add :meta1, :string

      timestamps()
    end

  end
end
