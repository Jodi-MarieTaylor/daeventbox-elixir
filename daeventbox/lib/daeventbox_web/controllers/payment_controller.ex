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

  def payment_form(conn, params) do
    render conn, "payment_form.html", success: "false"
  end

  def make_payment(conn, params) do



      conn
      show_event_success_modal(conn, params)
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

end
