defmodule Daeventbox.Repo.Migrations.CreateOptions do
  use Ecto.Migration

  def change do
    create table(:options) do
      add :info, :map
      add :position, :string
      add :description, :string
      add :zid, :uuid
      add :size, :string
      add :name, :string
      add :type, :string
      add :max_days, :integer
      add :price, :decimal
      add :meta1, :string
      add :meta2, :string

      timestamps()
    end

  end
end
