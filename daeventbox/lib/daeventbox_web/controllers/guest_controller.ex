defmodule DaeventboxWeb.GuestController do
  use DaeventboxWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def home(conn, _params) do
    render conn, "home.html"
  end

  def changemode(conn, _params) do
    time_in_secs_from_now = 86400 * 90
    conn
      |> delete_resp_cookie("daeventboxmode")
      |> delete_resp_cookie("daeventboxmode")
      |> put_resp_cookie("daeventboxmode", "Guest", max_age: time_in_secs_from_now)
      |> redirect(to: "/switch/guest"  )

  end
end
