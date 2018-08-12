defmodule Daeventbox.Inquiry do
  use Ecto.Schema
  import Ecto.Changeset


  schema "inquiries" do
    field :email, :string
    field :info, :map
    field :message, :string
    field :meta1, :string
    field :name, :string
    field :status, :string

    timestamps()
  end

  @doc false
  def changeset(inquiry, attrs) do
    inquiry
    |> cast(attrs, [:name, :email, :message, :status, :info, :meta1])
    |> validate_required([:name, :email, :message])
  end
end
