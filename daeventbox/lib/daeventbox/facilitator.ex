defmodule Daeventbox.Facilitator do
  use Ecto.Schema
  import Ecto.Changeset


  schema "facilitators" do
    field :about, :string
    field :facilitator_address, :string
    field :facilitator_contact, :string
    field :facilitator_email, :string
    field :facilitator_phone, :string
    field :facilitator_zid, Ecto.UUID
    field :fb_link, :string
    field :image, :binary
    field :image_url, :string
    field :insta_link, :string
    field :meta1, :string
    field :meta2, :string
    field :name, :string
    field :role, :string
    field :twitter_link, :string
    field :type, :string
    field :user_id, :integer

    timestamps()
  end

  @doc false
  def changeset(facilitator, attrs) do
    facilitator
    |> cast(attrs, [:user_id, :meta1, :meta2, :type, :role, :name, :about, :fb_link, :insta_link, :twitter_link, :image, :image_url, :facilitator_email, :facilitator_phone, :facilitator_address, :facilitator_contact, :facilitator_zid])
    |> validate_required([:user_id, :name, :facilitator_zid])
  end
end
