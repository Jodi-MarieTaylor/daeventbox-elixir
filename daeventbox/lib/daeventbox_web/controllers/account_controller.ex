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
  alias Daeventbox.ClosedAccount
  alias Daeventbox.Preference


  def account_settings(conn,params) do
    user =  conn.assigns[:current_user]
    facilitator = Repo.get_by(Facilitator, user_id: user.id)
    preference1 = Repo.get_by(Preference, user_id: user.id, title: "preference1", type: "Email")
    preference2 = Repo.get_by(Preference, user_id: user.id, title: "preference2", type: "Email")
    preference3 = Repo.get_by(Preference, user_id: user.id, title: "preference3", type: "Email")
    preference4 = Repo.get_by(Preference, user_id: user.id, title: "preference4", type: "Email")


    render conn, "account_settings.html", user: user, facilitator: facilitator, preference1: preference1, preference2: preference2, preference3: preference3, preference4: preference4
  end

  def update_email(conn, params) do

    user = Repo.get!(User, conn.assigns[:current_user].id)
    for i <- 1..4 do
      IO.puts "In for loop"
      preference = Repo.get_by(Preference, title: "preference#{i}", user_id: user.id, type: "Email")
      IO.inspect preference
      if preference do
        IO.puts "here1"
        if params["preference#{i}"] do
          required_params = %{status: "Active", preference: params["preference#{i}"]}
          changeset = Preference.changeset(preference, required_params)
          case Repo.update(changeset) do
            {:ok, _preference} ->
              IO.puts "Updated preference#{i}"
            {:error, changeset} ->
              IO.inspect changeset
          end
        else

          case Repo.delete(preference) do
            {:ok, _preference} ->
              IO.puts "Delete preference#{i}"

            {:error, changeset} ->
              IO.inspect changeset

          end
        end
      else
        IO.puts "here2"
        if is_nil(preference) and params["preference#{i}"] do
          IO.puts "here3"
          required_params = %{user_id: user.id, preference: params["preference#{i}"], type: "Email", status: "Active" , title: "preference#{i}"}
          changeset = Preference.changeset(%Preference{}, required_params)

            case Repo.insert(changeset) do
              {:ok, _preference} -> IO.puts "Preference Added"
              {:error, reason} -> IO.inspect reason
            end
        end
      end
    end

    conn
    |> put_flash(:info, "Account updated successfully.")
    |> redirect(to: "/account/settings")

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
        Repo.update(changeset)
        IO.puts "password changed"
        conn
        |> put_flash(:info, "Password changed successfully")
        |> redirect(to: "/account/settings")
      params["new_password"] != params["confirm_password"] ->
        IO.puts "passwords dont match"
        conn
        |> put_flash(:error, "Passwords Dont Match")
        |> redirect(to: "/account/settings")
      true ->
        IO.puts "wrong password"
        conn
        |> put_flash(:error, "Wrong Password")
        |> redirect(to: "/account/settings")

    end
    conn
  end

  def close_account(conn, params) do
     user =  conn.assigns[:current_user]
     user = Repo.get!(User, user.id)
      IO.puts "Reason is"
      IO.inspect params["reason"]
     facilitator = Repo.get_by(Facilitator, user_id: user.id)
     required_params =
     if !is_nil(facilitator) do
       %{user_name: user.firstname <> " " <> user.lastname, reason: params["reason"], facilitator: facilitator.name}
     else
        %{user_name: user.firstname <> " " <> user.lastname, reason: params["reason"]}

     end
     changeset = Daeventbox.ClosedAccount.changeset(%Daeventbox.ClosedAccount{}, required_params)

    case Repo.insert(changeset) do
      {:ok, _closedaccounts} -> IO.puts "Closed Account Reason Added"
      {:error, reason} -> IO.inspect reason
    end
     case Repo.delete user do
       {:ok, struct}       ->
         if !is_nil(facilitator) do
          case Repo.delete facilitator do
            {:ok, struct}       ->
              redirect(conn, to: "/logout")

            {:error, changeset} ->
              IO.inspect changeset
              redirect(conn, to: "/logout")
          end
        else
          redirect(conn, to: "/logout")
        end

      {:error, changeset} ->
        IO.inspect changeset
        redirect(conn, to: "/logout")
     end

  end
end
