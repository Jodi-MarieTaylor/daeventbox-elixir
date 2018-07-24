defmodule Daeventbox.Repo.Migrations.CreateFaqs do
  use Ecto.Migration

  def change do
    create table(:faqs) do
      add :question, :string
      add :answer, :string
      add :info, :map
      add :meta1, :string

      timestamps()
    end

  end
end
