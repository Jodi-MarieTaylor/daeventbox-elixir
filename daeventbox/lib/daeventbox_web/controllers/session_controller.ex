defmodule DaeventboxWeb.SessionController do
  use DaeventboxWeb, :controller

  alias Daeventbox.User

  action_fallback DaeventboxWeb.FallbackController

    #process register
    def signup(conn, params) do
       case DaeventboxWeb.AuthController.create_user(params) do
         {:ok, user} ->
           verify_email(user)
           case Daeventbox.Auth.login_by_email_and_pass(conn, user.email, params["password"]) do
             {:ok, conn} ->
                 time_in_secs_from_now = 86400 * 90
                 conn
                  |> delete_resp_cookie("daeventboxuser")
                  |> delete_resp_cookie("daeventboxuser")
                  |> put_resp_cookie("daeventboxuser", user.zid, max_age: time_in_secs_from_now)
                  |> put_resp_cookie("daeventboxmode", "Guest", max_age: time_in_secs_from_now)
                  |> put_flash(:info, "Logged in")
                  |> redirect(to: "/")
             {:error, reason, conn} ->
                 conn
                  |> put_flash(:error,"Bad Credentials")
                  |> render("login.html")
           end
          {:error, reason} ->
            IO.inspect reason
            case reason do
              :unauthorized ->
                  conn
                  |> put_flash(:error, "Please Enter a good password and make sure they match")
                  |> redirect(to: "/signup")
              :not_found ->
                  conn
                  |> put_flash(:error, "User does not exist")
                  |> redirect(to: "/signup")
            end
            #render(conn, "signup.html", changeset: changeset, params: params)
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
           |> redirect(to: "/"  )
        {:error, reason, conn} ->
          IO.inspect reason
          case reason do
            :unauthorized ->
                conn
                 |> put_flash(:error, "Bad Credentials")
                 |> redirect(to: "/login")
            :not_found ->
                conn
                 |> put_flash(:error, "User does not exist")
                 |> redirect(to: "/login")
          end
      end
    end

    def reset_password(conn, %{"email" => email}) do
      user = Data.Repo.get_by(Data.Account.User, email: email)
      template = Data.Repo.get(Data.Content.Post, 4079)
      MmsWeb.EmailController.user_email(user, template)
      conn
      |> put_flash(:info, "Please Check Your Email for your reset link")
      |> render("recover.html")
    end

    def recover(conn, params) do
      render(conn, "reset.html", params: params)
    end

    def verify_email(user) do
      DaeventboxWeb.EmailController.user_email(user)
    end

end
