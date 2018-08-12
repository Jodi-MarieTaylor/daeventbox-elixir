defmodule Daeventbox.Repo.Migrations.CreateInquiries do
  use Ecto.Migration

  def change do
    create table(:inquiries) do
      add :name, :string
      add :email, :string
      add :message, :text
      add :status, :string
      add :info, :map
      add :meta1, :string

      timestamps()
    end

  end
end
