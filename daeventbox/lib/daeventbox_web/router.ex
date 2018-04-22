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

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/payment", DaeventboxWeb do
    pipe_through :browser

    get "/card-info", PaymentController, :payment_form
    get "/process", PaymentController, :make_payment
  end

  scope "/event", DaeventboxWeb do
    pipe_through :secure # Use the default browser stack
    get "/create", EventController, :create
    post "/add", EventController, :add
    get "/edit", EventController, :edit
    delete "/delete", EventController, :delete
  end

  scope "/facilitator", DaeventboxWeb do
    pipe_through :secure # Use the default browser stack
    get "/switch", FacilitatorController, :switch
    get "/change/mode", FacilitatorController, :changemode
    get "/event/search", FacilitatorController, :eventsearch
    get "/event/dashboard/:title", FacilitatorController, :dashboard
    get "/" , FacilitatorController, :home
    post "/", FacilitatorController, :home
  end
  scope "/guest", DaeventboxWeb do
    pipe_through :secure # Use the default browser stack

    get "/" , GuestController, :home

  end


  scope "/", DaeventboxWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/register", AuthController, :signup
    get "/login", AuthController, :login
    get "/logout", AuthController, :logout
    post "/user/create", AuthController, :create_user
    post "/signin", AuthController, :signin




  end

  # Other scopes may use custom stacks.
  # scope "/api", DaeventboxWeb do
  #   pipe_through :api
  # end
end
