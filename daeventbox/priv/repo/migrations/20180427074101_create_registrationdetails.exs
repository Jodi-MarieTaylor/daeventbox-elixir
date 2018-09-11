defmodule Daeventbox.Repo.Migrations.CreateRegistrationdetails do
  use Ecto.Migration

  def change do
    create table(:registrationdetails) do
      add :event_id, :integer
      add :status, :string
      add :type, :string
      add :category, :string
      add :active, :integer
      add :max_quantity, :integer
      add :info, :map
      add :meta1, :string
      add :meta2, :string
      add :zid, :uuid
      add :price, :float
      add :name, :string

      timestamps()
    end

  end
end
