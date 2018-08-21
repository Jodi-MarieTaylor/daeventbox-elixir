defmodule Daeventbox.Registration do
  use Ecto.Schema
  import Ecto.Changeset


  schema "registration" do
    field :details, :map
    field :event_id, :integer
    field :info, :map
    field :meta1, :string
    field :meta2, :string
    field :persons_details, {:array, :map}
    field :quantity, :integer
    field :registration_zid, Ecto.UUID
    field :status, :string
    field :user_id, :integer
    field :registrationdetails_id, :integer
    timestamps()
  end

  @doc false
  def changeset(registration, attrs) do
    registration
    |> cast(attrs, [:user_id, :event_id, :status, :registration_zid, :details, :persons_details, :quantity, :info, :meta1, :meta2, :registrationdetails_id])
  end
end
