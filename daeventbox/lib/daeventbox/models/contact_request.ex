defmodule Daeventbox.ContactRequest do
  use Ecto.Schema
  import Ecto.Changeset


  schema "contact_requests" do
    field :email, :string
    field :info, :map
    field :message, :string
    field :meta1, :string
    field :name, :string
    field :status, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(contact_request, attrs) do
    contact_request
    |> cast(attrs, [:status, :info, :meta1, :name, :email, :title, :message])
    |> validate_required([:name, :email, :title, :message])
  end
end
