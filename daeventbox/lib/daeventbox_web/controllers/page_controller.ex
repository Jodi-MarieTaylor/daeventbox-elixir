defmodule DaeventboxWeb.PageController do
  use DaeventboxWeb, :controller

  def index(conn, params) do
  IO.puts "PROMPT"
  #conn

  #|> put_layout(:false)
  #|> render "index.html"
  render conn, "index.html"
  end
end
