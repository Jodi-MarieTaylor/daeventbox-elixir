defmodule DaeventboxWeb.AdminController do
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
  alias Daeventbox.Action
  alias Daeventbox.Ad
  alias Daeventbox.Registrationdetails
  alias Daeventbox.Ticketdetail
  alias Daeventbox.Faq
  alias Daeventbox.News
  alias Daeventbox.TransactionRequest
  alias Daeventbox.Charge
  alias Daeventbox.Notification
  alias Daeventbox.Announcement
  alias Daeventbox.Complaints
  alias Daeventbox.Option
  alias Daeventbox.SiteContent

  def login(conn, params) do
    IO.puts "IN THE ADMIN CONTROLLER BOUT TA RENDER LOGIN"
    conn
    |> put_layout(:false)
    |> render("login.html")
  end

    #process login
  def signin(conn, %{"email" => email, "password" => password} = params) do
    case Daeventbox.Auth.login_by_email_and_pass(conn, String.trim(String.downcase(email)), password) do
      {:ok, conn} ->
        IO.inspect conn.assigns
        user = conn.assigns[:current_user]
        time_in_secs_from_now = 86400 * 90
        conn
          |> delete_resp_cookie("daeventboxuser")
          |> delete_resp_cookie("daeventboxuser")
          |> put_resp_cookie("daeventboxuser", user.zid, max_age: time_in_secs_from_now)
          |> put_resp_cookie("daeventboxmode", "Guest", max_age: time_in_secs_from_now)

          |> put_flash(:info, "Logged in")
          |> redirect(to: "/admin?p=facilitators"  )
      {:error, reason, conn} ->
        IO.inspect reason
        case reason do
          :unauthorized ->
              conn
                |> put_flash(:error, "Bad Credentials")
                |> redirect(to: "/login")
          :not_found ->
              conn
                |> put_flash(:error, "User does not exist")
                |> redirect(to: "/login")
        end
    end
  end

  def event_details(conn, params) do
    event = Repo.get_by(Event, id: params["id"])
    facilitator = Repo.get_by(Facilitator, id: event.facilitator_id)
    tickets = Repo.all(from t in Ticket, where: t.event_id == ^event.id) |> Enum.count
    ads = Repo.all(from a in Ad, where: a.event_id == ^event.id) |> Enum.count
    registrations = Repo.all(from r in Registration, where: r.event_id == ^event.id) |> Enum.count
    ticket_details = Repo.all(from ti in Ticketdetail, where: ti.event_id == ^event.id)
    registration_details = Repo.all(from re in Registrationdetails, where: re.event_id == ^event.id)

    conn
    |> put_layout(:false)
    |> render "event-details.html",ticket_details: ticket_details,registration_details: registration_details,  event: event, facilitator: facilitator, registrations: registrations, tickets: tickets, ads: ads
  end

  def dashboard(conn, params) do
    total_events = Repo.all(from e in Event) |> Enum.count
    total_facilitators = Repo.all(from f in Facilitator) |> Enum.count
    total_users = Repo.all(from u in User) |> Enum.count
    total_registrations = Repo.all(from r in Registration)|> Enum.count
    total_tickets = Repo.all(from t in Ticket) |> Enum.count
    total_paid_transactions = total_tickets + total_registrations
    # clicks = Repo.all(from a in Action, where: a.action == "click")  |> Enum.count
    # opens = Repo.all(from a in Action, where: o.action == "open") |> Enum.count
    visits = Repo.all(from a in Action, where: a.action == "visit" ) |> Enum.count
    events = Repo.all(from e in Event, order_by: [desc: e.inserted_at], limit: 10)
    facilitators = Repo.all(from f in Facilitator, order_by: [desc: f.inserted_at], limit: 10)
    conn
    |> put_layout(:false)
    |> render "admin-dashboard.html",events: events, facilitators: facilitators, total_events: total_events, total_facilitators: total_facilitators, total_users: total_users,  total_paid_transactions: total_paid_transactions, visits: visits

  end



  def index(conn, params) do


    IO.puts "PROMPT"

    cond do
      params["p"] == "admin-dashboard" ->
        # this should be per week
        total_events = Repo.all(from e in Event) |> Enum.count
        total_facilitators = Repo.all(from f in Facilitator) |> Enum.count
        total_users = Repo.all(from u in User) |> Enum.count
        total_registrations = Repo.all(from r in Registration)|> Enum.count
        total_tickets = Repo.all(from t in Ticket) |> Enum.count
        total_paid_transactions = total_tickets + total_registrations
        # clicks = Repo.all(from a in Action, where: a.action == "click")  |> Enum.count
        # opens = Repo.all(from a in Action, where: o.action == "open") |> Enum.count
        visits = Repo.all(from a in Action, where: a.action == "visit" ) |> Enum.count
        events = Repo.all(from e in Event, order_by: [desc: e.inserted_at], limit: 10)
        facilitators = Repo.all(from f in Facilitator, order_by: [desc: f.inserted_at], limit: 10)
        conn
        |> put_layout(:false)
        |> render "admin-dashboard.html",events: events, facilitators: facilitators, total_events: total_events, total_facilitators: total_facilitators, total_users: total_users,  total_paid_transactions: total_paid_transactions, visits: visits
      params["p"] == "facilitators" ->
        facilitators(conn, params)
      params["p"] == "view-facilitator" ->
        view_facilitator(conn, params)
      params["p"] == "delete-facilitator" ->
        delete_facilitator(conn, params)
      params["p"] == "events" ->
        events(conn,params)
      true ->
        conn

        |> put_layout(:false)
        |> render "#{params["p"]}.html"

    end
  end

  def events(conn,params) do
    cond do
      params["action"] ->
        cond do
          params["action"] == "delete" -> delete_event(conn,params)
          params["action"] == "create" -> create_event(conn, params)
          params["action"] == "view" -> view_event(conn, params)
        end

     params["filterby"]  ->
        events_filter(conn, params)
     true ->
        events = Repo.all(from e in Event)
        conn
        |> put_layout(:false)
        |> render "events.html", events: events

    end
  end

  def create_event(conn, params) do


      #if there is no facilitator record( meaning the person is new)  add the record
      if is_nil(Repo.get_by(Facilitator, user_id: conn.assigns[:current_user].id)) do
        facil_params = %{name: params["facilitator_name"], facilitator_zid:  Ecto.UUID.generate, user_id: 0}
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
      required_params = %{title: params["title"], facilitator_name: facilitator.name, user_id: 0, facilitator_id: facilitator.id, status: "active",
       image_url: image_url, start_date: params["start_date"], start_time: params["start_time"], end_date: params["end_date"], end_time: params["end_time"], category: params["category"], description: params["description"],
       fb_link: params["fb_link"], insta_link: params["insta_link"],  twitter_link: params["twitter_link"], type: params["type"], admission_type: params["admission_type"], location: "#{params["address1"]}, #{params["address2"]}, #{params["parish"]}, Jamaica",
       details: %{}, event_zid:  Ecto.UUID.generate, venue_name: params["venue_name"], location_info: %{parish: params["parish"], address1: params["address1"], address2: params["address2"], country: "Jamaica"}}
      changeset = Event.changeset(%Event{}, required_params)
      case Repo.insert(changeset) do
        {:ok, event} ->
          if params["type"]== "paid" do
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
          else
            registration_params = %{event_id: event.id, max_quantity:  params["registration_quantity"], status: "pending", active: 1}
            registration_changeset = Registrationdetails.changeset(%Registrationdetails{}, registration_params)
              case Repo.insert(registration_changeset) do
                  {:ok, reg} -> IO.puts "Reg free details good"
                  {:error, changeset} -> IO.inspect changeset
              end

          end
        {:error, changeset} ->
            IO.inspect changeset
             conn
            |> put_layout(:false)
            |> put_flash(:info, "Event created successfully.")
            |> render "create-event.html", changeset: changeset, params: params

      end
      events = Repo.all(from e in Event)
      conn
      |> put_layout(:false)
      |> put_flash(:info, "Event created successfully.")
      |> render "events.html", events: events
      # Webapp.Mailer.send_welcome_email(user.email)
  end

  def view_event(conn, params) do
  end
  def create_event_view(conn, params) do
    conn
      |> put_layout(:false)
      |> render "create-event.html"
  end


  def events_filter(conn, params) do
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
        query =
          if params["date"] == "asc" do
            from e in Event, where: e.id > 15, order_by: [asc: e.inserted_at]
          else
            from e in Event, where: e.id > 15, order_by: [desc: e.inserted_at]
          end
        events = Repo.all(query)

      params["reset"] ->
        events = Repo.all(from e in Event)
    end
    conn
    |> put_layout(:false)
    |> render "events.html", events: events
  end




   def delete_event(conn, params) do
      event = Repo.get!(Event, params["eid"])
      case Repo.delete(event) do
        {:ok, _facilitator} ->
          conn
          |> put_flash(:info, "Deleted Successfully")
          |> redirect(to: "/admin/events")

        {:error, changeset} ->
          IO.inspect changeset
          events = Repo.all(from e in Event)
          conn
          |> put_flash(:error, "Oops error! Please try again")
          |> render "events.html", events: events
      end
  end



  def dashboard(conn, params) do
  end

  def facilitators(conn,params) do
    if params["filter"]  do
      facilitators_filter(conn, params)
    else
      facilitators = Repo.all(from f in Facilitator)
      conn
      |> put_layout(:false)
      |> render "facilitators.html", facilitators: facilitators

    end
  end

  def facilitators_filter(conn, params) do

     cond do
      params["filter"] == "asc" ->
        query =  from f in Facilitator,  order_by: [asc: f.name]
        facilitators = Repo.all(query)

      params["filter"] == "desc" ->
        query = from f in Facilitator, order_by: [desc: f.name]
        facilitators = Repo.all(query)

      params["filter"] == "mostpopular" ->
        query =  from f in Facilitator,  order_by: [asc: f.name]
        facilitators = Repo.all(query)

      params["filter"] == "leastpopular" ->
        query = from f in Facilitator, order_by: [desc: f.name]
        facilitators = Repo.all(query)

      params["filter"] == "mostevents" ->
       query =  from f in Facilitator,  order_by: [asc: f.name]
       facilitators = Repo.all(query)

      params["filter"] == "leastevents" ->
       query =  from f in Facilitator, order_by: [desc: f.name]
       facilitators = Repo.all(query)

      params["filter"] == "oldestdate" ->
          query = from f in Facilitator,  order_by: [asc: f.inserted_at]
          facilitators = Repo.all(query)

      params["filter"] == "latestdate" ->
          query = from f in Facilitator, order_by: [desc: f.inserted_at]
          facilitators = Repo.all(query)
     end
    conn
    |> put_layout(:false)
    |> render "facilitators.html", facilitators: facilitators
  end
  def user(conn, params) do
    IO.puts "PROMPT"
    conn

    |> put_layout(:false)
    |> render "user.html"
  end

  def create_facilitator(conn, params) do

     required_params = %{name: params["name"], about: params["about"], website_link: params["website"], fb_link: params["facebook"], insta_link: params["instagram"],
    twitter_link: params["twitter"], image: params["image"], image_url: params["image_url"], facilitator_email: params["email"], facilitator_phone: params["phone"],
    facilitator_address: params["address"], facilitator_contact: params["contactname"], facilitator_zid:  Ecto.UUID.generate,user_id: conn.assigns[:current_user].id}
      IO.inspect params
    changeset = Facilitator.changeset(%Facilitator{}, required_params)
    case Repo.insert(changeset) do
      {:ok, _facilitator} ->
        conn
        |> put_layout(:false)
        |> put_flash(:info, "Event updated successfully.")
        |> redirect(to: "/admin?facilitators")

      {:error, changeset} ->
        IO.inspect changeset
        conn
        |> put_layout(:false)
        |> put_flash(:error, "Oops error! Please try again")
        |> redirect( to: "/admin?p=create-facilitator")
    end

  end

  def view_facilitator(conn, params) do
    facilitator = Repo.get_by(Facilitator,id: params["i"])
    conn
    |> put_layout(:false)
    |> render "view-facilitator.html", facilitator: facilitator
  end


  def delete_facilitator(conn, params) do
      facilitator = Repo.get!(Facilitator, params["fid"])
      case Repo.delete(facilitator) do
        {:ok, _facilitator} ->
          conn
          |> put_layout(:false)
          |> put_flash(:info, "Deleted Successfully")
          |> redirect(to: "/admin?p=facilitators")

        {:error, changeset} ->
          IO.inspect changeset
          conn
          |> put_layout(:false)
          |> put_flash(:error, "Oops error! Please try again")
          |> render "view-facilitator.html", facilitator: facilitator
      end
  end

  def add_admin(conn, params) do


  end


  def tickets(conn, params) do
    event = Repo.get!(Event, params["event_id"])
    tickets = Repo.all(from t in Ticket, where: t.event_id == ^params["event_id"])
    ticket_details = Repo.all(from ti in Ticketdetail, where: ti.event_id == ^params["event_id"])
    conn
    |> put_layout(:false)
    |> render "tickets.html", tickets: tickets, event: event, ticket_details: ticket_details

  end

  def filter_tickets(conn, params) do
    event = Repo.get!(Event, params["event_id"])

    ticket_details = Repo.all(from ti in Ticketdetail, where: ti.event_id == ^params["event_id"])
    cond do
      params["status"] ->
        query = from t in Ticket, where: t.status == ^params["status"] and t.event_id == ^params["event_id"]
        tickets = Repo.all(query)
      params["name"] ->
         ticket_detail = Repo.one(from td in Ticketdetail , where: td.name == ^params["name"] and td.event_id == ^params["event_id"])
         query = from t in Ticket, where: t.ticket_id == ^ticket_detail.id and t.event_id == ^params["event_id"]
         tickets = Repo.all(query)
      params["price"] ->
        ticket_detail = Repo.one(from td in Ticketdetail , where: td.price == ^params["price"] and td.event_id == ^params["event_id"])
        query = from t in Ticket, where: t.ticket_id == ^ticket_detail.id and t.event_id == ^params["event_id"]
        tickets=Repo.all(query)
      params["date"] ->
        query =
          if params["date"] == "asc" do
            from t in Ticket, where: t.event_id == ^params["event_id"],  order_by: [asc: t.inserted_at]
          else
            from t in Ticket, where: t.event_id == ^params["event_id"],  order_by: [desc: t.inserted_at]
          end
         tickets = Repo.all(query)
      params["reset"] ->
        tickets = Repo.all(from t in Ticket, where: t.event_id == ^params["event_id"])
     end
    conn
    |> put_layout(:false)
    |> render "tickets.html", tickets: tickets, event: event, ticket_details: ticket_details

  end



  def filter_d_registrations(conn, params) do
    event = Repo.get!(Event, params["event_id"])
    registrations = Repo.all(from r in Registration, where: r.event_id == ^params["event_id"])
    registration_details = Repo.all(from re in Registrationdetails, where: re.event_id == ^params["event_id"])
    conn
    |> put_layout(:false)
    |> render "registrations.html", registrations: registrations, event: event,registration_details: registration_details

  end

  def registrations(conn, params) do
    event = Repo.get!(Event, params["event_id"])
    registrations = Repo.all(from r in Registration, where: r.event_id == ^params["event_id"])
    registration_details = Repo.all(from re in Registrationdetails, where: re.event_id == ^params["event_id"])
    conn
    |> put_layout(:false)
    |> render "registrations.html", registrations: registrations, event: event,registration_details: registration_details

  end

  def email(conn, params) do
    conn
    |> put_layout(:false)
    |> render "email.html"

  end

  def ads(conn, params) do
    options= Repo.all(from o in Option)

    if params["event_id"] do
      ads = Repo.all(from a in Ad, where: a.event_id == ^params["event_id"])
      event = Repo.get!(Event, params["event_id"])
      conn
      |> put_layout(:false)
      |> render "ads.html", ads: ads, options: options, event: event
    else
      ads = Repo.all(from a in Ad)
      conn
      |> put_layout(:false)
      |> render "all_ads.html", ads: ads, options: options
    end
  end

  def ads_filter(conn, params) do
    options= Repo.all(from o in Option)
    if params["event_id"] do
      event = Repo.get!(Event, params["event_id"])
      cond do
        params["status"] ->
          query = from a in Ad, where: a.status == ^params["status"] and a.event_id == ^params["event_id"]
          ads = Repo.all(query)
        params["position"] ->
          option = Repo.one(from o in Option , where: o.position == ^params["position"] )
          query = from a in Ad, where: a.option_id == ^option.id and a.event_id == ^params["event_id"]
          ads = Repo.all(query)
        params["days"] ->
          query =
            if params["days"] == "asc" do
              from a in Ad, where: a.event_id == ^params["event_id"], order_by: [asc: a.days]
            else
              from a in Ad, where: a.event_id == ^params["event_id"], order_by: [desc: a.days]
            end
          ads=Repo.all(query)
        params["date"] ->
          query =
            if params["date"] == "asc" do
              from a in Ad, where: a.event_id == ^params["event_id"],  order_by: [asc: a.inserted_at]
            else
              from a in Ad, where: a.event_id == ^params["event_id"],  order_by: [desc: a.inserted_at]
            end
          ads = Repo.all(query)
       end
       conn
        |> put_layout(:false)
        |> render "ads.html", ads: ads, options: options, event: event
    else
       cond do
        params["status"] ->
          query = from a in Ad, where: a.status == ^params["status"]
          ads = Repo.all(query)
        params["position"] ->
          option = Repo.one(from o in Option , where: o.position== ^params["position"])
          query = from a in Ad, where: a.option_id == ^option.id
          ads = Repo.all(query)
        params["days"] ->
          query =
            if params["days"] == "asc" do
              from a in Ad,  order_by: [asc: a.days]
            else
              from a in Ad, order_by: [desc: a.days]
            end
          ads=Repo.all(query)
        params["date"] ->
          query =
            if params["date"] == "asc" do
              from a in Ad,  order_by: [asc: a.inserted_at]
            else
              from a in Ad,  order_by: [desc: a.inserted_at]
            end
          ads = Repo.all(query)
       end
      conn
      |> put_layout(:false)
      |> render "all_ads.html", ads: ads, options: options
    end
  end

  def faqs(conn, params) do
    faqs = Repo.all(from f in Faq)
    conn
    |> put_layout(:false)
    |> render "faqs.html", faqs: faqs
  end

  def add_faqs(conn, params) do
    required_params = %{question: params["question"], answer: params["answer"]}
    faqs_changeset = Faq.changeset(%Faq{}, required_params)
      case Repo.insert(faqs_changeset) do
        {:ok, faq} -> IO.puts "Added FAQ"
        {:error, changeset} -> IO.inspect changeset
      end
    faqs = Repo.all(from f in Faq)
    conn
    |> put_layout(:false)
    |> redirect(to: "/admin/faqs")
  end

  def delete_faq(conn, params) do
    faq = Repo.get!(Faq, params["faq_id"])
    Repo.delete!(faq)
    conn
    |> put_layout(:false)
    |> redirect(to: "/admin/faqs")
  end

  def news(conn, params) do
    news_list = Repo.all(from n in News)
    conn
    |> put_layout(:false)
    |> render "news.html", news_list: news_list

  end
  def add_news(conn, params) do
    conn
    |> put_layout(:false)
    |> render "add_news.html"
  end

  def create_news(conn, params) do
   #{:ok, resp} = Utils.AmazonS3.file_upload(params)

   # image_url = convert_url(resp.url)

    required_params = %{title: params["title"], body: params["body"]}

    changeset = News.changeset(%News{}, required_params)
    case Repo.insert(changeset) do
      {:ok, news} ->
        conn
        |> put_layout(:false)
        |> put_flash(:info, "News Item successfully added.")
        |> redirect(to: "/admin/news")

      {:error, changeset} ->
        IO.inspect changeset
        conn
        |> put_layout(:false)
        |> put_flash(:error, "Oops error! Please try again")
        |> redirect( to: "/admin/news")
    end

  end

  def delete(conn, params) do
    news= Repo.get!(News, params["news_id"])
    Repo.delete!(news)
    conn
    |> put_layout(:false)
    |> put_flash(:info, "News Item successfully deleted.")
    |> redirect(to: "/admin/news")

  end

  def edit_aboutus(conn, params) do

    conn
    |> put_layout(:false)
    |> render "about-us.html"
  end

  def update_aboutus(conn, params) do
    if Repo.get_by(SiteContent, page: "about-us") do
      about = Repo.get_by(SiteContent, page: "about-us")
      changeset = SiteContent.changeset(about, %{ info: %{body: params["about"]}})
      case Repo.update changeset do
        {:ok, struct}       -> redirect conn, to: "/admin/aboutus/edit"
        {:error, changeset} -> IO.inspect changeset
      end
    else
      required_params = %{page: "about-us", info: %{body: params["about"]}}

      changeset = SiteContent.changeset(%SiteContent{}, required_params)
      case Repo.insert(changeset) do
        {:ok, content} ->
          conn
          |> put_layout(:false)
          |> put_flash(:info, "About Us Item successfully added.")
          |> redirect(to: "/admin/aboutus/edit")

        {:error, changeset} ->
          IO.inspect changeset
          conn
          |> put_layout(:false)
          |> put_flash(:error, "Oops error! Please try again")
          |> redirect( to: "/admin/aboutus/edit")
      end
    end

  end

  def edit_contactus(conn, params) do

    conn
    |> put_layout(:false)
    |> render "contact-us.html"

  end

  def update_contactus(conn, params) do
    if Repo.get_by(SiteContent, page: "contact-us") do
      required_params = %{page: "contact-us", info: %{ mobile_phone: params["mobile_phone"], work_phone: params["work_phone"], other_phone: params["other_phone"], email: params["email"], address: params["address"], start_time: params["start_time"], end_time: params["end_time"]}}

      contact = Repo.get_by(SiteContent, page: "contact-us")
      changeset = SiteContent.changeset(contact, required_params)
      case Repo.update changeset do
        {:ok, struct}       -> redirect conn, to: "/admin/contactus/edit"
        {:error, changeset} -> IO.inspect changeset
      end
    else
      required_params = %{page: "contact-us", info: %{ mobile_phone: params["mobile_phone"], work_phone: params["work_phone"], other_phone: params["other_phone"], email: params["email"], address: params["address"], start_time: params["start_time"], end_time: params["end_time"]}}

      changeset = SiteContent.changeset(%SiteContent{}, required_params)
      case Repo.insert(changeset) do
        {:ok, content} ->
          conn
          |> put_layout(:false)
          |> put_flash(:info, "About Us Item successfully added.")
          |> redirect(to: "/admin/contactus/edit")

        {:error, changeset} ->
          IO.inspect changeset
          conn
          |> put_layout(:false)
          |> put_flash(:error, "Oops error! Please try again")
          |> redirect( to: "/admin/contactus/edit")
      end
    end
  end

  def transactions(conn, params) do
    read_notifications("Transaction Request")
    facilitator = Repo.get_by(Facilitator, id: params["facilitator_id"] )
    events = Repo.all(from e in Event, where: e.facilitator_id == ^facilitator.id)
    transaction_requests = Repo.all(from t in TransactionRequest, where: t.facilitator_id == ^facilitator.id)
    conn
      |> put_layout(:false)
      |> render "transactions.html", facilitator: facilitator, events: events, transaction_requests: transaction_requests
  end
  def transactions_all(conn, params) do
    read_notifications("Transaction Request")
    events = Repo.all(from e in Event)
    transaction_requests = Repo.all(from t in TransactionRequest)
    conn
      |> put_layout(:false)
      |> render "transactions.html", facilitator: nil,  events: events, transaction_requests: transaction_requests
  end


  def payout(conn, params) do
    event = Repo.get_by(Event, id: params["event_id"])
    facilitator = Repo.get_by(Facilitator, id: event.facilitator_id )
    transaction_requests = Repo.all(from t in TransactionRequest, where: t.event_id == ^event.id)
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
    requests = Repo.all(from t in TransactionRequest, where: t.event_id == ^event.id)
    total_recieved = Repo.one(from t in TransactionRequest, where: t.event_id == ^event.id and t.status=="Paid", select: sum(t.amount))
    total_recieved  =
      if is_nil(total_recieved) do
        0.00
      else
        total_recieved
      end
    total_balance = total_earnings - total_charges - total_recieved
    total_paid = total_recieved
    conn
    |> put_layout(:false)
    |> render "payout.html", event: event, facilitator: facilitator, transaction_requests: transaction_requests, total_paid_transactions: total_paid_transactions, total_paid: total_paid, total_earnings: total_earnings, total_charges: total_charges, total_balance: total_balance
  end

  def charges(conn, params) do
    charges = Repo.all( from c in Charge)
    conn
    |> put_layout(:false)
    |> render "charges.html", charges: charges
  end

  def create_charge(conn, params) do
    conn
    |> put_layout(:false)
    |> render "create_charge.html"
  end

  def add_charge(conn, params) do
    required_params = %{charges: params["amount"], name: params["name"], status: "active", assigned_to: params["assigned_to"], type: params["type"]}
    changeset = Charge.changeset(%Charge{}, required_params)
    case Repo.insert(changeset) do
      {:ok, charge} -> IO.puts "Charge Added Successfully"
        redirect conn, to: "/admin/charges"
      {:error, changeset} -> IO.inspect changeset
    end
  end

  def edit_charge(conn, params) do
    charge = Repo.get_by(Charge, id: params["charge_id"])
    conn
    |> put_layout(:false)
    |> render  "edit_charge.html", charge: charge

  end

  def delete_charge(conn, params) do
    charge = Repo.get_by(Charge, id: params["charge_id"])
    Repo.delete!(charge)
    IO.puts "Succesfully deleted charge"
    redirect conn, to: "/admin/charges"
  end

  def change_transaction_status(conn, params) do
    transaction_request = Repo.get!(TransactionRequest, params["transaction_request_id"])
    changeset = TransactionRequest.changeset(transaction_request, %{status: params["status"]})
    case Repo.update changeset do
      {:ok, struct}       -> redirect conn, to: "/admin/transaction/requests/payout/#{transaction_request.event_id}"
      {:error, changeset} -> IO.inspect changeset
    end
  end
  def change_complaint_status(conn, params) do
      complaint = Repo.get!(Complaints, params["complaint_id"])
      changeset = Complaints.changeset(complaint, %{status: params["status"]})
      case Repo.update changeset do
        {:ok, struct}       -> redirect conn, to: "/admin/complaints"
        {:error, changeset} -> IO.inspect changeset
      end
    end

  def notifications(conn, params) do
    new_requests = Repo.all(from n in Notification, where: n.facilitator_id == 0 and n.type == "Transaction Request" and n.seen == false) |> Enum.count
    unseen_notifications = new_requests
    new_messages = 0
    new_complaints = Repo.all(from n in Notification, where: n.facilitator_id == 0 and n.type == "Complaint" and n.seen == false) |> Enum.count
    unseen_notifications = new_requests + new_complaints + new_messages
    data = %{unseen_notification: unseen_notifications, new_requests: new_requests, new_messages: new_messages, new_complaints: new_complaints}
    json(conn, data)
  end
  def read_notifications(type) do
    new_requests = Repo.all(from n in Notification, where: n.type == ^type and n.seen == false)
    for new_request <- new_requests do
      changeset = Notification.changeset(new_request, %{seen: true})
      case Repo.update changeset do
        {:ok, struct}       -> IO.puts "Read Notifications"
        {:error, changeset} -> IO.inspect changeset
      end
    end
  end

  def announcements(conn, params) do
    announcements = Repo.all(from a in Announcement, where: a.from_id == 0)
    conn
    |> put_layout(:false)
    |> render  "announcements.html", announcements: announcements
  end
  def create_announcement(conn, params) do
    conn
    |> put_layout(:false)
    |> render  "create-announcement.html"
  end
  def add_announcement(conn,params) do
    required_params = %{from: params["from"], from_id: 0 , message: params["message"], recipient: params["recipient"], event_id: nil, user_id: 0}
    changeset = Announcement.changeset(%Announcement{}, required_params)
    case Repo.insert(changeset) do
      {:ok, charge} -> IO.puts "Annoucement Added Successfully"
        add_notification_from_admin(params["recipient"], "Admin Announcement", params["message"])

        redirect conn, to: "/admin/announcements"

      {:error, changeset} -> IO.inspect changeset
    end

  end

   def add_notification_from_admin(recipient, type, message ) do
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
  def complaints(conn, params) do
    read_notifications("Complaint")
    complaints = Repo.all(from c in Complaints)
    conn
    |> put_layout(:false)
    |> render  "complaints.html", complaints: complaints
  end

  def ads_settings(conn, params) do
    options = Repo.all(from o in Option)
    conn
    |> put_layout(:false)
    |> render  "ads_settings.html", options: options
  end

  def ads_settings_edit(conn, params) do
    IO.inspect params
    ad_option = Repo.get_by(Option, id: params["option_id"])
    changeset = Option.changeset(ad_option, %{status: params["status"], name: params["title"], size: params["size"], max_days: params["max_days"], price: params["price"], type: params["type"], description: params["description"]})
    IO.inspect changeset
    case Repo.update changeset do
      {:ok, struct}       -> redirect conn, to: "/admin/ads/settings"
      {:error, changeset} -> IO.inspect changeset
        IO.puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!111"
    end

  end
   def convert_url(url) do
    String.replace(url, "https://d1l54leyvskqrr.cloudfront.net", "https://s3.us-east-2.amazonaws.com/daeventboximages")
  end

end
