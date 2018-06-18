defmodule DaeventboxWeb.RoomController do
  use DaeventboxWeb, :controller

  import Ecto.Query

  alias Daeventbox.Chat
  alias Daeventbox.Repo
  alias Daeventbox.User
  alias Daeventbox.Chat.Room
  alias Daeventbox.Chat.Message
  alias Daeventbox.Facilitator
  def index(conn, _params) do
    rooms = Chat.list_rooms()
    render(conn, "index.html", rooms: rooms)
  end

  def start(conn, params) do
    users = Daeventbox.Repo.all(Daeventbox.User)
    render(conn, "start_chat.html", users: users)
  end

  def new(conn, _params) do
    changeset = Chat.change_room(%Room{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, params) do
    user =
      cond do
        params["zid"] -> Repo.get_by(User, zid: params["zid"])
        params["fuid"] -> Repo.get_by(User, id: params["fuid"])
        true -> nil
      end
    case user do
      nil ->
        conn
        |> redirect(to: "/facilitator/switch")
      recipient ->
          case Chat.get_room(conn.assigns[:current_user].id, recipient.id) do
            {:error, %Ecto.Changeset{} = changeset} ->
                  render(conn, "start_chat.html", changeset: changeset)
            {:ok, room} ->
                facilitator =
                  if conn.cookies["daeventboxmode"] == "Guest" do
                    Repo.get_by(Daeventbox.Facilitator, user_id: user.id )
                  else
                    nil
                  end
                messages = Chat.list_messages(room.id)
                conn
                |> render("room.html", room: room, user: conn.assigns[:current_user], recipient: recipient, messages: messages, facilitator: facilitator)
          end
    end
  end

  def show(conn, %{"id" => id}) do
    room = Chat.get_room!(id)
    user = conn.assigns[:current_user]
    recipient =
      if room.recipient_id == user.id do
        Repo.get(User, room.owner_id)
      else
        Repo.get(User, room.recipient_id)
      end
    messages = Chat.list_messages(room.id)
    facilitator =
        if conn.cookies["daeventboxmode"] == "Guest" do
          Repo.get_by(Daeventbox.Facilitator, user_id: user.id )
        else
          nil
        end
    render(conn, "room.html", room: room, user: user, recipient: recipient, messages: messages, facilitator: facilitator)
  end

  def edit(conn, %{"id" => id}) do
    room = Chat.get_room!(id)
    changeset = Chat.change_room(room)
    render(conn, "edit.html", room: room, changeset: changeset)
  end

  def update(conn, %{"id" => id, "room" => room_params}) do
    room = Chat.get_room!(id)

    case Chat.update_room(room, room_params) do
      {:ok, room} ->
        conn
        |> put_flash(:info, "Room updated successfully.")
        |> redirect(to: room_path(conn, :show, room))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", room: room, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    room = Chat.get_room!(id)
    {:ok, _room} = Chat.delete_room(room)

    conn
    |> put_flash(:info, "Room deleted successfully.")
    |> redirect(to: room_path(conn, :index))
  end

  def view_rooms(conn, params) do
    user = conn.assigns[:current_user]
    rooms =
      if conn.cookies["daeventboxmode"] == "Guest" and conn.cookies["daeventboxuser"] do
        query = from r in Room, join: f in Facilitator, join: u in User, join: m in Message, where: r.owner_id == ^user.id and r.recipient_id == f.user_id and f.user_id == u.id and r.id == m.room_id, distinct: r.id,  order_by: [desc: m.inserted_at], select: [r.id, f.name, m.body, m.inserted_at, u.zid]

        IO.inspect Repo.all(query)
        Repo.all(query)
      else
        query = from r in Room, join: u in User, join: m in Message, where: r.recipient_id == ^user.id and r.owner_id == u.id and r.id == m.room_id, distinct: r.id,  order_by: [desc: m.inserted_at], select: [r.id, u.firstname, m.body, m.inserted_at, u.zid]
        Repo.all(query)
      end
      render conn, "view_messages.html", rooms: rooms
  end

end
