defmodule Daeventbox.Event do
  use Ecto.Schema
  import Ecto.Changeset


  schema "events" do
    field :admission_type, :string
    field :category, :string
    field :description, :string
    field :details, :map
    field :location_info, :map
    field :end_date, :date
    field :end_time, :time
    field :facilitator_id, :integer
    field :facilitator_name, :string
    field :fb_link, :string
    field :image, :binary
    field :image_url, :string
    field :insta_link, :string
    field :location, :string
    field :meta1, :string
    field :meta2, :string
    field :start_date, :date
    field :start_time, :time
    field :title, :string
    field :twitter_link, :string
    field :type, :string
    field :event_zid,  Ecto.UUID
    field :venue_name, :string
    field :status, :string
    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:title, :status, :location, :facilitator_name, :facilitator_id, :start_date, :start_time, :end_date, :end_time, :category, :description, :image, :image_url, :fb_link, :insta_link, :twitter_link, :type, :admission_type, :meta1, :meta2, :details, :event_zid, :venue_name, :location_info])
    |> validate_required([:title, :location, :facilitator_name,  :start_date, :start_time, :type, :admission_type, :event_zid])
  end
end
