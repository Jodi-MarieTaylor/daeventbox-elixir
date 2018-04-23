defmodule Daeventbox.Chat do
  @moduledoc """
  The Chat context.
  """

  import Ecto.Query, warn: false
  alias Daeventbox.Repo

  alias Daeventbox.Chat.Message
  alias Daeventbox.Chat.Room

  @doc """
  Returns the list of messages.

  ## Examples

      iex> list_messages()
      [%Message{}, ...]

  """
  def list_messages(room_id) do
    Message
    |> where([m], m.room_id == ^room_id)
    |> order_by([asc: :id])
    |> Repo.all
  end

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id), do: Repo.get!(Message, id)

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{source: %Message{}}

  """
  def change_message(%Message{} = message) do
    Message.changeset(message, %{})
  end

  def create_room(attrs \\ %{}) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert()
  end

  def get_room!(room_id) do
    Repo.get(Room, room_id)
  end

  def get_room(user_id, recipient_id) do
    case room_exits?(user_id, recipient_id) do
      {:error, nil} ->
          case create_room(%{"owner_id" => user_id, "recipient_id" => recipient_id}) do
          {:ok, room} ->
            {:ok, room}
          {:error, %Ecto.Changeset{} = changeset} ->
            {:error, changeset}
          end
      {:ok, room} ->
          {:ok, room}
    end
  end

  def room_exits?(user_id, recipient_id) do
    room =
      Room
      |> where([r], (r.owner_id == ^user_id and r.recipient_id == ^recipient_id) or (r.owner_id == ^recipient_id and r.recipient_id == ^user_id))
      |> Repo.one
    case room do
      nil ->
        {:error, nil}
      room ->
        {:ok, room}
    end
  end
end
