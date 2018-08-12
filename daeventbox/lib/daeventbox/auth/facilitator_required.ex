defmodule Daeventbox.FaciliatorRequired do
  import Plug.Conn

  def init(opts), do: opts
  def call(conn, _opts) do
     current_user = conn.assigns[:current_user]
     case Daeventbox.Repo.get_by(Daeventbox.Facilitator, user_id: current_user.id) do
       nil ->
         conn
         |> Phoenix.Controller.redirect(to: "/profile/create")
        _ ->
          conn
     end
  end

end
