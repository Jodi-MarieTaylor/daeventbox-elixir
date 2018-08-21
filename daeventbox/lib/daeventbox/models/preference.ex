defmodule Daeventbox.Preference do
  use Ecto.Schema
  import Ecto.Changeset


  schema "preferences" do
    field :facilitator_id, :integer
    field :info, :map
    field :meta1, :string
    field :preference, :string
    field :status, :string
    field :title, :string
    field :type, :string
    field :user_id, :integer

    timestamps()
  end

  @doc false
  def changeset(preference, attrs) do
    preference
    |> cast(attrs, [:user_id, :type, :title, :facilitator_id, :status, :info, :meta1, :preference])
  end
end
