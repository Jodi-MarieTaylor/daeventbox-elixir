defmodule Daeventbox.Repo.Migrations.CreateActions do
  use Ecto.Migration

  def change do
    create table(:actions) do
      add :anonymous_id, :integer
      add :action, :string
      add :utm_source, :string
      add :utm_medium, :string
      add :utm_campaign, :string
      add :utm_content, :string
      add :ip, :string
      add :info, :map
      add :geo, :map
      add :processed, :boolean, default: false, null: false
      add :meta1, :string
      add :action_id, :integer
      add :event_id, :integer

      timestamps()
    end

  end
end
