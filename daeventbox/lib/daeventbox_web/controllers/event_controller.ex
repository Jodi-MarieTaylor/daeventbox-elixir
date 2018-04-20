defmodule DaeventboxWeb.EventController do
  use DaeventboxWeb, :controller

  alias Daeventbox.Event
  import Ecto.Query
  import Plug.Conn
  alias Daeventbox.User
  alias Daeventbox.Repo

  def index(conn, _params) do


    render conn, "index.html"
  end

  def create(conn, params) do
   IO.puts("lll")
    IO.inspect conn.assigns[:current_user]
    render conn, "create_event_form.html", success: nil

  end


  def add(conn, params) do
      IO.puts "Here is the facilitator ID: #{conn.assigns[:current_user].id}"

      current_user = Repo.get_by(User, zid: conn.cookies["daeventboxuser"])
      IO.inspect current_user
      required_params = %{title: params["title"], facilitator_name: params["facilitator_name"], facilitiator_id: conn.assigns[:current_user].id,
       start_date: params["start_date"], start_time: params["start_time"], end_date: params["end_date"], end_time: params["end_time"], category: params["category"], description: params["description"],
       fb_link: params["fb_link"], insta_link: params["insta_link"],  twitter_link: params["twitter_link"], type: params["type"], admission_type: params["admission_type"], location: "#{params["address1"]}, #{params["address2"]}, #{params["parish"]}, Jamaica",
       details: %{}, event_zid:  Ecto.UUID.generate, venue_name: params["venue_name"], location_info: %{parish: params["parish"], address1: params["address1"], address2: params["address2"], country: "Jamaica"}}
      IO.inspect params
      IO.puts "------------------------------------------"
      IO.inspect required_params
      changeset = Event.changeset(%Event{}, required_params)
      case Repo.insert(changeset) do
        {:ok, event} ->
          unless params["type"]== "paid" do
            IO.puts "Event Created Successful"
            show_event_success_modal(conn, params)
          else
            conn
              |> put_flash(:info, "Event created successfully.")
              |> redirect(to: "/payment/card-info" )
              # Webapp.Mailer.send_welcome_email(user.email)
          end
        {:error, changeset} ->
          IO.inspect changeset
          render(conn, "create_event_form.html", changeset: changeset, params: params)
      end
      conn

  end

  defp show_event_success_modal(conn, params) do
    #render(conn, "success_event_modal.html", success: true)
    render(conn, "create_event_form.html", success: "true")
  end

end
