defmodule Daeventbox.Repo.Migrations.CreateCharges do
  use Ecto.Migration

  def change do
    create table(:charges) do
      add :charges, :float
      add :type, :string
      add :name, :string
      add :status, :string
      add :info, :map
      add :meta1, :string
      add :assigned_to, :string

      timestamps()
    end

  end
end
