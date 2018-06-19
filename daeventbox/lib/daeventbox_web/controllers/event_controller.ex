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
          if params["type"]== "paid" do
            IO.puts "Event Created Successful"
            if params["admission_type"] == "ticket" do
              IO.puts "in ticket tin"

              ticket1_params = %{active: "true", event_id: event.id, name: params["ticket1_name"], price: params["ticket1_price"], max_quantity:  params["ticket1_quantity"], info: %{notes: params["notes"]} }
              ticket2_params = %{active: "true", event_id: event.id,name: params["ticket2_name"], price: params["ticket2_price"], max_quantity:  params["ticket2_quantity"], info: %{notes: params["notes"]} }
              ticket3_params = %{active: "true", event_id: event.id,name: params["ticket3_name"], price: params["ticket3_price"], max_quantity:  params["ticket3_quantity"], info: %{notes: params["notes"]} }
              if  ticket1_params.name && ticket1_params.price && ticket1_params.max_quantity do
                  IO.puts "in ticket tin1"

                  ticket1_changeset = Ticketdetail.changeset(%Ticketdetail{}, ticket1_params)
                  case Repo.insert( ticket1_changeset) do
                    {:ok, event} -> IO.puts "Ticket 1 details good"
                    {:error, changeset} -> IO.inspect changeset
                  end
              end
              if ticket2_params.name && ticket2_params.price && ticket2_params.max_quantity do
                   IO.puts "in ticket tin2"

                  ticket2_changeset = Ticketdetail.changeset(%Ticketdetail{}, ticket2_params)
                  case Repo.insert( ticket2_changeset) do
                    {:ok, event} -> IO.puts "Ticket 2 details good"
                    {:error, changeset} -> IO.inspect changeset
                  end
              end
              if  ticket3_params.name && ticket3_params.price && ticket3_params.max_quantity do
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
          else
            registration_params = %{event_id: event.id, max_quantity:  params["registration_quantity"], status: "pending", active: 1}
            registration_changeset = Registrationdetails.changeset(%Registrationdetails{}, registration_params)
              case Repo.insert(registration_changeset) do
                  {:ok, reg} -> IO.puts "Reg free details good"
                  {:error, changeset} -> IO.inspect changeset
              end
            conn
              |> put_flash(:info, "Event created successfully.")
              |> show_event_success_modal(params)
              # Webapp.Mailer.send_welcome_email(user.email)
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
    Repo.delete!(event)

    conn
    |> put_flash(:info, "Event deleted successfully.")
    |> redirect(to: "/facilitator")

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
    user_id = conn.assigns[:current_user].id

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
    Action.add(conn, "viewed-event-details", 1, event.id )
    render(conn, "details.html", comments: comments,  event: event, saved: saved, liked: liked, facilitator: facilitator, map: map_url, end_date: end_date, start_date: start_date, start_time: start_time, end_time: end_time)

  end

  def manage(conn, params) do
   # get all events saved
   saved_events = Repo.all(from s in SavedEvent,join: e in Event, on: s.event_id == e.id, where: s.user_id ==  ^conn.assigns[:current_user].id, select: [e.title, e.start_date, e.id])
   # get all tickets bought and the event details
   tequery = from t in Ticket, join: e in Event, on: t.event_id == e.id, join: ti in Ticketdetail, on: t.event_id == ti.event_id, where: t.user_id ==  ^conn.assigns[:current_user].id, select: [e.title, e.image_url, t.inserted_at, ti.name, t.barcode, ti.price, t.status, e.id, t.id]
   tickets_and_events = Repo.all(tequery)
   # get all the registrations and the event details
   requery = from r in Registration, join: e in Event, on: r.event_id == e.id, join: re in Registrationdetails, on: r.event_id == re.event_id, where: r.user_id ==  ^conn.assigns[:current_user].id, select: [e.title, re.name,  e.image_url, r.inserted_at, re.type, re.id, r.id, r.status,r.persons_details]
   registration_and_events = Repo.all(requery)

   render(conn, "manage.html", saved_events: saved_events, tickets_and_events: tickets_and_events, registration_and_events: registration_and_events )
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
         total = total + item.price
      end
    render conn, "payment_form.html", items: items, total: 1000, event: event, total_items: Enum.count(items)
  end

  def ticket_selection(conn, params) do

      proceed_with_payment(conn, params)

  end
  def registration_selection(conn, params) do
    event = Repo.get!(Event, params["id"])
    if event.type == "free" do

      registration_form(conn,params, event)
    else
      proceed_with_payment(conn, params)
    end
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

  def add_ticket(conn, params) do
    total_items = String.to_integer(params["total_items"])-1
    for count <- 0..total_items do
       IO.puts "here"
      unless params["item#{count}"] == "" do
        ticket = Repo.get!(Ticketdetail, String.to_integer(params["item#{count}"]))
        for i <- 1..String.to_integer(params["itemq#{count}"]) do
          DaeventboxWeb.TicketController.create_ticket(params["id"], conn.assigns[:current_user])
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
    redirect conn, to: "/"

  end

  def upcoming_events(conn,params) do
    query = from e in Event, where: e.id > 15 # where events are new
    events = Repo.all(query)
    ads_query = from a in Ad, join: o in Option,  where: o.position == "side" and a.status == "active" and a.option_id == o.id, select: [o.position, a.image_url]
    ads = Repo.all(ads_query)
    render conn, "upcoming_events.html", events: events,ads: ads
  end

  def facilitators(conn, params) do
    user = Repo.get!(User, conn.assigns[:current_user].id)
    query = from f in Facilitator
    facilitators = Repo.all(query)
    IO.puts "THESE ARE FACILIS"
    IO.inspect facilitators
    ads_query = from a in Ad, join: o in Option,  where: o.position == "side" and a.status == "active" and a.option_id == o.id, select: [o.position, a.image_url]
    ads = Repo.all(ads_query)
    followers = Repo.all(from f in Follower, where: f.user_id == ^user.id )
    render conn, "facilitators.html", facilitators: facilitators, ads: ads, followers: followers, user: user

  end

  def filter_events(conn, params) do
     cond do
      params["category"] ->
        query = from e in Event, where: e.category == ^params["category"] and e.id > 15
        events = Repo.all(query)
      params["location"] ->
         query = from e in Event, where: fragment("?->>'parish' LIKE ?", e.location_info, ^params["location"]) and e.id > 15
         events = Repo.all(query)
      params["price"] ->
        query = from e in Event, where: e.type == ^params["price"] and e.id > 15
        events = Repo.all(query)
      params["date"] ->
         query = from e in Event, where: e.id > 15, order_by: [asc: e.inserted_at]
         events = Repo.all(query)
     end
    render conn, "upcoming_events.html", events: events

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


  def filter_facilitators(conn, params) do
     cond do
      params["alphabetically"] ->
        query =
          if  params["alphabetically"] == "asc" do
            from f in Facilitator,  order_by: [asc: f.name]
          else
            from f in Facilitator, order_by: [desc: f.name]
          end
        facilitators = Repo.all(query)
      params["ratings"] ->
       query =
         if  params["ratings"] == "most" do
            from f in Facilitator,  order_by: [asc: f.name]
          else
            from f in Facilitator, order_by: [desc: f.name]
          end
        facilitators = Repo.all(query)
      params["events"] ->
       query =
        if  params["events"] == "asc" do
            from f in Facilitator,  order_by: [asc: f.name]
          else
            from f in Facilitator, order_by: [desc: f.name]
          end
        facilitators = Repo.all(query)
      params["date"] ->
         query =
          if  params["date"] == "asc" do
            from f in Facilitator,  order_by: [asc: f.inserted_at]
          else
            from f in Facilitator, order_by: [desc: f.inserted_at]
          end
          facilitators = Repo.all(query)
     end
    render conn, "facilitators.html", facilitators: facilitators

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
