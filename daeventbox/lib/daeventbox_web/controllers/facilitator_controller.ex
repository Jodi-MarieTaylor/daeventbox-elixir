defmodule DaeventboxWeb.FacilitatorController do
  use DaeventboxWeb, :controller

  alias Daeventbox.Event
  import Ecto.Query
  import Plug.Conn
  alias Daeventbox.User
  alias Daeventbox.Repo
  alias Daeventbox.Facilitator

  def index(conn, _params) do
    render conn, "index.html"
  end

  def switch(conn, _params) do
    #if first first time being facilitator (to check - check if its in facilitator table)
    render conn, "switchfirsttime.html"
  end

  def changemode(conn, _params) do
    time_in_secs_from_now = 86400 * 90
    conn
      |> delete_resp_cookie("daeventboxmode")
      |> delete_resp_cookie("daeventboxmode")
      |> put_resp_cookie("daeventboxmode", "Facilitator", max_age: time_in_secs_from_now)
      |> redirect(to: "/facilitator/switch"  )

  end

  def home(conn, params) do
    user_id = conn.assigns[:current_user].id
    events = filter(params, conn.assigns[:current_user].id)
    render conn, "home.html", events: events
  end

  def filter(params, user_id) do
    IO.puts "!!!!!!!!!!!!!!!!!!!!!!!@@#"
    IO.inspect params

    events =
    Event
    |> where([e], not is_nil(e.id))
    |> where([e], e.facilitator_id == ^user_id)

    events =
      if params["title_search"] != "" and params["title_search"] != nil do
        events
          |> where([e], fragment("? ~* ?", e.title, ^params["title_search"]))
      else
        events
      end
    events =
      if params["content_search"] != "" and params["content_search"] != nil do
        IO.inspect "look here work"
        events
          |> where([e], fragment("? ~* ?", e.description, ^params["content_search"]))
      else
        events
      end
    events =
    if params["category_search"] != "" and params["category_search"] != nil do
      events
        |> where([e], fragment("? ~* ?", e.category, ^params["category_search"]))
    else
      events
    end

    events =
      if params["type_search"] != "" and params["type_search"] != nil do
        events
          |> where([e], fragment("? ~* ?", e.type, ^params["type_search"]))
      else
        events
      end

    #events =
    #  if params["location_search"] != "" and params["location_search"] != nil do
     #   events
    #      |> where([e], fragment("? ~* ?", e.location_info.parish, ^params["location_search"]))
    #  else
    #    events
    #  end

      events =
        if params["date_sort"] == "asc" do
           events
             |> order_by([e], asc: e.inserted_at)
        else
          events
        end

    #events =
    #  if params["likes_search"] != "" and params["likes_search"] != nil do
    #    likes = String.split(params["likes_search"], "-")
    #  IO.inspect  ulikes = Enum.at(likes, 0)
    #  IO.inspect  olikes = Enum.at(likes, 1)
    #    events
    #      |> where([p], p.likes > ^ulikes and p.likes < ^olikes)
    #  else
    #    events
    #  end

    #events =
    #    if params["ratings_sort"] == "desc" do
    #     events
    #      |> order_by([p], asc: p.likes)
    #    else
    #      events
    #    end

    #events =
    #      if params["ratings_sort"] == "asc" do
    #        events
    #        |> order_by([p], desc: p.likes)
    #  else
    #    events
    #  end

	events =
		events
		|> Repo.all


  end

  def eventsearch(conn, params) do

    current_user = Repo.get_by(User, zid: conn.cookies["daeventboxuser"])

    ctitle = String.strip(params["search_text"]) |> String.split(" ") |> Enum.map( &String.capitalize/1 )|> Enum.join(" ")
    query = from e in Event, where:  fragment("? ~* ?", e.title, ^ctitle)
    events =  Repo.all(query)
    render conn, "home.html", events: events

  end

  def dashboard(conn, params) do
    current_user = Repo.get_by(User, zid: conn.cookies["daeventboxuser"])
    event = Repo.get!(Event, 1)
    #event = Repo.get!(Event, params["id"])
    IO.inspect event.type

    cond do
      event.type =="paid" and event.admission_type == "tickets" ->
          event_details = %{}
          render conn, "dashboard1.html", event_details: event_details
      event.type == "paid" and event.admission_type =="registration" ->
        event_details = %{}
        render conn, "dashboard2.html", event_details: event_details
      event.type == "free" and event.admission_type == "registration" ->
        event_details = %{}
        render conn, "dashboard3.html", event_details: event_details
      event.type == "free" ->
        event_details = %{}
        render conn, "dashboard4.html", event_details: event_details

    end
  end

  def profile_form(conn, params) do
    render conn, "profile_form.html"
  end
   def profile(conn, params) do
    facilitator = Repo.get_by(Facilitator, id: params["id"])

    render conn, "profile.html",  facilitator: facilitator
  end

  def profile_preview(conn,params) do
    current_user = Repo.get_by(User, zid: conn.cookies["daeventboxuser"])
    facilitator = Repo.get_by(Facilitator, id: current_user.id)

    render conn, "profile_preview.html", facilitator: facilitator
  end

  def update_profile(conn, params) do
    facilitator = Repo.get!(Facilitator, params["id"])
    required_params = %{name: params["name"], about: params["about"], website_link: params["website_link"], fb_link: params["fb_link"], insta_link: params["insta_link"],
    twitter_link: params["twitter_link"], image: params["image"], image_url: params["image_url"], facilitator_email: params["email"], facilitator_phone: params["phone"],
    facilitator_address: params["address"], facilitator_contact: params["contact"]}
      IO.inspect params
    changeset = Facilitator.changeset(facilitator, required_params)
    case Repo.update(changeset) do
      {:ok, _facilitator} ->
        conn
        |> put_flash(:info, "Event updated successfully.")
        |> redirect(to: "/facilitator")

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Oops error!")
        |> redirect(to: "/event/edit")
    end
  end

end
