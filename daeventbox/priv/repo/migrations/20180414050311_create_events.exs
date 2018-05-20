defmodule Daeventbox.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :title, :string
      add :location, :string
      add :facilitator_name, :string
      add :facilitator_id, :integer
      add :start_date, :date
      add :start_time, :time
      add :end_date, :date
      add :end_time, :time
      add :category, :string
      add :description, :string
      add :image, :binary
      add :image_url, :string
      add :fb_link, :string
      add :insta_link, :string
      add :twitter_link, :string
      add :type, :string
      add :admission_type, :string
      add :meta1, :string
      add :meta2, :string
      add :details, :map
      add :status, :string

      timestamps()
    end

  end
end
