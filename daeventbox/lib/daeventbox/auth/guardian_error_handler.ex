defmodule Daeventbox.GuardianErrorHandler do
  import DaeventboxWeb.Router.Helpers
  import Plug.Conn

  def unauthenticated(conn, _params) do
    conn
    |> Phoenix.Controller.put_flash(:error,
                       "You must be signed in to access that page.")
    |> Phoenix.Controller.redirect(to: "/")
  end

  def auth_error(conn, {type, _reason}, _opts) do
    conn
    |> Phoenix.Controller.put_flash(:error,
                       "You must be signed in to access that page.")
    |> Phoenix.Controller.redirect(to: "/")
  end
end
