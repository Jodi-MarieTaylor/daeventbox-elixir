defmodule Daeventbox.Repo.Migrations.CreateAds do
  use Ecto.Migration

  def change do
    create table(:ads) do
      add :event_id, :integer
      add :user_id, :integer
      add :facilitator_id, :integer
      add :info, :map
      add :zid, :uuid
      add :image, :binary
      add :image_url, :string
      add :name, :string
      add :option_id, :integer
      add :type, :string
      add :days, :integer
      add :price, :decimal
      add :meta1, :string
      add :meta2, :string

      timestamps()
    end

  end
end
