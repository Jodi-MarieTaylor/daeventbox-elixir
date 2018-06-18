defmodule DaeventboxWeb.FacilitatorController do
  use DaeventboxWeb, :controller
alias Elixlsx.{Workbook, Sheet}
  @header [
      "Name",
      "Email",
      "Date",
      "Type",
      "Quantity",
      "Total Paid"
    ]
  alias Daeventbox.Event
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
  alias Daeventbox.Notification
  alias Daeventbox.Comment
  alias Daeventbox.Follower

  def index(conn, _params) do
    render conn, "index.html"
  end

  def switch(conn, _params) do
    #if first first time being facilitator (to check - check if its in facilitator table)
    current_user = Repo.get_by(User, zid: conn.cookies["daeventboxuser"])
    facilitator = Repo.get_by(Facilitator, user_id: current_user.id)
    if facilitator do
      redirect conn, to: "/facilitator"
    else
      render conn, "switchfirsttime.html"
    end
  end

  def changemode(conn, params) do
    if conn.cookies["daeventboxmode"] == "Facilitator" and conn.cookies["daeventboxuser"] do
      time_in_secs_from_now = 86400 * 90
      conn
        |> delete_resp_cookie("daeventboxmode")
        |> delete_resp_cookie("daeventboxmode")
        |> put_resp_cookie("daeventboxmode", "Guest", max_age: time_in_secs_from_now)
        |> redirect(to: "/"  )
    else
      time_in_secs_from_now = 86400 * 90
      conn
        |> delete_resp_cookie("daeventboxmode")
        |> delete_resp_cookie("daeventboxmode")
        |> put_resp_cookie("daeventboxmode", "Facilitator", max_age: time_in_secs_from_now)
        |> redirect(to: "/facilitator/switch"  )
    end

  end

  def manage(conn, params) do
    user_id = conn.assigns[:current_user].id
    events = filter(params, conn.assigns[:current_user].id)
    render conn, "manage.html", events: events
  end

  def filter(params, user_id) do
    IO.puts "!!!!!!!!!!!!!!!!!!!!!!!@@#"
    IO.inspect params
    facilitator = Repo.get_by(Facilitator, user_id: user_id)
    events =
    Event
    |> where([e], e.facilitator_id == ^facilitator.id)

    events =
      if params["title_search"] != "" and params["title_search"] != nil do
        events
          |> where([e], fragment("? ~* ?", e.title, ^params["title_search"]))
      else
        events
      end
    events =
      if params["content_search"] != "" and params["content_search"] != nil do
        IO.inspect "look here work"
        events
          |> where([e], fragment("? ~* ?", e.description, ^params["content_search"]))
      else
        events
      end
    events =
    if params["category_search"] != "" and params["category_search"] != nil do
      events
        |> where([e], fragment("? ~* ?", e.category, ^params["category_search"]))
    else
      events
    end

    events =
      if params["type_search"] != "" and params["type_search"] != nil do
        events
          |> where([e], fragment("? ~* ?", e.type, ^params["type_search"]))
      else
        events
      end

    #events =
    #  if params["location_search"] != "" and params["location_search"] != nil do
     #   events
    #      |> where([e], fragment("? ~* ?", e.location_info.parish, ^params["location_search"]))
    #  else
    #    events
    #  end

      events =
        if params["date_sort"] == "asc" do
           events
             |> order_by([e], asc: e.inserted_at)
        else
          events
        end

    #events =
    #  if params["likes_search"] != "" and params["likes_search"] != nil do
    #    likes = String.split(params["likes_search"], "-")
    #  IO.inspect  ulikes = Enum.at(likes, 0)
    #  IO.inspect  olikes = Enum.at(likes, 1)
    #    events
    #      |> where([p], p.likes > ^ulikes and p.likes < ^olikes)
    #  else
    #    events
    #  end

    #events =
    #    if params["ratings_sort"] == "desc" do
    #     events
    #      |> order_by([p], asc: p.likes)
    #    else
    #      events
    #    end

    #events =
    #      if params["ratings_sort"] == "asc" do
    #        events
    #        |> order_by([p], desc: p.likes)
    #  else
    #    events
    #  end
  IO.inspect events
	events =
		events
		|> Repo.all

  IO.puts "Last stop events"
  IO.inspect events

  end

  def eventsearch(conn, params) do

    current_user = Repo.get_by(User, zid: conn.cookies["daeventboxuser"])

    ctitle = String.strip(params["search_text"]) |> String.split(" ") |> Enum.map( &String.capitalize/1 )|> Enum.join(" ")
    query = from e in Event, where:  fragment("? ~* ?", e.title, ^ctitle)
    events =  Repo.all(query)
    render conn, "manage.html", events: events

  end

  def dashboard(conn, params) do
    current_user = Repo.get_by(User, zid: conn.cookies["daeventboxuser"])
    event = Repo.get!(Event, params["id"])

    #event = Repo.get!(Event, params["id"])
    IO.inspect event.type

    cond do
      event.type =="paid" and event.admission_type == "ticket" ->
          event_details = %{}
          current_user = Repo.get_by(User, zid: conn.cookies["daeventboxuser"])
          facilitator = Repo.get_by(Facilitator, user_id: current_user.id)
          ticket_query = from t in Ticket, where: t.event_id == ^event.id
          tickets = Repo.all(ticket_query)
          new_tickets_query = from t in Ticket, where: t.event_id == ^event.id and t.inserted_at >  datetime_add(^Ecto.DateTime.utc, 0, "week")
          new_tickets = Repo.all(new_tickets_query)
          likes_query = from l in LikedEvent, where: l.event_id == ^event.id
          likes = Repo.all(likes_query)
          ad_query = from a in Ad, join: e in Event, join: o in Option,  where: a.event_id == e.id and a.option_id == o.id and a.facilitator_id== ^facilitator.id and a.event_id == ^event.id, select: [a.name, e.title, a.inserted_at, o.position, a.days, a.price, a.id, a.image_url]
          ads = Repo.all(ad_query)
          views_query = from a in Action, where: a.event_id ==  ^event.id and a.action == "viewed-event-details"
          views = Repo.all(views_query)
          notifications_query = from n in Notification, where: n.event_id == ^event.id and n.facilitator_id == ^facilitator.id, distinct: n.message, limit: 3
          notifications = Repo.all(notifications_query)
          comments = Repo.all(from c in Comment, where: c.event_id == ^event.id, limit: 5)
          render conn, "dashboard1.html", comments: comments, views: views, likes: likes, event_details: event_details, ads: ads,  event: event, facilitator: facilitator, tickets: tickets, new_tickets: new_tickets, notifications: notifications

      event.type == "paid" and event.admission_type =="registration" ->
        event_details = %{}
        current_user = Repo.get_by(User, zid: conn.cookies["daeventboxuser"])
        facilitator = Repo.get_by(Facilitator, user_id: current_user.id)
        registration_query = from r in Registration, where: r.event_id == ^event.id
        registrations = Repo.all(registration_query)
        new_registrations_query = from r in Registration, where: r.event_id == ^event.id and r.inserted_at >  datetime_add(^Ecto.DateTime.utc, 0, "week")
        new_registrations = Repo.all(new_registrations_query)
        ad_query = from a in Ad, join: e in Event, join: o in Option,  where: a.event_id == e.id and a.option_id == o.id and a.event_id == ^event.id and a.facilitator_id== ^facilitator.id , select: [a.name, e.title, a.inserted_at, o.position, a.days, a.price, a.id, a.image_url]
        ads = Repo.all(ad_query)
        likes_query = from l in LikedEvent, where: l.event_id == ^event.id
        likes = Repo.all(likes_query)
        views_query = from a in Action, where: a.event_id ==  ^event.id and a.action == "viewed-event-details"
        views = Repo.all(views_query)
        notifications_query = from n in Notification, where: n.event_id == ^event.id and n.facilitator_id == ^facilitator.id, distinct: n.message, limit: 3
        notifications = Repo.all(notifications_query)
        comments = Repo.all(from c in Comment, where: c.event_id == ^event.id, limit: 5)
        render conn, "dashboard2.html", comments: comments, views: views, likes: likes, event_details: event_details, event: event, facilitator: facilitator, registrations: registrations, new_registrations: new_registrations, ads: ads, notifications: notifications

      event.type == "free" and event.admission_type == "registration" ->
        event_details = %{}
        current_user = Repo.get_by(User, zid: conn.cookies["daeventboxuser"])
        facilitator = Repo.get_by(Facilitator, user_id: current_user.id)
        registration_query = from r in Registration, where: r.event_id == ^event.id
        registrations = Repo.all(registration_query)
        new_registrations_query = from r in Registration, where: r.event_id == ^event.id and r.inserted_at >  datetime_add(^Ecto.DateTime.utc, 0, "week")
        new_registrations = Repo.all(new_registrations_query)
        likes_query = from l in LikedEvent, where: l.event_id == ^event.id
        likes = Repo.all(likes_query)
        ad_query = from a in Ad, join: e in Event, join: o in Option,  where: a.event_id == e.id and a.option_id == o.id and a.facilitator_id== ^facilitator.id and a.event_id == ^event.id, select: [a.name, e.title, a.inserted_at, o.position, a.days, a.price, a.id, a.image_url]
        ads = Repo.all(ad_query)
        views_query = from a in Action, where: a.event_id ==  ^event.id and a.action == "viewed-event-details"
        views = Repo.all(views_query)
        notifications_query = from n in Notification, where: n.event_id == ^event.id and n.facilitator_id == ^facilitator.id, distinct: n.message, limit: 3
        notifications = Repo.all(notifications_query)
        comments = Repo.all(from c in Comment, where: c.event_id == ^event.id, limit: 5)
        render conn, "dashboard3.html", comments: comments, views: views, likes: likes, event_details: event_details, event: event, facilitator: facilitator, registrations: registrations, new_registrations: new_registrations, ads: ads, notifications: notifications

      event.type == "free" ->
        event_details = %{}
        facilitator = Repo.get_by(Facilitator, user_id: current_user.id)
        likes_query = from l in LikedEvent, where: l.event_id == ^event.id
        likes = Repo.all(likes_query)
        views_query = from a in Action, where: a.event_id ==  ^event.id and a.action == "viewed-event-details"
        views = Repo.all(views_query)
        ad_query = from a in Ad, join: e in Event, join: o in Option,  where: a.event_id == e.id and a.option_id == o.id and a.facilitator_id== ^facilitator.id , select: [a.name, e.title, a.inserted_at, o.position, a.days, a.price, a.id, a.image_url]
        ads = Repo.all(ad_query)
        notifications_query = from n in Notification, where: n.event_id == ^event.id and n.facilitator_id == ^facilitator.id, distinct: n.message, limit: 5
        notifications = Repo.all(notifications_query)
        comments = Repo.all(from c in Comment, where: c.event_id == ^event.id, limit: 5)
        render conn, "dashboard4.html", comments: comments, ads: ads, views: views, event_details: event_details, event: event, notifications: notifications

    end
  end

  def profile_form(conn, params) do
    render conn, "profile_form.html"
  end

  def profile(conn, params) do
    facilitator =
    if is_nil(params["id"]) do
      current_user = Repo.get_by(User, zid: conn.cookies["daeventboxuser"])
      Repo.get_by(Facilitator, user_id: current_user.id)
    else
      Repo.get_by(Facilitator, id: params["id"])
    end
    visitor =
      if is_nil(params["id"]) do
        false
      else
        true
      end
    followers = Repo.all( from f in Follower, where: f.facilitator_id == ^facilitator.id)

    render conn, "profile.html",  facilitator: facilitator, visitor: visitor, followers: followers
  end

  def profile_preview(conn,params) do
    current_user = Repo.get_by(User, zid: conn.cookies["daeventboxuser"])
    facilitator = Repo.get_by(Facilitator, id: current_user.id)

    render conn, "profile_preview.html", facilitator: facilitator
  end

  def add_facilitator(conn, params) do
    image_url =
      if params["image_url"] == "" or is_nil(params["image_url"]) do
        "https://s3.us-east-2.amazonaws.com/daeventboximages/06682d8564b4/file/icon-user.png"
      else
        params["image_url"]
      end
    required_params = %{name: params["name"], about: params["about"], website_link: params["website"], fb_link: params["facebook"], insta_link: params["instagram"],
    twitter_link: params["twitter"], image: params["image"], image_url: image_url, facilitator_email: params["email"], facilitator_phone: params["phone"],
    facilitator_address: params["address"], facilitator_contact: params["contactname"], facilitator_zid:  Ecto.UUID.generate,user_id: conn.assigns[:current_user].id}
      IO.inspect params
    changeset = Facilitator.changeset(%Facilitator{}, required_params)
    case Repo.insert(changeset) do
      {:ok, _facilitator} ->
        conn
        |> put_flash(:info, "Event updated successfully.")
        |> redirect(to: "/facilitator")

      {:error, changeset} ->
        IO.inspect changeset
        conn
        |> put_flash(:error, "Oops error! Please try again")
        |> render "profile_form.html"
    end

  end
  def profile_edit(conn, params) do
    current_user = Repo.get_by(User, zid: conn.cookies["daeventboxuser"])
    facilitator = Repo.get_by(Facilitator, user_id: current_user.id)

    render conn, "profile_edit_form.html", facilitator: facilitator
  end
  def update_profile(conn, params) do
    current_user = Repo.get_by(User, zid: conn.cookies["daeventboxuser"])
    facilitator = Repo.get_by(Facilitator, user_id: current_user.id)
    {:ok, resp} = Utils.AmazonS3.file_upload(params)

    IO.inspect resp
    image_url = convert_url(resp.url)
    required_params = %{name: params["name"], about: params["about"], website_link: params["website"], fb_link: params["facebook"], insta_link: params["instagram"],
    twitter_link: params["twitter"], image: params["image"], image_url: image_url, facilitator_email: params["email"], facilitator_phone: params["phone"],
    facilitator_address: params["address"], facilitator_contact: params["contactname"]}
      IO.inspect params
    changeset = Facilitator.changeset(facilitator, required_params)

    case Repo.update(changeset) do
      {:ok, _facilitator} ->
        conn
        |> put_flash(:info, "Event updated successfully.")
        |> redirect(to: "/facilitator")

      {:error, changeset} ->
        IO.inspect changeset

        conn
        |> put_flash(:error, "Oops error!")
        |> redirect(to: "/facilitator/profile/edit")
    end
  end


  def home(conn, params) do
    render conn, "home.html", events: nil
  end
  def export(conn, params) do
    event = Repo.get!(Event, params["id"])

    if event.type != "registration" do

      registration_query = from r in Registration, where: r.event_id == ^event.id
      registrations = Repo.all(registration_query)

      report_generator(registrations)
      |> Elixlsx.write_to("report.xlsx")
      IO.puts "JOKE"
      conn
      |> put_resp_content_type("text/xlsx")
      |> put_resp_header("content-disposition", ~s[attachment; filename="report.xlsx"])
      |> send_file(200, "report.xlsx")
    else
      ticket_query = from t in Ticket, where: t.event_id == ^event.id
      tickets = Repo.all(ticket_query)
      report_generator(tickets)
      |> Elixlsx.write_to("report.xlsx")
      |> elem(1)
      IO.puts "JOKE"
      conn
      |> put_resp_content_type("text/xlsx")
      |> put_resp_header("content-disposition", ~s[attachment; filename="report.xlsx"])
      |> send_file(200, "report.xlsx")
    end
  end

  def follow(conn, params) do
    user = Repo.get_by(User, zid: conn.cookies["daeventboxuser"])
    facilitator = Repo.get!(Facilitator, params["facilitator_id"])
    required_params = %{ user_id: user.id, facilitator_id: facilitator.id }
    changeset = Follower.changeset(%Follower{}, required_params)

    case Repo.insert(changeset) do
      {:ok, _facilitator} ->
        conn
        |> put_flash(:info, "Followed successfully.")
        |> redirect(to: "/event/facilitators")

      {:error, changeset} ->
        IO.inspect changeset
        conn
        |> put_flash(:error, "Oops error! Please try again")
    end

  end
  def unfollow(conn, params) do
    user = Repo.get_by(User, zid: conn.cookies["daeventboxuser"])
    facilitator = Repo.get!(Facilitator, params["facilitator_id"])
    follower = Repo.get_by(Follower, user_id: user.id, facilitator_id: facilitator.id)

    case Repo.delete(follower) do
      {:ok, _facilitator} ->
        conn
        |> put_flash(:info, "Unfollowed successfully.")
        |> redirect(to: "/event/facilitators")

      {:error, changeset} ->
        IO.inspect changeset
        conn
        |> put_flash(:error, "Oops error! Please try again")
        |> render "profile_form.html"
    end

  end

  def convert_url(url) do
    String.replace(url, "https://d1l54leyvskqrr.cloudfront.net", "https://s3.us-east-2.amazonaws.com/daeventboximages")
  end



  def report_generator(items) do
      rows = items |> Enum.map(&(row(&1)))
      %Workbook{sheets: [%Sheet{name: "Items" , rows: [@header] ++ rows}]}
    end
  def row(item) do
      [
        item.name,
        item.email,
        item.date,
        item.email,
        item.quanity,
        "$0.00"

      ]
    end
end
