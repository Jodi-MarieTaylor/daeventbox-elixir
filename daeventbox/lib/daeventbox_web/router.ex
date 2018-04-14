defmodule DaeventboxWeb.Router do
  use DaeventboxWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DaeventboxWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/register", AuthController, :signup
    get "/login", AuthController, :login
    get "/logout", AuthController, :logout
    post "/user/create", AuthController, :create_user
    post "/signin", AuthController, :signin
    get "/switch/facilitator", FacilitatorController, :switch
    get "/change/mode/facilitator", FacilitatorController, :changemode
    get "/event/create", EventController, :create
    post "/event/add", EventController, :add


  end

  # Other scopes may use custom stacks.
  # scope "/api", DaeventboxWeb do
  #   pipe_through :api
  # end
end
