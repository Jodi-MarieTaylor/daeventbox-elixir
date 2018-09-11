defmodule Daeventbox.ClosedAccount do
  use Ecto.Schema
  import Ecto.Changeset


  schema "closed_accounts" do
    field :facilitator_id, :integer
    field :info, :map
    field :meta1, :string
    field :reason, :string
    field :status, :string
    field :title, :string
    field :type, :string
    field :user_id, :integer
    field :user_name, :string
    field :facilitator_name, :string
    timestamps()
  end

  @doc false
  def changeset(closed_accounts, attrs) do
    closed_accounts
    |> cast(attrs, [:reason, :user_id, :user_name, :type, :title, :facilitator_id, :status, :info, :meta1, :facilitator_name])
  end
end
