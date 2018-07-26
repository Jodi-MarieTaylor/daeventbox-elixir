defmodule DaeventboxWeb.PageController do
  use DaeventboxWeb, :controller


  alias Daeventbox.Ad
  alias Daeventbox.Event
  alias Daeventbox.SavedEvent
  alias Daeventbox.LikedEvent
  alias Daeventbox.Action
  import Ecto.Query
  import Plug.Conn

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
    render conn, "abous-us.html"
  end
  def contact_us(conn, params) do
    render conn, "contact-us.html"
  end
end
