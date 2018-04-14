defmodule DaeventboxWeb.EventController do
  use DaeventboxWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def create(conn, params) do
    render conn, "create_event_form.html"

  end

  def add(conn, params) do
  end

end
