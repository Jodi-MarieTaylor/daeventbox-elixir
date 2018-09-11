defmodule Daeventbox.Repo.Migrations.CreateRatings do
  use Ecto.Migration

  def change do
    create table(:ratings) do
      add :rating, :integer
      add :event_id, :integer
      add :user_id, :integer
      add :type, :string
      add :title, :string
      add :facilitator_id, :integer
      add :status, :string
      add :info, :map
      add :meta1, :string

      timestamps()
    end

  end
end
