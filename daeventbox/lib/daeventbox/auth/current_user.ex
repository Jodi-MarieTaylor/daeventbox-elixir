defmodule Daeventbox.CurrentUser do
  import Plug.Conn
  import Guardian.Plug
  def init(opts), do: opts
  def call(conn, _opts) do
     current_user = current_resource(conn)
     IO.puts "CURRENT USER"
 	   IO.inspect current_user
     assign(conn, :current_user, current_user)
  end


  def set_user(conn, user) do
     { :ok, jwt, full_claims } = Daeventbox.Guardian.encode_and_sign(user)
     IO.puts "THIS USER"
     IO.inspect user
     time_in_secs_from_now = 7 * 24 * 60 * 60 # a week from now
     conn
     |> put_resp_cookie("current_user", jwt, max_age: time_in_secs_from_now)
  end
end
