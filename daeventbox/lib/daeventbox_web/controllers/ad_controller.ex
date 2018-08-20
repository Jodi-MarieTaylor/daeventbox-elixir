defmodule DaeventboxWeb.AdController do
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
  alias Daeventbox.Option
  alias Daeventbox.Ad


  def create(conn, params) do
    {:ok, resp} = Utils.AmazonS3.file_upload(params)
    image_url = convert_url(resp.url)

    facilitator = Repo.get_by(Facilitator, user_id: conn.assigns[:current_user].id)
    option = Repo.get(Option, String.to_integer(params["option_id"]))
    days_decimal = Decimal.new(params["days"])
    # price = Decimal.mult(days_decimal, option.price)
    price = String.to_integer(params["days"]) * option.price
    ad_params = %{type: "internal" ,option_id: params["option_id"] , event_id: params["event_id"], status: "active", name: params["name"], image_url:  image_url, user_id: conn.assigns[:current_user].id, facilitator_id: facilitator.id, days: params["days"], price: price}
    changeset = Ad.changeset(%Ad{}, ad_params)

      case Repo.insert(changeset) do
        {:ok, _ad} -> IO.puts "Created AD"
        {:error, reason} -> IO.inspect reason
      end
    redirect conn, to:  "/facilitator/manage"
  end

  def ad_option(conn, params) do

    bottom_option_params = %{type: "internal" , position: "bottom" , description: "Banner will show near footer on all pages", name: params["name"], zid:  Ecto.UUID.generate, size: "780px X 100px",  max_days: 60, price: 5.00}
    top_option_params = %{type: "internal" , position: "top" , description: "Banner will show at the top of the site on the Homepage", name: params["name"], zid:  Ecto.UUID.generate, size: "7728px X 100px", max_days: 90, price: 15.00}
    side_option_params = %{type: "internal" ,  position: "side" , description: "Banner will show on the right side of the Events page", name: params["name"], zid:  Ecto.UUID.generate, size: " 240px X 240px" , max_days: 60, price: 10.00}
    all_option_params = %{type: "internal" , position: "all" , description: "Banner will show at the footer, side, and top", name: params["name"], zid:  Ecto.UUID.generate, size: "7728px X 100px, 780px X 100px ,240px X 240px", max_days: 90, price: 20.00}
    external_option_params = %{type: "external" , position: "all" , description: "Banner will show at the footer, side, and top and is not an event", name: params["name"],zid:  Ecto.UUID.generate, size: "7728px X 100px, 780px X 100px ,240px X 240px", max_days: 90 , price: 20.00}

    bottom_option_changeset = Option.changeset(%Option{}, bottom_option_params)
    top_option_changeset = Option.changeset(%Option{}, top_option_params)
    side_option_changeset = Option.changeset(%Option{}, side_option_params)
    all_option_changeset = Option.changeset(%Option{}, all_option_params)
    external_option_changeset = Option.changeset(%Option{}, external_option_params)
    Repo.insert!(bottom_option_changeset)
    Repo.insert!(side_option_changeset)
    Repo.insert!(all_option_changeset)
    Repo.insert!(top_option_changeset)
    Repo.insert!(external_option_changeset)

  end
  def pay(conn, params) do
  end

  def edit(conn, params) do

  end

  def delete(conn, params) do

    ad = Repo.get!(Ad, params["id"])

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    #Repo.delete!(ad)
    required_params = %{is_deleted: true}
    changeset = Ad.changeset(ad, required_params)

    case Repo.update(changeset) do
      {:ok, _facilitator} ->
        conn
        |> put_flash(:info, "AD deleted successfully.")
        |> redirect(to: "/facilitator/manage")

      {:error, changeset} ->
        IO.inspect changeset
    end


  end

  def view(conn, params) do

  # render conn, "view.html", option: option, event: event, ad: ad
  end

  def view_all(conn, params) do
    per_page = params["page_size"] || 9
    page = params["page"] || "1"
    facilitator = Repo.get_by(Facilitator, user_id: conn.assigns[:current_user].id)
    query = from a in Ad, join: e in Event, join: o in Option,  where: a.event_id == e.id and a.option_id == o.id and a.facilitator_id== ^facilitator.id and  is_nil(a.is_deleted), select: [a.name, e.title, a.inserted_at, o.position, a.days, a.price, a.id, a.image_url], order_by: [desc: a.inserted_at]
    ad_num = Repo.all(query)  |> Enum.count
    pages = ad_num / per_page
    pages = Float.ceil(pages) |> Kernel.round
    ads = Paginate.query(query, per_page, page)
    IO.inspect ads
    render conn, "view_all.html", ads: ads, page_count: pages, page: page
  end
  def select(conn, params) do

    event = Repo.get!(Event, params["id"])
    ad_options = Repo.all(from o in Option, where: o.status == "enabled" )

    render conn, "options.html", event: event, ad_options: ad_options
  end

  def ad_form(conn,params) do
    event = Repo.get!(Event, params["id"])
    option_id = params["option_id"]
    option =  Repo.get!(Option, params["option_id"])

    render conn, "form.html", event: event, option_id: option_id, option: option

  end

  def ad_search(conn, params) do
    user_id = conn.assigns[:current_user].id
    per_page = params["page_size"] || 9
    page = params["page"] || "1"
    facilitator = Repo.get_by(Facilitator, user_id: user_id)
    aname = String.strip(params["name"]) |> String.split(" ") |> Enum.map( &String.capitalize/1 )|> Enum.join(" ")
    query = from a in Ad, join: e in Event, join: o in Option, where:  fragment("? ~* ?", a.name, ^aname) and  a.event_id == e.id and a.option_id == o.id and a.facilitator_id== ^facilitator.id and  is_nil(a.is_deleted), select: [a.name, e.title, a.inserted_at, o.position, a.days, a.price, a.id, a.image_url]
    ad_num = Repo.all(query)  |> Enum.count
    pages = ad_num / per_page
    pages = Float.ceil(pages) |> Kernel.round
    ads = Paginate.query(query, per_page, page)
    IO.inspect ads
    render conn, "view_all.html", ads: ads, page_count: pages, page: page

  end
  def convert_url(url) do
    String.replace(url, "https://d1l54leyvskqrr.cloudfront.net", "https://s3.us-east-2.amazonaws.com/daeventboximages")
  end

end
