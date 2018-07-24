defmodule Daeventbox.Repo.Migrations.CreateContactRequests do
  use Ecto.Migration

  def change do
    create table(:contact_requests) do
      add :status, :string
      add :info, :map
      add :meta1, :string
      add :name, :string
      add :email, :string
      add :title, :string
      add :message, :string

      timestamps()
    end

  end
end
