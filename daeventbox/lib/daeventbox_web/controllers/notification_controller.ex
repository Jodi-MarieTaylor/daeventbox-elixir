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

  def notify(conn, params) do
    unseen_ids = Repo.all(from u in User)
    #IO.inspect unseen_ids.inserted_at
    for i <- unseen_ids do
      IO.inspect i.inserted_at
    end
    IO.puts "!!!"
    IO.inspect params
    if params["seen"] == "true" do
        unseen = 0
        IO.puts "llll"
    else
       unseen = 1
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
    render conn, "notifications.html"
  end
end
