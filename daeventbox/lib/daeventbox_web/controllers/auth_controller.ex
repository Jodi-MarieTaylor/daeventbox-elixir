defmodule DaeventboxWeb.AuthController do
  use DaeventboxWeb, :controller

  @moduledoc """
  AuthenticationController implements the  authentication workflow for
  performing the users authentication
  """
  import Ecto.Query
  import Plug.Conn
  alias Daeventbox.User
  alias Daeventbox.Repo

  def signup(conn, params) do
    changeset = User.changeset(%User{}, %{})
    render(conn, "signup.html", changeset: changeset,params: params)
  end

  def login(conn, _params) do
      render conn, "login.html"
  end

  def create_user(user_params) do
  IO.inspect user_params
    required_params =
      Map.new
      |> Map.put("firstname", Format.name(user_params["firstname"]))
      |> Map.put("lastname", Format.name(user_params["lastname"]))
      |> Map.put("zid", Ecto.UUID.generate)
      |> Map.put("email",  Format.email((user_params["email"])))
      |> Map.put("password", user_params["password"])

    changeset = User.changeset_in(%User{}, required_params)
    Repo.insert(changeset)
  end

  def signin(conn,  user_params) do
    email = String.strip(String.downcase(user_params["email"]))
    password = String.strip(user_params["password"])

    time_in_secs_from_now = 86400 * 90
    user = Repo.get_by(User, email: email )

    cond do
      user && Hasher.check_password_hash(user_params["password"], user.password) ->

          conn
           |> delete_resp_cookie("daeventboxuser")
           |> delete_resp_cookie("daeventboxuser")
           |> put_resp_cookie("daeventboxuser", user.zid, max_age: time_in_secs_from_now)
           |> put_resp_cookie("daeventboxmode", "Guest", max_age: time_in_secs_from_now)

           |> put_flash(:info, "Your are now logged in")
           |> redirect(to: "/"  )

      user->
            conn
            |> put_flash(:error,"Wrong password")
            |> render("login.html")

        true ->
          conn
          |> put_flash(:error,"No user found")
          |> render("login.html")
     end
    end

    def logout(conn, user_params) do
      conn
        |> delete_resp_cookie("daeventboxuser")
        |> delete_resp_cookie("daeventboxuser")
        |> delete_resp_cookie("daeventboxmode")
        |> delete_resp_cookie("daeventboxmode")
        |> redirect(to: "/"  )

    end

end
