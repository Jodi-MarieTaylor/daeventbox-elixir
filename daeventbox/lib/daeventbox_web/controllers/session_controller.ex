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
      user = Repo.get_by(User, email: email)
      case user do
        nil ->
          conn
          |> put_flash(:error, "Email Not Found.")
          |> render("recover.html")
        _ ->
            DaeventboxWeb.EmailController.generic_email(user, %{"template" => "reset_password.html", "title" => "Password Reset"})
#          template = Repo.get_by(Data.Content.Template, site_id: 1, permalink: "/password-reset")
#          MmsWeb.EmailController.user_email(user, template)
          conn
          |> put_flash(:info, "Please Check Your Email for your reset link")
          |> render("recover.html")
      end
    end

    def reset_password(conn, params) do
      render(conn, "recover.html", params: params)
    end

    def recover(conn, %{"password" => password, "token" => token}) do
      user = Repo.get_by(User, zid: token)
      IO.inspect user
      if password && password != "" do
        if user do
          case User.updatepass(user, %{"password" => password}) do
            {:ok, user} ->
              conn
              |> put_flash(:info, "Successfully Reset Password")
              |> redirect(to: "/login")
            {:error, reason} ->
              conn
              |> put_flash(:error, "Failed To Update Password")
              |> redirect(to: "/recover")
          end
        else
          conn
          |> put_flash(:error, "This password reset token has expired.")
          |> redirect(to: "/recover")
        end
      else
        conn
        |> put_flash(:error, "Failed To Update Password Due To Empty Submission")
        |> redirect(to: "/recover")
      end
    end

    def recover(conn, params) do
      case Repo.get_by(User, zid: params["key"]) do
        nil ->
          conn
          |> put_flash(:error, "This password reset token has expired.")
          |> redirect(to: "/recover")
        _ ->
          render(conn, "reset.html", params: params)
      end
    end

    def recover(conn, params) do
      render(conn, "reset.html", params: params)
    end

    def verify_email(user) do
      DaeventboxWeb.EmailController.user_email(user)
    end


end
