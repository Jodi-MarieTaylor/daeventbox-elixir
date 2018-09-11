defmodule Daeventbox.Repo.Migrations.CreateTickets do
  use Ecto.Migration

  def change do
    create table(:tickets) do
      add :user_id, :integer
      add :event_id, :integer
      add :details, :map
      add :ticket_url, :string
      add :barcode, :integer
      add :barcode_zid, :uuid
      add :status, :string
      add :ticket_info, :map
      add :type, :string
      add :price, :float
      add :quantity, :integer
      add :meta1, :string
      add :meta2, :string

      timestamps()
    end

  end
end
