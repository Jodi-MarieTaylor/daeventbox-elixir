defmodule Daeventbox.Repo.Migrations.CreateTransactionrequests do
  use Ecto.Migration

  def change do
    create table(:transactionrequests) do
      add :total_amount, :float
      add :charges, :float
      add :amount_payable, :float
      add :facilitator_id, :integer
      add :status, :string
      add :title, :string
      add :event_id, :integer
      add :info, :map
      add :meta1, :string

      timestamps()
    end

  end
end
