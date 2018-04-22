defmodule Daeventbox.ChatTest do
  use Daeventbox.DataCase

  alias Daeventbox.Chat

  describe "messages" do
    alias Daeventbox.Chat.Message

    @valid_attrs %{"": 42, body: "some body", "recipient_id,": "some recipient_id,", "sender_id,": "some sender_id,"}
    @update_attrs %{"": 43, body: "some updated body", "recipient_id,": "some updated recipient_id,", "sender_id,": "some updated sender_id,"}
    @invalid_attrs %{"": nil, body: nil, "recipient_id,": nil, "sender_id,": nil}

    def message_fixture(attrs \\ %{}) do
      {:ok, message} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Chat.create_message()

      message
    end

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Chat.list_messages() == [message]
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Chat.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      assert {:ok, %Message{} = message} = Chat.create_message(@valid_attrs)
      assert message. == 42
      assert message.body == "some body"
      assert message.recipient_id, == "some recipient_id,"
      assert message.sender_id, == "some sender_id,"
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chat.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      assert {:ok, message} = Chat.update_message(message, @update_attrs)
      assert %Message{} = message
      assert message. == 43
      assert message.body == "some updated body"
      assert message.recipient_id, == "some updated recipient_id,"
      assert message.sender_id, == "some updated sender_id,"
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Chat.update_message(message, @invalid_attrs)
      assert message == Chat.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Chat.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Chat.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Chat.change_message(message)
    end
  end

  describe "messages" do
    alias Daeventbox.Chat.Message

    @valid_attrs %{body: "some body", recipient_id: 42, sender_id: 42}
    @update_attrs %{body: "some updated body", recipient_id: 43, sender_id: 43}
    @invalid_attrs %{body: nil, recipient_id: nil, sender_id: nil}

    def message_fixture(attrs \\ %{}) do
      {:ok, message} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Chat.create_message()

      message
    end

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Chat.list_messages() == [message]
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Chat.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      assert {:ok, %Message{} = message} = Chat.create_message(@valid_attrs)
      assert message.body == "some body"
      assert message.recipient_id == 42
      assert message.sender_id == 42
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chat.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      assert {:ok, message} = Chat.update_message(message, @update_attrs)
      assert %Message{} = message
      assert message.body == "some updated body"
      assert message.recipient_id == 43
      assert message.sender_id == 43
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Chat.update_message(message, @invalid_attrs)
      assert message == Chat.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Chat.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Chat.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Chat.change_message(message)
    end
  end

  describe "rooms" do
    alias Daeventbox.Chat.Room

    @valid_attrs %{name: "some name", owner_id: 42}
    @update_attrs %{name: "some updated name", owner_id: 43}
    @invalid_attrs %{name: nil, owner_id: nil}

    def room_fixture(attrs \\ %{}) do
      {:ok, room} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Chat.create_room()

      room
    end

    test "list_rooms/0 returns all rooms" do
      room = room_fixture()
      assert Chat.list_rooms() == [room]
    end

    test "get_room!/1 returns the room with given id" do
      room = room_fixture()
      assert Chat.get_room!(room.id) == room
    end

    test "create_room/1 with valid data creates a room" do
      assert {:ok, %Room{} = room} = Chat.create_room(@valid_attrs)
      assert room.name == "some name"
      assert room.owner_id == 42
    end

    test "create_room/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chat.create_room(@invalid_attrs)
    end

    test "update_room/2 with valid data updates the room" do
      room = room_fixture()
      assert {:ok, room} = Chat.update_room(room, @update_attrs)
      assert %Room{} = room
      assert room.name == "some updated name"
      assert room.owner_id == 43
    end

    test "update_room/2 with invalid data returns error changeset" do
      room = room_fixture()
      assert {:error, %Ecto.Changeset{}} = Chat.update_room(room, @invalid_attrs)
      assert room == Chat.get_room!(room.id)
    end

    test "delete_room/1 deletes the room" do
      room = room_fixture()
      assert {:ok, %Room{}} = Chat.delete_room(room)
      assert_raise Ecto.NoResultsError, fn -> Chat.get_room!(room.id) end
    end

    test "change_room/1 returns a room changeset" do
      room = room_fixture()
      assert %Ecto.Changeset{} = Chat.change_room(room)
    end
  end

  describe "messages" do
    alias Daeventbox.Chat.Message

    @valid_attrs %{body: "some body", force: "some force", recipient_id: 42, room_id: 42, sender_id: 42}
    @update_attrs %{body: "some updated body", force: "some updated force", recipient_id: 43, room_id: 43, sender_id: 43}
    @invalid_attrs %{body: nil, force: nil, recipient_id: nil, room_id: nil, sender_id: nil}

    def message_fixture(attrs \\ %{}) do
      {:ok, message} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Chat.create_message()

      message
    end

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Chat.list_messages() == [message]
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Chat.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      assert {:ok, %Message{} = message} = Chat.create_message(@valid_attrs)
      assert message.body == "some body"
      assert message.force == "some force"
      assert message.recipient_id == 42
      assert message.room_id == 42
      assert message.sender_id == 42
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chat.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      assert {:ok, message} = Chat.update_message(message, @update_attrs)
      assert %Message{} = message
      assert message.body == "some updated body"
      assert message.force == "some updated force"
      assert message.recipient_id == 43
      assert message.room_id == 43
      assert message.sender_id == 43
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Chat.update_message(message, @invalid_attrs)
      assert message == Chat.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Chat.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Chat.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Chat.change_message(message)
    end
  end
end
