defmodule DaeventboxWeb.FacilitatorController do
  use DaeventboxWeb, :controller

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
      |> redirect(to: "/switch/facilitator"  )

  end
end
