defmodule Daeventbox.Faq do
  use Ecto.Schema
  import Ecto.Changeset


  schema "faqs" do
    field :answer, :string
    field :info, :map
    field :meta1, :string
    field :question, :string

    timestamps()
  end

  @doc false
  def changeset(faq, attrs) do
    faq
    |> cast(attrs, [:question, :answer, :info, :meta1])

  end
end
