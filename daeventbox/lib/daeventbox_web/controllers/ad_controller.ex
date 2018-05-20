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
    facilitator = Repo.get_by(Facilitator, user_id: conn.assigns[:current_user].id)
    option = Repo.get(Option, String.to_integer(params["option_id"]))
    days_decimal = Decimal.new(params["days"])
    price = Decimal.mult(days_decimal, option.price)
    # price = String.to_integer(params["days"]) * option.price
    ad_params = %{type: "internal" ,option_id: params["option_id"] , event_id: params["event_id"], name: params["name"], image:  params["image"], user_id: conn.assigns[:current_user].id, facilitator_id: facilitator.id, days: params["days"], price: price}
    changeset = Ad.changeset(%Ad{}, ad_params)

      case Repo.insert(changeset) do
        {:ok, _ad} -> IO.puts "Created AD"
        {:error, reason} -> IO.inspect reason
      end
    redirect conn, to:  "/facilitator"
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
    Repo.delete!(ad)

    conn
    |> put_flash(:info, "ad deleted successfully.")
    |> redirect(to: "/facilitator")

  end

  def view(conn, params) do

  # render conn, "view.html", option: option, event: event, ad: ad
  end

  def view_all(conn, params) do
    facilitator = Repo.get_by(Facilitator, user_id: conn.assigns[:current_user].id)
    query = from a in Ad, join: e in Event, join: o in Option,  where: a.event_id == e.id and a.option_id == o.id and a.facilitator_id== ^facilitator.id , select: [a.name, e.title, a.inserted_at, o.position, a.days, a.price, a.id]
    ads = Repo.all(query)
    IO.inspect ads
    render conn, "view_all.html", ads: ads
  end
  def select(conn, params) do

    event = Repo.get!(Event, params["id"])

    render conn, "options.html", event: event
  end

  def ad_form(conn,params) do
    event = Repo.get!(Event, params["id"])
    option_id = params["option_id"]

    render conn, "form.html", event: event, option_id: option_id

  end

end
