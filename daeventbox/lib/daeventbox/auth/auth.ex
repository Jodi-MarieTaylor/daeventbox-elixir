defmodule Daeventbox.Auth do
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  alias Daeventbox.User
  alias Daeventbox.Repo

  def login(conn, user) do
    IO.puts "LOGIN"
    IO.inspect user
    conn
    |> Daeventbox.Guardian.Plug.sign_in(user, %{"typ" => "access"})
    |> Plug.Conn.assign(:current_user, user)
  end

  def login_by_email_and_pass(conn, email, given_pass) do
    user = Repo.get_by(Daeventbox.User, email: email)
    IO.inspect given_pass
    IO.inspect email
    IO.inspect user.email
    cond do
      user && checkpw(given_pass, user.password) ->
        {:ok, Daeventbox.Auth.login(conn, user)}
      user ->
        {:error, :unauthorized, conn}
      true ->
        dummy_checkpw
        {:error, :not_found, conn}
    end
  end

  def logout(conn) do
    Daeventbox.Guardian.Plug.sign_out(conn)
  end

  def has_access?(conn, params) do
    user = conn.assigns[:current_user] || %{"id" => 1}
    resource = params["resource"]
    module = String.to_atom("Elixir." <> "Daeventbox." <> resource["name"] <> "Controller")
    params = %{"user_id" => user.id, "resource_id" => resource["id"]}
    apply(module, :has_access?, [params])
  end

end
