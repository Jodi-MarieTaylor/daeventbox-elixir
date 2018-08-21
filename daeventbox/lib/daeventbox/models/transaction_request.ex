defmodule Daeventbox.TransactionRequest do
  use Ecto.Schema
  import Ecto.Changeset


  schema "transactionrequests" do
    field :amount_payable, :float
    field :charges, :float
    field :event_id, :integer
    field :facilitator_id, :integer
    field :info, :map
    field :meta1, :string
    field :status, :string
    field :title, :string
    field :total_amount, :float
    field :amount, :float

    timestamps()
  end

  @doc false
  def changeset(transaction_request, attrs) do
    transaction_request
    |> cast(attrs, [:total_amount, :charges, :amount_payable, :facilitator_id, :status, :title, :event_id, :info, :meta1, :amount])
  end
end
