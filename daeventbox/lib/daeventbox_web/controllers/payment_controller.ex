defmodule DaeventboxWeb.PaymentController do
  use DaeventboxWeb, :controller

  alias Daeventbox.Event
  import Ecto.Query
  import Plug.Conn
  alias Daeventbox.User
  alias Daeventbox.Repo

  def index(conn, _params) do
    render conn, "index.html"
  end

  def home(conn, params) do
    redirect conn, to: "/"
  end

  def payment_form(conn, params) do
    render conn, "payment_form.html", success: "false"
  end

  def make_payment(conn, %{"event_id" => event_id} = params) do
      event = Repo.get!(Event, params["event_id"])
      if event.admission_type == "registration" do
        add_registration(conn, params)
        email =
          Map.new
          |> Map.put("title", "Payment Confirmation")
          |> Map.put("template", "payment_confirmation.html")
        DaeventboxWeb.EmailController.generic_email(conn.assigns[:current_user], email)
        conn
        |> redirect(to: "/event/manage")
      else

        add_ticket(conn, params)
        email =
          Map.new
          |> Map.put("title", "Payment Confirmation")
          |> Map.put("template", "payment_confirmation.html")
        DaeventboxWeb.EmailController.generic_email(conn.assigns[:current_user], email)
        conn
        |> redirect(to: "/event/manage")
        #show_event_success_modal(conn, params)
      end
  end

  defp save_card(conn,params) do
      #case Repo.insert(changeset) do
      #  {:ok, event} ->
      #    unless params["type"]==paid do
      #      IO.puts "Event Created Successful"
      #      show_event_success_modal(conn, params)
      #    else
      #      conn
      #        |> put_flash(:info, "Event created successfully.")
      #        |> redirect(to: "/payment/card-info" )
      #        # Webapp.Mailer.send_welcome_email(user.email)
      #    end
      #  {:error, changeset} ->
      #    IO.inspect changeset
      #    render(conn, "create_event_form.html", changeset: changeset, params: params)
      #end
  end
  defp show_event_success_modal(conn, params) do
    #render(conn, "success_event_modal.html", success: true)
    render(conn, "payment_form.html", success: "true")
  end

  def add_ticket(conn, params) do
    total_items = String.to_integer(params["total_items"])-1
    for count <- 0..total_items do
       IO.puts "here is itemq"
       IO.inspect params["itemq#{count}"]
      unless params["itemq#{count}"] == "0"  do
        ticket = Repo.get!(Ticketdetail, String.to_integer(params["item#{count}"]))
        for i <- 1..String.to_integer(params["itemq#{count}"]) do
          DaeventboxWeb.TicketController.create_ticket(conn, params, ticket)
        end
      end
    end
  end

  def add_registration(conn, params) do

    DaeventboxWeb.RegistrationController.add_registration(conn, params)

  end

end
