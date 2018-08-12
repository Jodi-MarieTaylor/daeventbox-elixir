defmodule DaeventboxWeb.PageController do
  use DaeventboxWeb, :controller


  alias Daeventbox.Ad
  alias Daeventbox.Event
  alias Daeventbox.SavedEvent
  alias Daeventbox.LikedEvent
  alias Daeventbox.Action
  alias Daeventbox.SiteContent
  alias Daeventbox.Inquiry
  import Ecto.Query
  import Plug.Conn

  def daeventbox(conn, params) do
      time_in_secs_from_now = 86400 * 90
      conn
        |> delete_resp_cookie("daeventboxmode")
        |> delete_resp_cookie("daeventboxmode")
        |> put_resp_cookie("daeventboxmode", "Guest", max_age: time_in_secs_from_now)
        |> redirect(to: "/"  )


  end
  def index(conn, params) do

  IO.puts "PROMPT"
  #conn

  #|> put_layout(:false)
  #|> render "index.html"
  ads = Repo.all(from a in Ad)
  saved_events = Repo.all(from s in SavedEvent, join: e in Event, where: s.event_id == e.id and  is_nil(e.is_deleted), group_by: s.event_id, order_by: [desc: count(s.event_id)], select: s.event_id, limit: 3)
  liked_events = Repo.all(from l in LikedEvent, join: e in Event, where: l.event_id == e.id and  is_nil(e.is_deleted), group_by: l.event_id, order_by: [desc: count(l.event_id)], select: l.event_id, limit: 3)
  views_events = Repo.all(from a in Action, join: e in Event, where: a.event_id == e.id and  is_nil(e.is_deleted) and a.action == "viewed-event-details", group_by: a.event_id, order_by: [desc: count(a.event_id)], select: a.event_id, limit: 3)
  events =  Repo.all(from e in Event, where: e.id in ^saved_events or e.id in ^liked_events  or e.id in ^views_events , distinct: e.id)
  latest_events = Repo.all(from e in Event, where:  is_nil(e.is_deleted),  order_by: [desc: e.inserted_at], limit: 6)
  render conn, "index.html", ads: ads, events: events, latest_events: latest_events
  end

  def about_us(conn, params) do
    content = Repo.get_by(SiteContent, page: "about-us")
    about = content.info["body"]
    render conn, "abous-us.html", about: about
  end
  def contact_us(conn, params) do
    content = Repo.get_by(SiteContent, page: "contact-us")
    render conn, "contact-us.html", info: content.info
  end

  def contact_send(conn, params) do
    IO.puts "These are the params for contact us"
    IO.inspect params
    inquiry_params = %{name: params["name"], email: params["email"], message: params["message"], status: "New"}
    changeset = Inquiry.changeset(%Inquiry{}, inquiry_params)

    case Repo.insert(changeset) do
      {:ok, _inquiry} -> IO.puts "Inquiry Added"
      conn
      |> put_flash(:info, "Message Sent, Thank You! We will be in contact soon.")
      |> redirect to: "/contactus"
      {:error, reason} -> IO.inspect reason
    end
  end
end
