defmodule DaeventboxWeb.MessageController do
  use DaeventboxWeb, :controller

  import Ecto.Query
  alias Daeventbox.Chat
  alias Daeventbox.Chat.Message

  def index(conn, _params) do
    messages = Chat.list_messages()
    render(conn, "index.html", messages: messages)
  end

  def new(conn, _params) do
    changeset = Chat.change_message(%Message{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"message" => message_params}) do
    sender_id = conn.assigns[:current_user].id
    IO.inspect room = Daeventbox.Repo.get(Daeventbox.Chat.Room, message_params["room_id"])
    IO.inspect recipient_id = ([room.recipient_id, room.owner_id] -- [sender_id]) |> Enum.at(0)
    message_params =
      message_params
      |> Map.put("recipient_id", recipient_id)
      |> Map.put("sender_id", sender_id)
      |> Map.put("seen", false)
    case Chat.create_message(message_params) do
      {:ok, message} ->
        IO.inspect message
        conn
        |> put_flash(:info, "Message sent.")
        |> redirect(to: "/chat/room/#{room.id}")
      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect changeset
        conn
        |> put_flash(:error, "Failed to send message.")
        |> redirect(to: "/chat/room/#{room.id}")
    end
  end

  def show(conn, %{"id" => id}) do
    message = Chat.get_message!(id)
    render(conn, "show.html", message: message)
  end

  def edit(conn, %{"id" => id}) do
    message = Chat.get_message!(id)
    changeset = Chat.change_message(message)
    render(conn, "edit.html", message: message, changeset: changeset)
  end

  def update(conn, %{"id" => id, "message" => message_params}) do
    message = Chat.get_message!(id)
    message_params =
      message_params
      |> Map.put("seen", true)
    case Chat.update_message(message, message_params) do
      {:ok, message} ->
        conn
        |> put_flash(:info, "Message updated successfully.")
        |> redirect(to: message_path(conn, :show, message))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", message: message, changeset: changeset)
    end

  end

  def check(conn, params) do
    user = Repo.get!(User, conn.assigns[:current_user].id)
    count =
      if conn.cookies["daeventboxmode"] == "Guest" do
        Repo.all(from m in Message, where:  is_nil(m.seen) and  m.owner_id == ^user.id) |> Enum.count
      else
        Repo.all(from m in Message, where: m.recipient_id == ^user.id and m.seen == false ) |> Enum.count

      end

    data =  %{ "unseen_messages" => count }
    json(conn, data)
  end

  def delete(conn, %{"id" => id}) do
    message = Chat.get_message!(id)
    {:ok, _message} = Chat.delete_message(message)

    conn
    |> put_flash(:info, "Message deleted successfully.")
    |> redirect(to: message_path(conn, :index))
  end
end
