defmodule DaeventboxWeb.AccountController do
  use DaeventboxWeb, :controller

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

  end
  def update_password(conn, params) do

  end

  def close_account(conn, params) do
    # user =  conn.assigns[:current_user]
    # user = Repo.get!(User, user.id)
    # case Repo.delete user do
    #   {:ok, struct}       ->
    #    redirect(to: '/logout')

    #  {:error, changeset} ->
    #    IO.inspect error
    #    redirect(to: '/logout')
    # end

  end
end
