defmodule DaeventboxWeb.EventController do
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
  alias Daeventbox.Comment
  alias Daeventbox.Ad
  alias Daeventbox.Option
  alias Daeventbox.Follower
  alias Daeventbox.Charge
  alias Daeventbox.Notification
  alias Daeventbox.TransactionRequest
  alias Daeventbox.Complaints
  alias Daeventbox.Rating
  alias Daeventbox.News

  def index(conn, _params) do


    render conn, "index.html"
  end

  def create(conn, params) do
   IO.puts("lll")
    IO.inspect conn.assigns[:current_user]
    facilitator = Repo.get_by(Facilitator,user_id: conn.assigns[:current_user].id)
    render conn, "create_event_form.html", success: nil , facilitator: facilitator

  end


  def add(conn, params) do
      IO.puts "Here is the facilitator ID: #{conn.assigns[:current_user].id}"

      #if there is no facilitator record( meaning the person is new)  add the record
      if is_nil(Repo.get_by(Facilitator, user_id: conn.assigns[:current_user].id)) do
        facil_params = %{name: params["facilitator_name"], facilitator_zid:  Ecto.UUID.generate, user_id: conn.assigns[:current_user].id}
        changeset = Facilitator.changeset(%Facilitator{}, facil_params)

        case Repo.insert(changeset) do
          {:ok, _facilitator} -> IO.puts "Facil Added"
          {:error, reason} -> IO.inspect reason
        end
      end

      facilitator = Repo.get_by(Facilitator,user_id: conn.assigns[:current_user].id)
      current_user = Repo.get_by(User, zid: conn.cookies["daeventboxuser"])
      IO.inspect current_user

      {:ok, resp} = Utils.AmazonS3.file_upload(params)

      IO.inspect resp
      image_url = convert_url(resp.url)
      required_params = %{title: params["title"], facilitator_name: facilitator.name, user_id: conn.assigns[:current_user].id, facilitator_id: facilitator.id, status: "active",
       image_url: image_url, start_date: params["start_date"], start_time: params["start_time"], end_date: params["end_date"], end_time: params["end_time"], category: params["category"], description: params["description"],
       fb_link: params["fb_link"], insta_link: params["insta_link"],  twitter_link: params["twitter_link"], type: params["type"], admission_type: params["admission_type"], location: "#{params["address1"]}, #{params["address2"]}, #{params["parish"]}, Jamaica",
       details: %{}, event_zid:  Ecto.UUID.generate, venue_name: params["venue_name"], location_info: %{parish: params["parish"], address1: params["address1"], address2: params["address2"], country: "Jamaica"}}
      IO.inspect params
      IO.puts "------------------------------------------"
      IO.inspect required_params



      changeset = Event.changeset(%Event{}, required_params)
      case Repo.insert(changeset) do
        {:ok, event} ->
          cond do
          params["type"]== "paid" ->
            IO.puts "Event Created Successful"
            if params["admission_type"] == "ticket" do
              IO.puts "in ticket tin"

              ticket1_params = %{active: "true", event_id: event.id, name: params["ticket1_name"], price: params["ticket1_price"], max_quantity:  params["ticket1_quantity"], info: %{notes: params["notes"]} }
              ticket2_params = %{active: "true", event_id: event.id,name: params["ticket2_name"], price: params["ticket2_price"], max_quantity:  params["ticket2_quantity"], info: %{notes: params["notes"]} }
              ticket3_params = %{active: "true", event_id: event.id,name: params["ticket3_name"], price: params["ticket3_price"], max_quantity:  params["ticket3_quantity"], info: %{notes: params["notes"]} }
              if  !is_nil(ticket1_params.name) && !is_nil(ticket1_params.price) && !is_nil(ticket1_params.max_quantity) && ticket1_params.name != "" && ticket1_params.price !== ""  do
                  IO.puts "in ticket tin1"

                  ticket1_changeset = Ticketdetail.changeset(%Ticketdetail{}, ticket1_params)
                  case Repo.insert( ticket1_changeset) do
                    {:ok, event} -> IO.puts "Ticket 1 details good"
                    {:error, changeset} -> IO.inspect changeset
                  end
              end
              if !is_nil(ticket2_params.name) && !is_nil(ticket2_params.price) && !is_nil(ticket2_params.max_quantity) && ticket2_params.name != "" && ticket2_params.price !== ""  do
                   IO.puts "in ticket tin2"

                  ticket2_changeset = Ticketdetail.changeset(%Ticketdetail{}, ticket2_params)
                  case Repo.insert( ticket2_changeset) do
                    {:ok, event} -> IO.puts "Ticket 2 details good"
                    {:error, changeset} -> IO.inspect changeset
                  end
              end
              if  !is_nil(ticket3_params.name) && !is_nil(ticket3_params.price) && !is_nil(ticket3_params.max_quantity) && ticket3_params.name != "" && ticket3_params.price !== ""  do
                  IO.puts "in ticket tin3"

                  ticket3_changeset = Ticketdetail.changeset(%Ticketdetail{}, ticket3_params)
                  case Repo.insert( ticket3_changeset) do
                    {:ok, event} -> IO.puts "Ticket 3 details good"
                    {:error, changeset} -> IO.inspect changeset
                  end
              end
            else
              registration_params = %{name: params["registration_name"], price: params["registration_price"], event_id: event.id, max_quantity:  params["registration_quantity"], status: "pending", active: 1}
              registration_changeset = Registrationdetails.changeset(%Registrationdetails{}, registration_params)
                case Repo.insert(registration_changeset) do
                    {:ok, event} -> IO.puts "reg paid details good"
                    {:error, changeset} -> IO.inspect changeset
                end
            end
            redirect(conn, to: "/payment/card-info" )
          true ->
            if params["admission_type"] == "registration" do
              registration_params = %{name: params["registration_name"], price: params["registration_price"],event_id: event.id, max_quantity:  params["registration_quantity"], status: "pending", active: 1}
              registration_changeset = Registrationdetails.changeset(%Registrationdetails{}, registration_params)
                case Repo.insert(registration_changeset) do
                    {:ok, reg} -> IO.puts "Reg free details good"
                    {:error, changeset} -> IO.inspect changeset
                end
              conn
                |> put_flash(:info, "Event created successfully.")
                |> show_event_success_modal(params)
                # Webapp.Mailer.send_welcome_email(user.email)
            else
              redirect(conn, to: "/facilitator/manage" )
            end
          end
        {:error, changeset} ->
          IO.inspect changeset
          render(conn, "create_event_form.html", changeset: changeset, params: params)
      end
      conn

  end

  defp show_event_success_modal(conn, params) do
    #render(conn, "success_event_modal.html", success: true)
    facilitator = Repo.get_by(Facilitator,user_id: conn.assigns[:current_user].id)
    IO.puts "Facilitor found success"
    render(conn, "create_event_form.html", success: "true", facilitator: facilitator)
  end

  def delete(conn, params) do

    event = Repo.get!(Event, params["id"])

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    # Repo.delete!(event)
    required_params = %{is_deleted: true, status: "Cancelled"}
    changeset = Event.changeset(event, required_params)
    facilitator = Repo.get_by(Facilitator,user_id: conn.assigns[:current_user].id)
    case Repo.update(changeset) do
      {:ok, _event} ->
        send_notification("Event Announcement", event, "#{facilitator.name} has cancelled #{event.title}", "Facilitator")

        conn
        |> put_flash(:info, "Event deleted successfully.")
        |> redirect(to: "/facilitator/manage")

      {:error, changeset} ->
        IO.inspect changeset
    end

    conn


  end

  def edit_form(conn,params) do
    # pre fill event info (add values)
    event = Repo.get!(Event, params["id"])
    facilitator = Repo.get_by(Facilitator,user_id: conn.assigns[:current_user].id)

    render(conn, "edit.html", event: event, success: false, facilitator: facilitator)
  end

  def update(conn,params) do
    event = Repo.get!(Event, params["id"])
    {:ok, resp} = Utils.AmazonS3.file_upload(params)
    IO.inspect resp
    image_url = convert_url(resp.url)
    required_params = %{title: params["title"], facilitator_name: event.facilitator_name,
       image_url: image_url, start_date: params["start_date"], start_time: event.start_time, end_date: params["end_date"], end_time: params["end_time"], category: params["category"], description: params["description"],
       fb_link: params["fb_link"], insta_link: params["insta_link"],  twitter_link: params["twitter_link"], type: event.type, admission_type: event.admission_type, location: "#{params["address1"]}, #{params["address2"]}, #{params["parish"]}, Jamaica",
       details: %{}, event_zid:  Ecto.UUID.generate, venue_name: params["venue_name"], location_info: %{parish: params["parish"], address1: params["address1"], address2: params["address2"], country: "Jamaica"}}
      IO.inspect params
    changeset = Event.changeset(event, required_params)
    case Repo.update(changeset) do
      {:ok, _event} ->
        conn
        |> put_flash(:info, "Event updated successfully.")
        |> redirect(to: "/facilitator")

      {:error, changeset} ->
        IO.inspect changeset
        conn
        |> put_flash(:error, "Oops error!")
        |> redirect(to: "/event/edit/#{params['id']}")
    end
  end

  def details(conn, params) do
    event = Repo.get!(Event, params["id"])
    user_id  =
      if conn.assigns[:current_user] do
        conn.assigns[:current_user].id
      else
        0
      end

    #facilitator = Repo.get!(Facilitator, event.facilitator_id)
    #if event.admission_type == "ticket" do
     # tickets = Repo.all(from t in Ticketdetail, where: t.event_id == ^event.id, select: [t.name, t.type, t.price, t.category] )
     # render(conn, "details.html", event: event, facilitator: facilitator, tickets: tickets)

    #else
     # registration = Repo.all(from r in Registrationdetails, where: r.event_id == ^event.id, select: [r.type, r.quantity])
      #render(conn, "details.html", event: event, facilitator: facilitator, registration: registration)

    #end

    comments = Repo.all(from c in Comment, where: c.event_id == ^event.id, limit: 5)
    saved_event = Repo.get_by(SavedEvent, user_id: user_id, event_id: event.id)
    if is_nil(saved_event) do
      saved = false
    else
      saved = true
    end
    liked_event = Repo.get_by(LikedEvent, user_id: user_id, event_id: event.id)
    if is_nil(liked_event) do
      liked = false
    else
      liked = true
    end
    facilitator =
    if !is_nil(Repo.get_by(Facilitator, id: event.facilitator_id)) do
      Repo.get_by(Facilitator, id: event.facilitator_id)
    else
     %{ name: "Unknown", about: "No description", phone: "No phone", email: "No email", address: "No address"}
    end
   # facilitator = Repo.get_by(Facilitator, id: event.facilitator_id)
    map_url = "https://www.google.com/maps/embed/v1/place?key=AIzaSyDetwM4R3Z2EohZ91Qub3-BkLo_tVfE6Eg&q=" <> "#{event.location_info["address1"]}" <> "+Kingston,+Jamaica"
    start_date =  format_datetime(event.start_date)
    end_date =  format_datetime(event.end_date)
    start_time = format_time(event.start_time)
    end_time = format_time(event.end_time)
    Action.add(conn, "viewed-event-details", 1, event.id, user_id )
    # Sum of (weight * number of reviews at that weight) / total number of reviews
    # (5*252 + 4*124 + 3*40 + 2*29 + 1*33) / 478 = 4.1
    star5 = Repo.all(from r in Rating, where: r.rating == 5 and r.event_id == ^event.id) |> Enum.count
    star4 = Repo.all(from r in Rating, where: r.rating == 4 and r.event_id == ^event.id) |> Enum.count
    star3 = Repo.all(from r in Rating, where: r.rating == 3 and r.event_id == ^event.id) |> Enum.count
    star2 = Repo.all(from r in Rating, where: r.rating == 2 and r.event_id == ^event.id) |> Enum.count
    star1 = Repo.all(from r in Rating, where: r.rating == 1 and r.event_id == ^event.id) |> Enum.count
    total_reviews =  Repo.all(from r in Rating, where: r.event_id == ^event.id) |> Enum.count
    unless total_reviews == 0 do
      overall_rating = (5 * star5 + 4 * star4 + 3 * star3 + 2 * star2 + 1 * star1) / total_reviews
    else
      overall_rating = 0
    end
    IO.puts "Overall rating"
    IO.inspect overall_rating
    IO.inspect total_reviews
    render(conn, "details.html", total_reviews: total_reviews, overall_rating: overall_rating, comments: comments,  event: event, saved: saved, liked: liked, facilitator: facilitator, map: map_url, end_date: end_date, start_date: start_date, start_time: start_time, end_time: end_time)

  end

  def manage(conn, params) do
    per_page = params["page_size"] || 2
    page = params["page"] || "1"
   # get all events saved
   saved_events = Repo.all(from s in SavedEvent,join: e in Event, on: s.event_id == e.id, where: s.user_id ==  ^conn.assigns[:current_user].id, select: [e.title, e.start_date, e.id, e.image_url])
   # get all tickets bought and the event details
   tequery =
    Ticket
    |> where([t], t.user_id == ^conn.assigns[:current_user].id)
    |> join(:inner, [t], e in Event, e.id == t.event_id)
    |> join(:inner, [t], ti in Ticketdetail, ti.id == t.ticket_id)
    |> select([t,e,ti], [e.title, e.image_url, t.inserted_at, ti.name, t.barcode, ti.price, t.status, e.id, t.id, t.user_id])
    |> order_by([t], [desc: t.inserted_at])
    #from t in Ticket,
    #where: t.user_id ==  ^conn.assigns[:current_user].id,
    #join: e in Event,
    #on: t.event_id == e.id, join: ti in Ticketdetail,
    #on: t.event_id == ti.event_id,
    #select: [e.title, e.image_url, t.inserted_at, ti.name, t.barcode, ti.price, t.status, e.id, t.id, t.user_id]

    IO.inspect tequery
    tickets_and_events = Paginate.query(tequery, per_page, page)
    IO.inspect tickets_and_events
    teevents_num = Repo.all(tequery) |> Enum.count
    pages = teevents_num / per_page
    pages = Float.ceil(pages) |> Kernel.round
   # get all the registrations and the event details
   requery = from r in Registration, join: e in Event, on: r.event_id == e.id, join: re in Registrationdetails, on: r.event_id == re.event_id, where: r.user_id ==  ^conn.assigns[:current_user].id, select: [e.title, re.name,  e.image_url, r.inserted_at, re.type, re.id, r.id, r.status,r.persons_details, re.price], order_by: [desc: r.inserted_at]
   registration_and_events = Paginate.query(requery, per_page, page)

   reevents_num = Repo.all(requery) |> Enum.count
   pages2 = reevents_num / per_page
   pages2 = Float.ceil(pages2) |> Kernel.round
   # attending_events = Repo.all(from e in Event, join: t in Ticket, join: r in Registration, where:  t.event_id == e.id or r.event_id == e.id and t.user_id ==  ^conn.assigns[:current_user].id or r.user_id ==  ^conn.assigns[:current_user].id, select: [e.title, e.start_date, e.id, e.image_url])
   attending_events = Repo.all(from s in SavedEvent,join: e in Event, on: s.event_id == e.id, where: s.user_id ==  ^conn.assigns[:current_user].id, select: [e.title, e.start_date, e.id, e.image_url])

   render(conn, "manage.html", page_count1: pages, page: page, page_count2: pages, attending_events: attending_events, saved_events: saved_events, tickets_and_events: tickets_and_events, registration_and_events: registration_and_events )
  end

  def save(conn, params) do
    event = Repo.get!(Event, params["id"])
    required_params = %{event_id: event.id, user_id: conn.assigns[:current_user].id, zid:  Ecto.UUID.generate }
    changeset = SavedEvent.changeset(%SavedEvent{}, required_params)

    case Repo.insert(changeset) do
      {:ok, saved} -> IO.puts "Saved event"
      {:error, changeset} -> IO.inspect changeset
    end
    redirect(conn, to: "/event/details/#{event.id}")
  end

  def unsave(conn,params) do
    event = Repo.get!(Event, params["id"])
    user_id = conn.assigns[:current_user].id
    saved_event = Repo.get_by(SavedEvent, user_id: user_id, event_id: event.id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(saved_event)
    redirect(conn, to: "/event/details/#{event.id}")
  end
   def like(conn, params) do
    event = Repo.get!(Event, params["id"])
    required_params = %{event_id: event.id, user_id: conn.assigns[:current_user].id, zid:  Ecto.UUID.generate }
    changeset = LikedEvent.changeset(%LikedEvent{}, required_params)

    case Repo.insert(changeset) do
      {:ok, liked} -> IO.puts "Liked event"
      {:error, changeset} -> IO.inspect changeset
    end
    redirect(conn, to: "/event/details/#{event.id}")
  end

  def unlike(conn,params) do
    event = Repo.get!(Event, params["id"])
    user_id = conn.assigns[:current_user].id
    liked_event = Repo.get_by(LikedEvent, user_id: user_id, event_id: event.id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(liked_event)
    redirect(conn, to: "/event/details/#{event.id}")
  end

  def register(conn, params) do
    event = Repo.get!(Event, params["id"])
    query = from r in Registrationdetails, where: r.event_id == ^event.id
    registration_details = Repo.all(query)
    start_date =  format_datetime(event.start_date)
    end_date =  format_datetime(event.end_date)
    start_time = format_time(event.start_time)
    end_time = format_time(event.end_time)
    render conn, "select_options.html", event: event, registration_details: registration_details, start_time: start_time, end_time: end_time, start_date: start_date, end_date: end_date
  end

  def buy_tickets(conn, params) do
    event = Repo.get!(Event, params["id"])
    query = from t in Ticketdetail, where: t.event_id == ^event.id
    ticket_details = Repo.all(query)
    start_date =  format_datetime(event.start_date)
    end_date =  format_datetime(event.end_date)
    start_time = format_time(event.start_time)
    end_time = format_time(event.end_time)
    render conn, "select_options.html", event: event, ticket_details: ticket_details, start_time: start_time, end_time: end_time, start_date: start_date, end_date: end_date
  end
  defp proceed_with_payment(conn, params) do


    event = Repo.get!(Event, params["id"])
    IO.puts "jjnjhhhhhhh"

    IO.inspect params
    details =
      if params["type"] =="ticket" do
        query = from t in Ticketdetail, where: t.event_id == ^event.id
        Repo.all(query)
      else
        query = from r in Registrationdetails, where: r.event_id == ^event.id
        Repo.all(query)
      end
    index = 0
    items =
      for i <- details do
        index = Enum.find_index(details, fn(x) -> x.id== i.id end)
        unless params["selected_quantity#{index}"] == 0  do
          quantity = String.to_integer(params["selected_quantity#{index}"])

          unit_price =  :erlang.float_to_binary(i.price, [:compact, { :decimals, 3 }])
          price = i.price * quantity

            %{
              name:  i.name,
              quantity: quantity,
              unit_price: unit_price,
              price: price,
              id: i.id
            }
        end
      end
    total = 0
    total =
      for item <- items do
         total + item.price
      end

    IO.puts "The total is"
    IO.inspect total
     total = Enum.sum(total)
     params = Poison.encode!(params)
    render conn, "payment_form.html", items: items, total: total, event: event, total_items: Enum.count(items), registration_details_params: '#{params}'
  end

  def ticket_selection(conn, params) do

      proceed_with_payment(conn, params)

  end
  def registration_selection(conn, params) do
    event = Repo.get!(Event, params["id"])

    registration_form(conn,params, event)
  end
  defp registration_form(conn, params, event) do
       query = from r in Registrationdetails, where: r.event_id == ^event.id
       details = Repo.all(query)
       items =
        for i <- details do
          index = Enum.find_index(details, fn(x) -> x.id== i.id end)
          IO.inspect  params["selected_quantity#{index}"]
          unless params["selected_quantity#{index}"] == 0  do
            quantity = String.to_integer(params["selected_quantity#{index}"])

            %{
                name:  i.name,
                quantity: quantity,
                id: i.id
              }
          end
        end
        render conn, "registration_form.html", event: event, items: items, total_items: Enum.count(items)
  end

  def email_ticket(conn, params) do
    user = conn.assigns[:current_user]
    ticket  = Repo.get_by(Ticket, id: params["ticket_id"])
    DaeventboxWeb.EmailController.ticket_email(ticket, user)
    conn
    |> put_flash(:info, "Ticket sent successful")
    |> redirect(to: "/event/manage")
  end

  def add_ticket(conn, params) do
    total_items = String.to_integer(params["total_items"])-1
    for count <- 0..total_items do
       IO.puts "here -event add ticket"
      unless params["item#{count}"] == "" do
        ticket = Repo.get!(Ticketdetail, String.to_integer(params["item#{count}"]))
        for i <- 1..String.to_integer(params["itemq#{count}"]) do
          DaeventboxWeb.TicketController.create_ticket(conn, params, ticket)
          #required_params = %{  barcode: Enum.random(1000000000000..999999999999), price: ticket.price , event_id: params["id"] , user_id: conn.assigns[:current_user].id , ticket_id: ticket.id }
          #changeset = Ticket.changeset(%Ticket{}, required_params)
          #IO.puts "ksdms"
          #case Repo.insert(changeset) do
          #  {:ok, ticket} -> IO.puts "Added Tickets"
          #  {:error, changeset} -> IO.inspect changeset
          #end

        end
      end
    end
    redirect conn, to: "/"

  end

  def add_registrations(conn, params) do
    event = Repo.get!(Event, params["id"])
    if event.type == "free" do
      total_items = String.to_integer(params["total_items"])-1
      for count <- 0..total_items do
        unless params["item#{count}"] == "" do
          registration_details = Repo.get!(Registrationdetails, String.to_integer(params["item#{count}"]))
          for i <- 1..String.to_integer(params["itemq#{count}"]) do
            person_details =
            [
              %{
                first_name: params["first_name#{registration_details.id}#{i}"],
                last_name: params["last_name#{registration_details.id}#{i}"],
                email: params["email#{registration_details.id}#{i}"],
                contact: params["contact#{registration_details.id}#{i}"]
              }

            ]
            required_params = %{persons_details: person_details, event_id: params["id"] , user_id: conn.assigns[:current_user].id , registrationdetails_id: registration_details.id }
            changeset = Registration.changeset(%Registration{}, required_params)
            case Repo.insert(changeset) do
              {:ok, ticket} -> IO.puts "Added Registration"
              {:error, changeset} -> IO.inspect changeset
            end

          end
        end
      end
      redirect conn, to: "/event/manage"
    else
      proceed_with_payment(conn, params)
    end



  end

  def upcoming_events(conn,params) do
    per_page = params["page_size"] || 9
    page = params["page"] || "1"
    query = from e in Event, where: e.id > 15 and is_nil(e.is_deleted) , order_by: [desc: e.inserted_at]
    events_num = Repo.all(query) |> Enum.count
    pages = events_num / per_page
    pages = Float.ceil(pages) |> Kernel.round
    events = Paginate.query(query, per_page, page)
    ads_query = from a in Ad, join: o in Option,  where: o.position == "side" and a.status == "active" and a.option_id == o.id, select: [o.position, a.image_url]
    ads = Repo.all(ads_query)
    news = Repo.all(from n in News, order_by: [desc: n.inserted_at], limit: 3)
    render conn, "upcoming_events.html", events: events,ads: ads, news: news,  page_count: pages, page: page
  end

  def facilitators(conn, params) do
    per_page = params["page_size"] || 9
    page = params["page"] || "1"
    user =
      if conn.assigns[:current_user] do
        Repo.get!(User, conn.assigns[:current_user].id)
      else
        nil
      end
    query = from f in Facilitator
    facilitators_num = Repo.all(query) |> Enum.count
    pages = facilitators_num / per_page
    pages = Float.ceil(pages) |> Kernel.round
    facilitators = Paginate.query(query, per_page, page)
    IO.puts "THESE ARE FACILIS"
    IO.inspect facilitators
    ads_query = from a in Ad, join: o in Option,  where: o.position == "side" and a.status == "active" and a.option_id == o.id, select: [o.position, a.image_url]
    ads = Repo.all(ads_query)
    news = Repo.all(from n in News, order_by: [desc: n.inserted_at], limit: 3)
    render conn, "facilitators.html", facilitators: facilitators, ads: ads, user: user, news: news, page_count: pages, page: page

  end

  def filter_events(conn, params) do
    per_page = params["page_size"] || 9
    page = params["page"] || "1"
     cond do
      params["category"] ->
        query = from e in Event, where: e.category == ^params["category"] and e.id > 15

      params["location"] ->
         query = from e in Event, where: fragment("?->>'parish' LIKE ?", e.location_info, ^params["location"]) and e.id > 15

      params["price"] ->
        query = from e in Event, where: e.type == ^params["price"] and e.id > 15

      params["date"] ->
        query =
        cond do
          params["date"] == "today" -> from r in Event, where: fragment(" ? >= current_date and ? <= current_date + interval '1 day'", r.start_date,  r.start_date), order_by: [desc: r.inserted_at]
          params["date"] == "this-week" -> from r in Event, where: fragment(" ? >= current_date and ? <= current_date + interval '1 week'", r.start_date,  r.start_date), order_by: [desc: r.inserted_at]
          params["date"] == "this-month" -> from r in Event, where: fragment(" ? >= current_date and ? <= current_date + interval '1 month'", r.start_date,  r.start_date), order_by: [desc: r.inserted_at]
          params["date"] == "this-year" -> from r in Event, where: fragment("? >= current_date and ? <= current_date + interval '1 year'", r.start_date,  r.start_date), order_by: [desc: r.inserted_at]


        end

     end
    events_num = Repo.all(query) |> Enum.count
    pages = events_num / per_page
    pages = Float.ceil(pages) |> Kernel.round
    events = Paginate.query(query, per_page, page)
    ads_query = from a in Ad, join: o in Option,  where: o.position == "side" and a.status == "active" and a.option_id == o.id, select: [o.position, a.image_url]
    ads = Repo.all(ads_query)
    news = Repo.all(from n in News, order_by: [desc: n.inserted_at], limit: 3)
    render conn, "upcoming_events.html", events: events, ads: ads, news: news, page_count: pages, page: page

  end

  def add_comment(conn, params) do
    user = Repo.get!(User, conn.assigns[:current_user].id)
    required_params = %{type: "Event Comment" , sent_by: "Guest", from: user.firstname <> " " <> user.lastname, user_id: user.id, event_id: params["event_id"], message: params["comment"] }
    changeset = Comment.changeset(%Comment{}, required_params)
      case Repo.insert(changeset) do
            {:ok, _comment} ->
              IO.puts "Added Comment"

              conn
              |> redirect(to: "/event/details/#{params["event_id"]}" )

            {:error, reason} -> IO.inspect reason
      end
  end

  def earnings(conn, params) do
    event = Repo.get_by(Event, id: params["event_id"])
    facilitator = Repo.get_by(Facilitator, id: event.facilitator_id )

    total_registrations = Repo.all(from r in Registration, where: r.event_id == ^event.id)|> Enum.count
    total_tickets = Repo.all(from t in Ticket, where: t.event_id == ^event.id) |> Enum.count
    total_paid_transactions = total_tickets + total_registrations
    total_earnings =
      if event.admission_type == "ticket" do
        Repo.one(from t in Ticket, join: td in Ticketdetail, where: t.ticket_id == td.id and t.event_id == ^event.id, select: sum(td.price))
      else
        Repo.one(from r in Registration, join: rd in Registrationdetails, where: r.event_id == ^event.id and r.registrationdetails_id == rd.id, select: sum(rd.price))

      end
    total_charges = 0.00
    charges  = Repo.all(from c in Charge, where: c.assigned_to == "facilitators")
    total_charges =
    for charge <- charges do
      if charge.type == "fixed" do
        total_charges + charge.charges
      else
        total_charges + (total_earnings*(charge.charges/100))
      end
    end
    total_charges  =  Enum.sum(total_charges)
    requests = Repo.all(from t in TransactionRequest, where: t.event_id == ^event.id)
    total_recieved = Repo.one(from t in TransactionRequest, where: t.event_id == ^event.id and t.status=="Paid", select: sum(t.amount))
    total_recieved  =
      if is_nil(total_recieved) do
        0.00
      else
        total_recieved
      end
    total_payable = total_earnings - total_charges - total_recieved
    earnings_breakdown =
      if event.admission_type == "ticket" do
        Repo.all( from td in Ticketdetail, join: t in Ticket, where: t.ticket_id == td.id and td.event_id == ^event.id , distinct: td.name, group_by: [:name, :price], select: [ td.name, count(t.id), td.price ] )
      else
        Repo.all( from rd in Registrationdetails, join: r in Registration, where: r.registrationdetails_id == rd.id and rd.event_id == ^event.id , distinct: rd.name, group_by: [:name, :price], select: [ rd.name, count(r.id), rd.price ] )

      end
    requests = Repo.all(from t in TransactionRequest, where: t.event_id == ^event.id)
    render conn, "earnings.html", total_recieved: total_recieved, requests: requests, event: event, facilitator: facilitator,  total_paid_transactions: total_paid_transactions, total_earnings: total_earnings, total_charges: total_charges, charges: charges, total_payable: total_payable, earnings_breakdown: earnings_breakdown
  end

  def transaction_request(conn, params) do
    event = Repo.get_by(Event, id: params["event_id"])
    facilitator = Repo.get_by(Facilitator, id: event.facilitator_id )
    items =
      if event.admission_type == "tickets" do
        Repo.all(from t in Ticket, join: td in Ticketdetail, where: t.event_id == ^event.id and t.ticket_id == td.id)
      else
        Repo.all(from r in Registration, join: rd in Registrationdetails, where: r.event_id == ^event.id and r.registrationdetails_id == rd.id)
      end
    total_registrations = Repo.all(from r in Registration, where: r.event_id == ^event.id)|> Enum.count
    total_tickets = Repo.all(from t in Ticket, where: t.event_id == ^event.id) |> Enum.count
    total_paid_transactions = total_tickets + total_registrations

    total_earnings = Repo.one(from t in Ticket, join: td in Ticketdetail, where: t.ticket_id == td.id and t.event_id == ^event.id, select: sum(td.price))
    total_charges = 0.00
    charges  = Repo.all(from c in Charge, where: c.assigned_to == "facilitators")
    total_charges =
    for charge <- charges do
      if charge.type == "fixed" do
        total_charges + charge.charges
      else
        total_charges + (total_earnings*(charge.charges/100))
      end
    end
    total_charges  =  Enum.sum(total_charges)
    total_recieved = Repo.one(from t in TransactionRequest, where: t.event_id == ^event.id and t.status=="Paid", select: sum(t.amount))
    total_recieved  =
      if is_nil(total_recieved) do
        0.00
      else
        total_recieved
      end
    total_payable = total_earnings - total_charges - total_recieved
    required_params = %{total_amount: total_earnings, charges: total_charges, amount_payable: total_payable, amount: params["amount"], facilitator_id: event.facilitator_id, event_id: event.id, title: params["reason"], status: "New" }

    changeset = TransactionRequest.changeset(%TransactionRequest{}, required_params)
    case Repo.insert(changeset) do
          {:ok, request} ->
            IO.puts "Added Request"
            send_notification("Transaction Request", request, "#{facilitator.name} has made a transaction request for #{event.title}", "Facilitator")
            conn
            |> redirect(to: "/event/earnings/#{event.id}" )

          {:error, reason} -> IO.inspect reason
    end


  end

def send_notification(type, item, message, sent_by) do


    if type == "Event Announcement"  do
      event  = Repo.get_by(Event, id: item.id)
      facilitator  = Repo.get_by(Facilitator, id: event.facilitator_id)
      all_interested_users_query = from u in User, join: l in LikedEvent, join: s in SavedEvent, join: t in Ticket, where: t.event_id == ^event.id and s.event_id == ^event.id and l.event_id == ^event.id and l.user_id == u.id or s.user_id == u.id or t.user_id == t.id, distinct: u.id
      # for all the users that like, save or are attending this event
      users = Repo.all(all_interested_users_query)
      for user <- users do
        required_params = %{type: "Event Announcement" , sent_by: "Facilitator", from: facilitator.name, seen: false, user_id: user.id, facilitator_id: facilitator.id, event_id: event.id, message: message, recipient: "Guests" }
        changeset = Notification.changeset(%Notification{}, required_params)
        case Repo.insert(changeset) do
              {:ok, _notification} ->
                IO.puts "Added Notification"

              {:error, reason} -> IO.inspect reason
        end
      end
    else
      event  = Repo.get_by(Event, id: item.event_id)
      facilitator  = Repo.get_by(Facilitator, id: event.facilitator_id)
      required_params = %{type: type , sent_by: sent_by, from: facilitator.name, seen: false, user_id: facilitator.id, facilitator_id: 0, event_id: item.event_id, message: message }
      changeset = Notification.changeset(%Notification{}, required_params)
      case Repo.insert(changeset) do
            {:ok, _notification} ->
              IO.puts "Added Notification"
            {:error, reason} -> IO.inspect reason
      end
    end

  end

  def filter_facilitators(conn, params) do
    per_page = params["page_size"] || 9
    page = params["page"] || "1"
     cond do
      params["alphabetically"] ->
        query =
          if  params["alphabetically"] == "asc" do
            from f in Facilitator,  order_by: [asc: f.name]
          else
            from f in Facilitator, order_by: [desc: f.name]
          end
      params["ratings"] ->
       query =
         if  params["ratings"] == "most" do
            from(f in Facilitator, [
                  join: fo in Follower, where: f.id == fo.facilitator_id ,
                  group_by: f.id,
                  select: [f.id, f.facilitator_email, count(fo.id), f.facilitator_phone, f.name, f.image_url, f.user_id],
                  order_by: [desc: count(fo.id)]
                ])
          else
            from(f in Facilitator, [
                  join: fo in Follower, where: f.id == fo.facilitator_id ,
                  group_by: f.id,
                  select: [f.id, f.facilitator_email, count(fo.id), f.facilitator_phone, f.name, f.image_url, f.user_id],
                  order_by: [asc: count(fo.id)]
                ])
           end

      params["events"] ->
       query =
        if  params["events"] == "most" do
        # "select facilitator_id , count(*) as count from events group by facilitator_id order by count desc;"
         from(f in Facilitator, [
                  join: e in Event, on: f.id == e.facilitator_id,
                  group_by: f.id,
                  select: [f.id, f.facilitator_email, count(e.id), f.facilitator_phone, f.name, f.image_url, f.user_id],
                  order_by: [desc: count(e.id)]
                ])
        else
        # "select facilitator_id , count(*) as count from events group by facilitator_id order by count desc;"
         from(f in Facilitator, [
                  join: e in Event, on: f.id == e.facilitator_id,
                  group_by: f.id,
                  select: [f.id, f.facilitator_email, count(e.id), f.facilitator_phone, f.name, f.image_url, f.user_id],
                  order_by: [asc: count(e.id)]
                ])
        end

      params["date"] ->
         query =
          if  params["date"] == "oldest" do
            from f in Facilitator,  order_by: [asc: f.inserted_at]
          else
            from f in Facilitator, order_by: [desc: f.inserted_at]
          end
     end
    user =
      if conn.assigns[:current_user] do
        Repo.get!(User, conn.assigns[:current_user].id)
      else
        nil
      end
    facilitators_num = Repo.all(query) |> Enum.count
    pages = facilitators_num / per_page
    pages = Float.ceil(pages) |> Kernel.round
    facilitators = Paginate.query(query, per_page, page)
    if !is_nil(params["events"]) or !is_nil(params["ratings"]) do
      facilitators =
        for f <- facilitators  do
        %{
          id: Enum.at(f, 0),
          facilitator_email: Enum.at(f, 1),
          event_count: Enum.at(f, 2),
          facilitator_phone: Enum.at(f, 3),
          name: Enum.at(f, 4),
          image_url: Enum.at(f, 5),
          user_id: Enum.at(f, 6),

        }
        end
    end
    ads_query = from a in Ad, join: o in Option,  where: o.position == "side" and a.status == "active" and a.option_id == o.id, select: [o.position, a.image_url]
    ads = Repo.all(ads_query)
    news = Repo.all(from n in News, order_by: [desc: n.inserted_at], limit: 3)

    render conn, "facilitators.html", facilitators: facilitators, user: user, ads: ads,  news: news, page_count: pages, page: page

  end

  def report_event(conn, params) do
    required_params = %{status: "New", title: params["title"], message: params["message"], user_id: conn.assigns[:current_user].id, event_id: params["event_id"], type: "Event", facilitator_id: nil}
    changeset = Complaints.changeset(%Complaints{}, required_params)
    case Repo.insert(changeset) do
          {:ok, complaint} ->
            IO.puts "Added Complaints"
            send_notification("Complaint",complaint, "You have recieved a new complaint", "Guest")
            redirect conn, to: "/event/details/#{params["event_id"]}"
          {:error, reason} -> IO.inspect reason
    end

  end


  def add_rating(conn, params) do
    if is_nil(Repo.get_by(Rating, event_id: params["event_id"], user_id: conn.assigns[:current_user].id) ) do
      event =  Repo.get_by(Event, id: params["event_id"])
      required_params = %{status: "active", rating: params["rating"], user_id: conn.assigns[:current_user].id, event_id: params["event_id"], type: "Event", facilitator_id: event.facilitator_id}
      changeset = Rating.changeset(%Rating{}, required_params)
      case Repo.insert(changeset) do
            {:ok, rating} ->

              redirect conn, to: "/event/details/#{params["event_id"]}"
            {:error, reason} -> IO.inspect reason
      end
    else
      rating = Repo.get_by(Rating, event_id: params["event_id"] , user_id: conn.assigns[:current_user].id )
      required_params = %{rating: params["rating"]}

      changeset = Rating.changeset(rating, required_params)
      case Repo.update(changeset) do
                 {:ok, rating} ->

              redirect conn, to: "/event/details/#{params["event_id"]}"
            {:error, reason} -> IO.inspect reason
      end
    end
  end

  def search(conn, params) do
    IO.puts "Regular params"
    IO.inspect params
    per_page = params["page_size"] || 9
    page = params["page"] || "1"
    events  =
      Event
      |> where([e], is_nil(e.is_deleted) )
      |> where([e], e.id > 15)
    events =
      if params["title"] != "" and params["title"] != nil do
        events
          |> where([e], fragment("? ~* ?", e.title, ^params["title"]))
      else
        events
      end

    events =
      if params["parish"] != "" and params["parish"] != nil do
        events
          |> where([e],  fragment("?->>'parish' LIKE ?", e.location_info, ^params["parish"]) )
      else
        events
      end

    events =
      if params["date"] != "" and params["date"] != nil do
        events
          |> where([e], e.start_date == ^params["date"] )
      else
        events
      end
    events =
      if params["category"] != "" and params["category"] != nil do
        events
          |> where([e], e.category == ^params["category"] )
      else
        events
      end



    all_events = events  |> Repo.all
    events_num = all_events |> Enum.count
    pages = events_num / per_page
    pages = Float.ceil(pages) |> Kernel.round
    events = Paginate.query(events, per_page, page)
    ads_query = from a in Ad, join: o in Option,  where: o.position == "side" and a.status == "active" and a.option_id == o.id, select: [o.position, a.image_url]
    ads = Repo.all(ads_query)
    news = Repo.all(from n in News, order_by: [desc: n.inserted_at], limit: 3)
    render conn, "upcoming_events.html", events: events, ads: ads, news: news, page_count: pages, page: page


  end
   @months %{1 => "Jan", 2 => "Feb", 3 => "Mar", 4 => "Apr",
            5 => "May", 6 => "Jun", 7 => "Jul", 8 => "Aug",
            9 => "Sep", 10 => "Oct", 11 => "Nov", 12 => "Dec"}

  def format_datetime(timestamp) do
   timestamp
   |> Calendar.Strftime.strftime!("%B %e,  %Y")
   #|> Calendar.Strftime.strftime!("%A, %e %B %Y")

  end


  def format_time(time) do
    time
    |> Calendar.Strftime.strftime! "%I:%M%P"
  end

  def convert_url(url) do
    String.replace(url, "https://d1l54leyvskqrr.cloudfront.net", "https://s3.us-east-2.amazonaws.com/daeventboximages")
  end

end
