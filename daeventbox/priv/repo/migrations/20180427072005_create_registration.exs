defmodule Daeventbox.Repo.Migrations.CreateRegistration do
  use Ecto.Migration

  def change do
    create table(:registration) do
      add :user_id, :integer
      add :event_id, :integer
      add :status, :string
      add :registration_zid, :uuid
      add :details, :map
      add :persons_details, {:array, :map}
      add :quantity, :integer
      add :info, :map
      add :meta1, :string
      add :meta2, :string

      timestamps()
    end

  end
end
