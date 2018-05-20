defmodule Daeventbox.Action do
  use Ecto.Schema
  import Ecto.Changeset
  alias Daeventbox.Action
  alias Daeventbox.Repo
  alias Daeventbox.User
  schema "actions" do
    field :action, :string
    field :action_id, :integer
    field :event_id, :integer
    field :anonymous_id, :integer
    field :geo, :map
    field :info, :map
    field :ip, :string
    field :meta1, :string
    field :processed, :boolean, default: false
    field :utm_campaign, :string
    field :utm_content, :string
    field :utm_medium, :string
    field :utm_source, :string

    timestamps()
  end

  @doc false
  def changeset(action, attrs) do
    action
    |> cast(attrs, [:event_id, :action_id,:anonymous_id, :action, :utm_source, :utm_medium, :utm_campaign, :utm_content, :ip, :info, :geo, :processed, :meta1])
  end
  """
  def add(conn, action) do
    case action do
      "click" ->
        case Url.find_or_create(conn.params) do
          nil -> nil
          url -> add(conn, action, url.id)
        end
      "track" ->
        case Track.find_or_create(conn.params) do
          nil -> nil
          track -> add(conn, action, track.id)
        end
      "open" -> IO.puts "The action is open"
        add(conn, action, 1)
    end
    conn
  end
  """



   def add(conn, action, action_id, event_id) do
    params = conn.params
    # ^conn.assigns.current_store.id
    user = Repo.get_by(User, zid: conn.cookies["daeventboxuser"])
    IO.inspect user
    if user do
      req = Enum.into(conn.req_headers, %{})
      IO.puts "USER FOUND"
      c = Action.changeset(%Action{}, %{
        action: action,
        action_id: action_id,
        event_id: event_id,
        anonymous_id: user.id,
        ip: req["x-real-ip"] || (conn.remote_ip |> Tuple.to_list |> Enum.join(".")),
        processed: false,
        utm_source: params["utm_source"],
        utm_medium: params["utm_medium"],
        utm_campaign: params["utm_campaign"],
        utm_term: params["utm_term"],
        utm_content: params["utm_content"],
        info: %{
          ua: req["user-agent"],
          referer: params["referer"] || req["referer"],
          cookies: req["cookie"],
          lang: req["accept-language"]
        },
        geo: nil
      })

      case Repo.insert(c) do
        {:ok, _} ->
          IO.puts "-- Action Success --"
        {:error, changeset} ->
          IO.puts "-- Action FAILED --"
          IO.inspect changeset
      end

    else
      IO.puts "-- user not found --"
       req = Enum.into(conn.req_headers, %{})

      c = Action.changeset(%Action{}, %{
        action: action,
        action_id: action_id,
        event_id: event_id,
        anonymous_id: nil,
        ip: req["x-real-ip"] || (conn.remote_ip |> Tuple.to_list |> Enum.join(".")),
        processed: false,
        utm_source: params["utm_source"],
        utm_medium: params["utm_medium"],
        utm_campaign: params["utm_campaign"],
        utm_term: params["utm_term"],
        utm_content: params["utm_content"],
        info: %{
          ua: req["user-agent"],
          referer: params["referer"] || req["referer"],
          cookies: req["cookie"],
          lang: req["accept-language"]
        },
        geo: nil
      })

      case Repo.insert(c) do
        {:ok, _} ->
          IO.puts "-- Action Success --"
        {:error, changeset} ->
          IO.puts "-- Action FAILED --"
          IO.inspect changeset
      end
    end
    conn
  end

end
