defmodule DaeventboxWeb.TicketController do
  use DaeventboxWeb, :controller

  alias Daeventbox.Ticket

  def generate_barcode(user_id, event_id) do
    pre_token = "-USER-#{user_id}-" <> "EVENT-#{event_id}"
    barcode = Barcode.generate(pre_token, 39)
    {:ok, resp} = Utils.AmazonS3.file_upload(%{"file" => barcode})
    {barcode.token, convert_url(resp.url)}
  end

  def create_ticket(event_id, user) do
    event = Daeventbox.Repo.get(Daeventbox.Event, event_id)
    IO.inspect event
    IO.inspect user
    {barcode, url} = generate_barcode(user.id, event.id)
    case Ticket.create(%{"ticket_url" => url, "barcode" => barcode, "event_id" => event.id, "user_id" => user.id}) do
      {:ok, ticket} ->
        ticket =
          ticket
          |> Map.put(:event, event)
        DaeventboxWeb.EmailController.ticket_email(ticket, user)
        {:ok, ticket}
      {:error, reason} ->
        errors = Changeset.errors(reason) |> Enum.join(",")
        {:error, errors}
    end
  end

  #Ticket
  #|> where([t], not is_nil(t.id))
  #|> preload([:event])
  #|> limit(1)
  #|> Repo.one

  def create_ticket(conn, params, b) do
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

  def convert_url(url) do
    String.replace(url, "https://d1l54leyvskqrr.cloudfront.net", "https://s3.us-east-2.amazonaws.com/daeventboximages")
  end

end
