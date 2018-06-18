defmodule DaeventboxWeb.AccountController do
  use DaeventboxWeb, :controller
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]


  import Ecto.Query
  import Plug.Conn
  alias Daeventbox.User
  alias Daeventbox.Repo
  alias Daeventbox.Facilitator
  alias Daeventbox.Ticketdetail
  alias Daeventbox.Registrationdetails
  alias Daeventbox.Ticket
  alias Daeventbox.Registration
  alias Daeventbox.SavedEvent
  alias Daeventbox.LikedEvent
  alias Daeventbox.Ad
  alias Daeventbox.Option
  alias Daeventbox.Action


  def account_settings(conn,params) do
    user =  conn.assigns[:current_user]
    facilitator = Repo.get_by(Facilitator, user_id: user.id)

    render conn, "account_settings.html", user: user, facilitator: facilitator
  end

  def update_email(conn, params) do


  end

  def update_user(conn, params) do
    user = Repo.get!(User, conn.assigns[:current_user].id)
    required_params = %{firstname: params["firstname"], lastname: params["lastname"],
       phone: params["phone"], address: params["address"], bio: params["bio"], alt_email: params["alt_email"], alt_phone: params["alt_phone"] }
      IO.inspect params
    changeset = User.changeset(user, required_params)
    case Repo.update(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Account updated successfully.")
        |> redirect(to: "/account/settings")

      {:error, changeset} ->
        IO.inspect changeset
        conn
        |> put_flash(:error, "Oops error!")
        |> redirect(to: "/account/settings")
    end

  end
  def update_password(conn, params) do

    user = Repo.get!(User, conn.assigns[:current_user].id)


    cond do
      checkpw(params["current_password"], user.password) && params["new_password"] == params["confirm_password"] ->
        required_params = %{password: params["new_password"]}
        changeset = User.updatepass(user, required_params)
        #Repo.update(changeset)
        conn
        |> put_flash(:info, "Password changed successfully")
        |> redirect(to: "/account/settings")
      params["new_password"] != params["confirm_password"] ->
        conn
        |> put_flash(:error, "Passwords Dont Match")
        |> redirect(to: "/account/settings")
      true ->
        conn
        |> put_flash(:error, "Wrong Password")
        |> redirect(to: "/account/settings")

    end
    conn
  end

  def close_account(conn, params) do
     user =  conn.assigns[:current_user]
     user = Repo.get!(User, user.id)
     case Repo.delete user do
       {:ok, struct}       ->
        redirect(conn, to: "/logout")

      {:error, changeset} ->
        IO.inspect changeset
        redirect(conn, to: "/logout")
     end

  end
end
