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

  def create_user(conn, user_params) do
    hashed_password = Hasher.salted_password_hash(user_params["password"])
    firstname = IO.inspect String.strip(user_params["firstname"]) |> String.split(" ") |> Enum.map( &String.capitalize/1 )|> Enum.join(" ")

    required_params = %{firstname: firstname ,zid: Ecto.UUID.generate, email: String.downcase(user_params["email"]), password: hashed_password, lastname: IO.inspect String.strip(user_params["lastname"]) |> String.split(" ") |> Enum.map( &String.capitalize/1 )|> Enum.join(" ")}
    changeset = User.changeset(%User{}, required_params)
    case Repo.insert(changeset) do
     {:ok, user} ->
       conn
       |> put_flash(:info, "User created successfully.")
       |> redirect(to: "/login" )
      # Webapp.Mailer.send_welcome_email(user.email)
     {:error, changeset} ->
       IO.inspect changeset
       render(conn, "signup.html", changeset: changeset, params: user_params)
     end
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

           |> put_flash(:info, "Logged in")
           |> redirect(to: "/guest"  )

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

