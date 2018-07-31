defmodule Daeventbox.Repo.Migrations.CreateSiteContents do
  use Ecto.Migration

  def change do
    create table(:site_contents) do
      add :page, :string
      add :status, :string
      add :info, :map
      add :meta1, :string

      timestamps()
    end

  end
end
