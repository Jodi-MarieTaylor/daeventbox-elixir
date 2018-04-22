defmodule DaeventboxWeb.Router do
  use DaeventboxWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers

  end

  pipeline :secure do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers

     plug Daeventbox.Plugs.CurrentUser
  end

  pipeline :with_session do
    plug Daeventbox.Pipeline
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource, allow_blank: true
    plug Daeventbox.CurrentUser
  end

  pipeline :login_required do
   plug Guardian.Plug.EnsureAuthenticated,
        handler: Daeventbox.GuardianErrorHandler
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/payment", DaeventboxWeb do
    pipe_through :browser

    get "/card-info", PaymentController, :payment_form
    get "/process", PaymentController, :make_payment
  end

  scope "/event", DaeventboxWeb do
    pipe_through [:browser, :with_session] # Use the default browser stack
    get "/create", EventController, :create
    post "/add", EventController, :add
  end

  scope "/facilitator", DaeventboxWeb do
    pipe_through [:browser, :with_session] # Use the default browser stack
    get "/switch", FacilitatorController, :switch
    get "/change/mode", FacilitatorController, :changemode
    get "/event/search", FacilitatorController, :eventsearch
    get "/event/dashboard/:title", FacilitatorController, :dashboard
    get "/" , FacilitatorController, :home
    post "/", FacilitatorController, :home
  end
  scope "/guest", DaeventboxWeb do
    pipe_through [:secure, :with_session] # Use the default browser stack

    get "/" , GuestController, :home

  end


  scope "/", DaeventboxWeb do
    pipe_through [:browser, :with_session] # Use the default browser stack

    get "/", PageController, :index
    get "/register", AuthController, :signup
    get "/login", AuthController, :login
    get "/logout", AuthController, :logout
    post "/user/create", SessionController, :signup
    post "/signin", SessionController, :signin
    resources "/messages", MessageController
    resources "/rooms", RoomController


  end

  # Other scopes may use custom stacks.
  # scope "/api", DaeventboxWeb do
  #   pipe_through :api
  # end
end
