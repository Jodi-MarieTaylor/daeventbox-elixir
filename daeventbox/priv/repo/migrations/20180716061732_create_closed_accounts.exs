defmodule Daeventbox.Repo.Migrations.CreateClosedAccounts do
  use Ecto.Migration

  def change do
    create table(:closed_accounts) do
      add :reason, :string
      add :user_id, :integer
      add :user_name, :string
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
