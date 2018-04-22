defmodule DaeventboxWeb.SessionController do
  use DaeventboxWeb, :controller

  alias Daeventbox.User

  action_fallback DaeventboxWeb.FallbackController

    #process register
    def signup(conn, params) do
       case DaeventboxWeb.AuthController.create_user(params) do
         {:ok, user} ->
           case Daeventbox.Auth.login_by_email_and_pass(conn, user.email, params["password"]) do
             {:ok, conn} ->
                 time_in_secs_from_now = 86400 * 90
                 conn
                  |> delete_resp_cookie("daeventboxuser")
                  |> delete_resp_cookie("daeventboxuser")
                  |> put_resp_cookie("daeventboxuser", user.zid, max_age: time_in_secs_from_now)
                  |> put_resp_cookie("daeventboxmode", "Guest", max_age: time_in_secs_from_now)
                  |> put_flash(:info, "Logged in")
                  |> redirect(to: "/guest")
             {:error, reason, conn} ->
                 conn
                  |> put_flash(:error,"Bad Credentials")
                  |> render("login.html")
           end
          {:error, changeset} ->
            render(conn, "signup.html", changeset: changeset, params: params)
       end
    end

    #logout user
    def logout(conn, _) do
      conn
      |> Daeventbox.Auth.logout
      |> Plug.Conn.clear_session
      |> delete_resp_cookie("daeventboxuser")
      |> delete_resp_cookie("daeventboxuser")
      |> delete_resp_cookie("daeventboxmode")
      |> delete_resp_cookie("daeventboxmode")
      |> redirect(to: "/"  )
    end

    #process login
    def signin(conn, %{"email" => email, "password" => password} = params) do
      case Daeventbox.Auth.login_by_email_and_pass(conn, String.trim(String.downcase(email)), password) do
        {:ok, conn} ->
          IO.inspect conn.assigns
          user = conn.assigns[:current_user]
          time_in_secs_from_now = 86400 * 90
          conn
           |> delete_resp_cookie("daeventboxuser")
           |> delete_resp_cookie("daeventboxuser")
           |> put_resp_cookie("daeventboxuser", user.zid, max_age: time_in_secs_from_now)
           |> put_resp_cookie("daeventboxmode", "Guest", max_age: time_in_secs_from_now)

           |> put_flash(:info, "Logged in")
           |> redirect(to: "/guest"  )
        {:error, _reason, conn} ->
          conn
           |> put_flash(:error, "Bad Credentials")
           |> render("login.html")
      end
    end

end
