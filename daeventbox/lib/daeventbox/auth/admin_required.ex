defmodule Daeventbox.AdminRequired do
  import Plug.Conn

  def init(opts), do: opts
  def call(conn, _opts) do
     current_user = conn.assigns[:current_user] || Map.new
     case Map.get(current_user, :role ) do
       nil ->
         conn
         |> Phoenix.Controller.redirect(to: "/admin/login")
        2 ->
          conn
        _ ->
          conn
         |> Phoenix.Controller.redirect(to: "/admin/login")
     end

  end

end
