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



  scope "/chat", DaeventboxWeb do
    pipe_through [:browser, :with_session] # Use the default browser stack

    get "/", RoomController, :create
    post "/send", MessageController, :create
    get "/start", RoomController, :start
    get "/room/:id", RoomController, :show
    get "/send", MessageController, :create
    get "/view/messages", RoomController, :view_rooms
  end

  scope "/event", DaeventboxWeb do
    pipe_through [:browser, :with_session] # Use the default browser stack
    get "/create", EventController, :create
    post "/add", EventController, :add
    get "/edit/:id", EventController, :edit_form
    get "/delete/:id", EventController, :delete
    get "/details/:id", EventController, :details
    get "/manage/", EventController, :manage
    get "/save/:id", EventController, :save
    get "/unsave/:id", EventController, :unsave
    get "/like/:id", EventController, :like
    get "/unlike/:id", EventController, :unlike
    get "/register/:id", EventController, :register
    get "/buyticket/:id", EventController, :buy_tickets
    post "/ticket/selection/:id", EventController, :ticket_selection
    post "/registration/selected/:id", EventController, :registration_selection
    get "/makepayment/:id", EventController, :make_payment
    get "/registrationform/:id", EventController, :registration_form
    post "/register/proceed/:id", EventController, :add_registrations
    post "/add/ticket/:id", EventController, :add_ticket
    get "/upcoming/filter", EventController, :filter_events
    get "/upcoming", EventController, :upcoming_events
    get "/facilitators", EventController, :facilitators
    get "/facilitators/filter", EventController, :filter_facilitators
    post "/add/comment/:event_id" , EventController, :add_comment
    post "/update/:id", EventController, :update

  end

  scope "/account", DaeventboxWeb do
    pipe_through [:browser, :with_session] # Use the default browser stack
    get "/settings", AccountController, :account_settings
    post "/submit/email-preferences/",AccountController, :update_email
    post "/submit/user-general/",AccountController, :update_user
    post "/submit/close-account/",AccountController, :close_account
    post "/submit/password-change/",AccountController, :update_password
  end

  scope "/notify", DaeventboxWeb do
    pipe_through [:browser, :with_session] # Use the default browser stack
    get "/send", NotificationController, :notify
    post "/send", NotificationController, :notify
    get "/", NotificationController, :notifications
    post "/delete/:notification_id/:user_id", NotificationController, :notifications

  end

  scope "/ad", DaeventboxWeb do
      pipe_through [:browser, :with_session] # Use the default browser stack
      get "/options", AdController, :ad_option
      get "/select/:id", AdController, :select
      get "/selection/form/:option_id/:id", AdController, :ad_form
      post "/create", AdController, :create
      get "/view/all", AdController, :view_all
  end
  scope "/facilitator", DaeventboxWeb do
    pipe_through [:browser, :with_session] # Use the default browser stack
    get "/switch", FacilitatorController, :switch
    get "/change/mode", FacilitatorController, :changemode
    get "/event/search", FacilitatorController, :eventsearch
    get "/event/dashboard/:title/:id", FacilitatorController, :dashboard
    get "/profile/create", FacilitatorController, :profile_form
    get "/profile/edit", FacilitatorController, :profile_edit
    get "/manage", FacilitatorController, :manage
    get "/export/:id", FacilitatorController, :export
    post "/add", FacilitatorController, :add_facilitator
    get "/profile/preview", FacilitatorController, :profile_preview
    post "/profile/update", FacilitatorController, :update_profile
    post "/add/announcement/:event_id/:facilitator_id", NotificationController, :add_from_facilitator
    get "/profile", FacilitatorController, :profile
    get "/follow/:facilitator_id", FacilitatorController, :follow
    get "/unfollow/:facilitator_id", FacilitatorController, :unfollow
    get "/" , FacilitatorController, :home
    post "/", FacilitatorController, :home
  end
  scope "/guest", DaeventboxWeb do
    pipe_through [:secure, :with_session] # Use the default browser stack

    get "/" , GuestController, :home


  end
  scope "/admin", DaeventboxWeb do
    pipe_through [:browser, :with_session] # Use the default browser stack
    post "/facilitator/create", AdminController, :index
    post "/event/create", AdminController, :index
    get "/", AdminController, :index
    get "/user", AdminController, :user
    get "/login", AdminController, :login
    post "/signin", AdminController, :signin
    get "/events", AdminController, :events
    get "/event/view/:id", AdminController, :event_details
    get "/event/delete/:id", AdminController, :delete_event
    get "/tickets/:event_id", AdminController, :tickets
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
