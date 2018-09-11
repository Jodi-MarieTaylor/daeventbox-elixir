defmodule Daeventbox.Repo.Migrations.CreateNews do
  use Ecto.Migration

  def change do
    create table(:news) do
      add :status, :string
      add :title, :string
      add :body, :string
      add :image_url, :string
      add :image, :binary
      add :info, :map
      add :meta1, :string

      timestamps()
    end

  end
end
