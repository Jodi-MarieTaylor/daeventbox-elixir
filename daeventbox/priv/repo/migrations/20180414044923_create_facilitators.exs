defmodule Daeventbox.Repo.Migrations.CreateFacilitators do
  use Ecto.Migration

  def change do
    create table(:facilitators) do
      add :user_id, :integer
      add :meta1, :string
      add :meta2, :string
      add :type, :string
      add :role, :string
      add :name, :string
      add :about, :string
      add :fb_link, :string
      add :insta_link, :string
      add :twitter_link, :string
      add :image, :binary
      add :image_url, :string
      add :facilitator_email, :string
      add :facilitator_phone, :string
      add :facilitator_address, :string
      add :facilitator_contact, :string
      add :facilitator_zid, :uuid

      timestamps()
    end

  end
end
