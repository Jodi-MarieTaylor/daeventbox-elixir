defmodule Daeventbox.News do
  use Ecto.Schema
  import Ecto.Changeset


  schema "news" do
    field :body, :string
    field :image, :binary
    field :image_url, :string
    field :info, :map
    field :meta1, :string
    field :status, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(news, attrs) do
    news
    |> cast(attrs, [:status, :title, :body, :image_url, :image, :info, :meta1])

  end
end
