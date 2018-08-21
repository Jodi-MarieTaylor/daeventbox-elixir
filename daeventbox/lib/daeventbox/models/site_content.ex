defmodule Daeventbox.SiteContent do
  use Ecto.Schema
  import Ecto.Changeset


  schema "site_contents" do
    field :info, :map
    field :meta1, :string
    field :page, :string
    field :status, :string

    timestamps()
  end

  @doc false
  def changeset(site_content, attrs) do
    site_content
    |> cast(attrs, [:page, :status, :info, :meta1])
  end
end
