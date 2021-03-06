defmodule DaeventboxWeb.NotificationController do
  use DaeventboxWeb, :controller

  alias Daeventbox.Event
  import Ecto.Query
  import Plug.Conn
  alias Daeventbox.User
  alias Daeventbox.Repo
  alias Daeventbox.Ticketdetail
  alias Daeventbox.Registrationdetails
  alias Daeventbox.Facilitator
  alias Daeventbox.Ticket
  alias Daeventbox.Registration
  alias Daeventbox.SavedEvent
  alias Daeventbox.LikedEvent
  alias Daeventbox.Action
  alias Daeventbox.Notification

  def add_from_facilitator(conn, params) do
    facilitator = Repo.get(Facilitator, params["facilitator_id"])
    all_interested_users_query = from u in User, join: l in LikedEvent, join: s in SavedEvent, join: t in Ticket, where: t.event_id == ^params["event_id"] and s.event_id == ^params["event_id"] and l.event_id == ^params["event_id"] and l.user_id == u.id or s.user_id == u.id or t.user_id == t.id, distinct: u.id
    # for all the users that like, save or are attending this event
    users = Repo.all(all_interested_users_query)
    for user <- users do
      required_params = %{type: "Event Announcement" , sent_by: "Facilitator", from: facilitator.name, seen: false, user_id: user.id, facilitator_id: params["facilitator_id"], event_id: params["event_id"], message: params["message"], recipient: "Guests" }
      changeset = Notification.changeset(%Notification{}, required_params)
      case Repo.insert(changeset) do
            {:ok, _notification} ->
              IO.puts "Added Notification"

              conn
              |> put_flash(:info, "Announcement send.")
              |> redirect(to: "/facilitator/manage")

            {:error, reason} -> IO.inspect reason
      end
    end
  end

  def add_from_admin(recipient, type, message ) do
    # for all the users that like, save or are attending this event
    users =
      if recipient == "Facilitators" do
        Repo.all(from f in Facilitator)
      else
        Repo.all(from u in User)
      end
    for user <- users do
      required_params = %{type: type , sent_by: "Daeventbox Admin", from: "Daeventbox", seen: false, user_id: user.id, facilitator_id: 0, event_id: nil, message: message, recipient: recipient }
      changeset = Notification.changeset(%Notification{}, required_params)
      case Repo.insert(changeset) do
            {:ok, _notification} ->
              IO.puts "Added Notification"

            {:error, reason} -> IO.inspect reason
      end
    end
  end

  def notify(conn, params) do
    user = conn.assigns[:current_user]
    unseen_ids =
      if conn.cookies["daeventboxmode"] == "Guest" do
        Repo.all(from n in Notification, where: n.seen == false and n.user_id == ^user.id )
      else
        Repo.all(from n in Notification, where: n.seen == false and n.user_id == ^user.id and n.recipient == "Facilitators" )
      end
    #IO.inspect unseen_ids.inserted_at
    for i <- unseen_ids do
      IO.inspect i.inserted_at
    end


    if params["seen"] == "true" do
        unseen = 0
        IO.puts "llll"
        for uns <- unseen_ids do
          required_params = %{seen: true}
          changeset = Notification.changeset(uns, required_params)
          case Repo.update(changeset) do
            {:ok, _user} ->
             IO.puts "Notifications all seen"
             conn
            {:error, changeset} ->
              IO.puts "Notifications not seen"
              IO.inspect changeset
              conn
          end
        end

    else
       unseen = Enum.count(unseen_ids)
    end
    IO.inspect unseen
    notification_msg = "   <li>
        <p>NOTIFICATIONS <span class='new badge'>4</span></p>
      </li>
      <li class='divider'></li>
      <li>
        <a href=''><i class='mdi-action-add-shopping-cart'></i> A new order has been placed!</a>
        <time class='media-meta' datetime='2015-06-12T20:50:48+08:00'>2 hours ago</time>
      </li>
      <li>
        <a href=''><i class='mdi-action-settings'></i> Settings updated</a>
        <time class='media-meta' datetime='2015-06-12T20:50:48+08:00'>4 days ago</time>
      </li>"
      data =  %{"notification"   => "<li>
      <p><b>Notifications</b> <span class='new badge'>4</span></p>
        </li>
        <li>
          <a href=''><i class='mdi-action-add-shopping-cart'></i>Chanel 1- This is life</a>
          <time class='media-meta' datetime='2015-06-12T20:50:48+08:00'>2 hours ago</time>
        </li>
        <li>
          <a href=''><i class='mdi-action-add-shopping-cart'></i> A new order has been placed!</a>
          <time class='media-meta' datetime='2015-06-12T20:50:48+08:00'>2 hours ago</time>
        </li>
        <li>
          <a href=''><i class='mdi-action-add-shopping-cart'></i> A new order has been placed!</a>
          <time class='media-meta' datetime='2015-06-12T20:50:48+08:00'>2 hours ago</time>
        </li>" ,
        "unseen_notification" => unseen }
       json(conn, data)
  end

  def notifications(conn, params) do
    per_page = params["page_size"] || 9
    page = params["page"] || "1"
    user = Repo.get!(User, conn.assigns[:current_user].id)
    query =
      if conn.cookies["daeventboxmode"] == "Facilitator" do
        from n in Notification, where: n.user_id == ^user.id and n.recipient == "Facilitators" and  is_nil(n.hide),  order_by: [desc: n.inserted_at]

      else
        from n in Notification, where: n.user_id == ^user.id and n.recipient == "Guests" and is_nil(n.hide) ,  order_by: [desc: n.inserted_at]


      end


    notifications_num = Repo.all(query) |> Enum.count
    pages = notifications_num / per_page
    pages = Float.ceil(pages) |> Kernel.round
    notifications =  Paginate.query(query, per_page, page)
    render conn, "notifications.html", notifications: notifications,  page_count: pages, page: page
  end

  def notification_delete_for_user(conn, params) do
      notification = Repo.get!(Notification, params["notification_id"])
      required_params = %{hide: true}
      changeset = Notification.changeset(notification, required_params)
      case Repo.update(changeset) do
        {:ok, _notification} ->
          IO.puts "Notifications deleted/hiden"
          redirect(conn, to: "/notify")
        {:error, changeset} ->
          IO.puts "Error ! Notifications deleted/hiden"
          IO.inspect changeset
          redirect(conn, to: "/notify")
      end
  end


 def filter(conn, params) do
    cond do
      params["date"] == "asc" ->
        user = Repo.get!(User, conn.assigns[:current_user].id)
        query =
          if conn.cookies["daeventboxmode"] == "Facilitator" do
            from n in Notification, where: n.user_id == ^user.id and n.recipient == "Facilitators", order_by: [asc: n.inserted_at]
          else
            from n in Notification, where: n.user_id == ^user.id,  order_by: [desc: n.inserted_at]

          end
        notifications = Repo.all(query)
        render conn, "notifications.html", notifications: notifications

      params["date"] == "desc" ->
        user = Repo.get!(User, conn.assigns[:current_user].id)
        query =
          if conn.cookies["daeventboxmode"] == "Facilitator" do
            from n in Notification, where: n.user_id == ^user.id and n.recipient == "Facilitators", order_by: [desc: n.inserted_at]
          else
            from n in Notification, where: n.user_id == ^user.id,  order_by: [desc: n.inserted_at]

          end
        notifications = Repo.all(query)
        render conn, "notifications.html", notifications: notifications

    end
 end

end
