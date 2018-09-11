defmodule DaeventboxWeb.TicketController do
  use DaeventboxWeb, :controller

  alias Daeventbox.Ticket

  def generate_barcode(user_id, event_id) do
    pre_token = "-USER-#{user_id}-" <> "EVENT-#{event_id}"
    barcode = Barcode.generate(pre_token, 39)
    {:ok, resp} = Utils.AmazonS3.file_upload(%{"file" => barcode})
    {barcode.token, convert_url(resp.url)}
  end

  def create_ticket(conn, params, ticket) do
    user = conn.assigns[:current_user]
    event = Daeventbox.Repo.get(Daeventbox.Event, params["event_id"])
    {barcode, url} = generate_barcode(user.id, event.id)
    case Ticket.create(%{"status"=> "Active", "ticket_url" => url, "barcode" => barcode, "event_id" => event.id, "user_id" => user.id, "ticket_id" => ticket.id}) do
      {:ok, new_ticket} ->
        ticket =
          ticket
          |> Map.put(:event, event)
        DaeventboxWeb.EmailController.ticket_email(new_ticket, user)
        {:ok, ticket}
      {:error, reason} ->
        errors = Changeset.errors(reason) |> Enum.join(",")
        {:error, errors}
    end


  end

  def convert_url(url) do
    String.replace(url, "https://d1l54leyvskqrr.cloudfront.net", "https://s3.us-east-2.amazonaws.com/daeventboximages")
  end

end
