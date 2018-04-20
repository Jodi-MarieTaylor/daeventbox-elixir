defmodule Daeventbox.Plugs.CurrentUser do
  import Plug.Conn

  def init(default), do: default

  def call(conn, default) do
    user = Daeventbox.Repo.get_by(Daeventbox.User, zid: conn.cookies["daeventboxuser"] )

    conn = assign(conn, :current_user, user)
     conn = assign(conn, :current_user, user)

  end
end
