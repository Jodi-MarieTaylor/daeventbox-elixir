defmodule DaeventboxWeb.PageController do
  use DaeventboxWeb, :controller


  alias Daeventbox.Ad
  alias Daeventbox.Event
  import Ecto.Query
  import Plug.Conn

  def index(conn, params) do
  IO.puts "PROMPT"
  #conn

  #|> put_layout(:false)
  #|> render "index.html"
  ads = Repo.all(from a in Ad)
  render conn, "index.html", ads: ads
  end
end
