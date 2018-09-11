defmodule Daeventbox.Repo.Migrations.CreateTicketdetails do
  use Ecto.Migration

  def change do
    create table(:ticketdetails) do
      add :event_id, :integer
      add :status, :string
      add :active, :string
      add :name, :string
      add :price, :float
      add :type, :string
      add :category, :string
      add :info, :map
      add :meta1, :string
      add :meta2, :string

      timestamps()
    end

  end
end
