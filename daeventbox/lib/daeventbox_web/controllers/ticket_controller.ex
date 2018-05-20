defmodule DaeventboxWeb.TicketController do
  use DaeventboxWeb, :controller

  alias Daeventbox.Ticket

  def generate_barcode(user_id, event_id) do
    pre_token = "-USER-#{user_id}-" <> "EVENT-#{event_id}"
    barcode = Barcode.generate(pre_token, 39)
    {:ok, resp} = Utils.AmazonS3.file_upload(%{"file" => barcode})
    {barcode.token, resp.url}
  end

  def create_ticket(conn, params) do
    user = conn.assigns[:current_user]
    event = Daeventbox.Repo.get(Daeventbox.Event, 28)
    {barcode, url} = generate_barcode(user.id, event.id)
    case Ticket.create(%{"ticket_url" => url, "barcode" => barcode, "event_id" => event.id, "user_id" => user.id}) do
      {:ok, ticket} ->
        conn
        |> put_flash(:info, "Ticket Successfully created.")
        |> redirect(to: "/")
      {:error, reason} ->
        errors = Changeset.errors(reason) |> Enum.join(",")
        conn
        |> put_flash(:error, errors)
        |> redirect(to: "/")
    end
  end

end
