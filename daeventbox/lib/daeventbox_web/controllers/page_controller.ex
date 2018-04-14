defmodule DaeventboxWeb.PageController do
  use DaeventboxWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
