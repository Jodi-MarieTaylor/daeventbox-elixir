defmodule DaeventboxWeb.Router do
  use DaeventboxWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers

  end

  pipeline :admin_route do
    plug :put_layout, {DaeventboxWeb.LayoutView, :admin_layout}

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

  pipeline :facilitator_required do
    plug Daeventbox.FaciliatorRequired
  end
  pipeline :admin_required do
    plug Daeventbox.AdminRequired
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/payment", DaeventboxWeb do
    pipe_through [:browser, :with_session, :login_required] # Use the default browser stack

    get "/card-info", PaymentController, :payment_form
    get "/process", PaymentController, :home
    post "/process/:event_id", PaymentController, :make_payment
  end


  scope "/help", DaeventboxWeb do
    pipe_through [:browser, :with_session] # Use the default browser stack

    post "/contact", HelpController, :contact
    get "/", HelpController, :index
  end




  scope "/chat", DaeventboxWeb do
    pipe_through [:browser, :with_session, :login_required] # Use the default browser stack

    get "/", RoomController, :create
    post "/send", MessageController, :create
    get "/start", RoomController, :start
    get "/room/:id", RoomController, :show
    get "/send", MessageController, :create
    get "/view/messages", RoomController, :view_rooms
    get "/check" , MessageController, :check

  end

  scope "/event", DaeventboxWeb do
    pipe_through [:browser, :with_session, :login_required] # Use the default browser stack

    get "/create", EventController, :create
    post "/add", EventController, :add
    get "/edit/:id", EventController, :edit_form
    get "/delete/:id", EventController, :delete
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

    post "/add/comment/:event_id" , EventController, :add_comment
    post "/update/:id", EventController, :update
    get "/earnings/:event_id", EventController, :earnings
    post "/transaction/request/:event_id", EventController, :transaction_request
    post "/report/add/:event_id", EventController, :report_event
    post "/rate/add/:event_id", EventController, :add_rating

    get "/manage/ticket/email/:ticket_id", EventController, :email_ticket
  end

  scope "/account", DaeventboxWeb do
    pipe_through [:browser, :with_session, :login_required] # Use the default browser stack
    get "/settings", AccountController, :account_settings
    post "/submit/email-preferences/",AccountController, :update_email
    post "/submit/user-general/",AccountController, :update_user
    post "/submit/close-account/",AccountController, :close_account
    post "/submit/password-change/",AccountController, :update_password
  end

  scope "/notify", DaeventboxWeb do
    pipe_through [:browser, :with_session, :login_required] # Use the default browser stack
    get "/send", NotificationController, :notify
    post "/send", NotificationController, :notify
    get "/", NotificationController, :notifications
    post "/delete/:notification_id/:user_id", NotificationController, :notifications

  end
  scope "/notification", DaeventboxWeb do
    pipe_through [:browser, :with_session] # Use the default browser stack
    get "/filter", NotificationController, :filter
    get "/hide/:notification_id/:user_id", NotificationController, :notification_delete_for_user


  end

  scope "/auth", DaeventboxWeb do
    pipe_through [:browser, :with_session] # Use the default browser stack
     get "/:provider", OAuthController, :request
    get "/:provider/callback", OAuthController, :callback
  end

  scope "/ad", DaeventboxWeb do
    pipe_through [:browser, :with_session, :login_required, :facilitator_required] # Use the default browser stack
      get "/options", AdController, :ad_option
      get "/select/:id", AdController, :select
      get "/selection/form/:option_id/:id", AdController, :ad_form
      post "/create", AdController, :create
      get "/view/all/search/", AdController, :ad_search
      get "/view/all", AdController, :view_all
      get "/delete/:id", AdController, :delete
      get "/payment", AdController, :payments
  end

  scope "/facilitator", DaeventboxWeb do
    pipe_through [:browser, :with_session, :login_required, :facilitator_required] # Use the default browser stack

    get "/event/search", FacilitatorController, :eventsearch
    get "/event/dashboard/:title/:id", FacilitatorController, :dashboard

    get "/profile/edit", FacilitatorController, :profile_edit
    get "/manage", FacilitatorController, :manage
    get "/export/:id", FacilitatorController, :export

    get "/profile/preview", FacilitatorController, :profile_preview
    post "/profile/update", FacilitatorController, :update_profile
    post "/add/announcement/:event_id/:facilitator_id", NotificationController, :add_from_facilitator

    get "/manage/search/events", FacilitatorController, :search_events
    get "/" , FacilitatorController, :home
    post "/", FacilitatorController, :home

  end
  scope "/facilitator", DaeventboxWeb do
    pipe_through [:browser, :with_session, :login_required] # Use the default browser stack
    post "/add", FacilitatorController, :add_facilitator


    get "/profile", FacilitatorController, :profile
    get "/follow/:facilitator_id", FacilitatorController, :follow
    get "/unfollow/:facilitator_id", FacilitatorController, :unfollow

    post "/report/add/:facilitator_id", FacilitatorController, :report_facilitator
  end

  scope "/guest", DaeventboxWeb do
    pipe_through [:browser, :with_session, :login_required] # Use the default browser stack

    get "/" , GuestController, :home


  end

  scope "/admin", DaeventboxWeb do
    pipe_through [:browser, :with_session, :admin_required, :admin_route] # Use the default browser stack
    post "/facilitator/create", AdminController, :index
    get "/facilitators", AdminController, :facilitators
    get "/facilitator/view", AdminController, :view_facilitator
    get "/facilitator/delete", AdminController, :delete_facilitator
    get "/dashboard", AdminController, :dashboard
    post "/event/create", AdminController, :index
    get "/event/create", AdminController, :create_event_view
    get "/", AdminController, :index
    get "/user", AdminController, :user

    get "/events", AdminController, :events
    get "/event/view/:id", AdminController, :event_details
    get "/event/delete/:id", AdminController, :delete_event
    get "/tickets/:event_id", AdminController, :tickets
    get "/tickets/:event_id/filter", AdminController, :filter_tickets
    get "/registrations/:event_id", AdminController, :registrations
    get "/registrations/:event_id/filter", AdminController, :filter_d_registrations
     get "/email", AdminController, :email
     get "/ads/settings", AdminController, :ads_settings
    post "/ads/settings/options/edit/:option_id", AdminController, :ads_settings_edit
     get "/ads/:event_id/filter", AdminController, :ads_filter
    get "/ads/filter", AdminController, :ads_filter
    get "/reports",  AdminController, :reports
    get "/ads/:event_id", AdminController, :ads
    get "/ads", AdminController, :ads
    get "/faqs", AdminController, :faqs
    post "/add/faq", AdminController, :add_faqs
    get "/faq/delete/:faq_id", AdminController, :delete_faq
    get "/news", AdminController, :news
    get "/news/add", AdminController, :add_news
    post "/news/add", AdminController, :create_news
    get "/news/delete/:news_id", AdminController, :delete_news
    get "/aboutus/edit", AdminController, :edit_aboutus
    post "/aboutus/update", AdminController, :update_aboutus
    get "/contactus/edit", AdminController, :edit_contactus
    post "/contactus/update", AdminController, :update_contactus
    get "/logout", AdminController, :logout

    get "/transaction/requests/payout/:event_id", AdminController, :payout
    get  "/transaction/requests/transactions/:facilitator_id", AdminController, :transactions
    get  "/transaction/requests/transactions", AdminController, :transactions_all

    get "/transaction/requests/all", AdminController, :requests
    post "/transaction/change/status/:transaction_request_id", AdminController, :change_transaction_status
    get "/charges/edit/:charge_id", AdminController, :edit_charge
    get "/charges/create", AdminController, :create_charge
    post "/charges/add", AdminController, :add_charge
    get "/charges/delete/:charge_id", AdminController, :delete_charge
    get "/charges", AdminController, :charges
    get "/notify/send", AdminController, :notifications
    get "/announcements/create", AdminController, :create_announcement
    post "/annoucements/add", AdminController, :add_announcement
    get "/announcements", AdminController, :announcements
    get "/complaints", AdminController, :complaints
    get "/messages", AdminController, :message_inquiry
    post "/complaint/change/status/:complaint_id", AdminController, :change_complaint_status
    post "/message/change/status/:inquiry_id", AdminController, :change_message_status

  end

  scope "/", DaeventboxWeb do
    pipe_through [:browser, :with_session, :login_required] # Use the default browser stack


    resources "/messages", MessageController
    resources "/rooms", RoomController

    get "/logout", SessionController, :logout

  end

  scope "/", DaeventboxWeb do
    pipe_through [:browser, :with_session] # Use the default browser stack

    get "/facilitator/switch", FacilitatorController, :switch
    get "/facilitator/change/mode", FacilitatorController, :changemode
    get "/facilitator/profile/create", FacilitatorController, :profile_form
    get "/event/upcoming/filter", EventController, :filter_events
    get "/event/upcoming", EventController, :upcoming_events
    get "/event/facilitators", EventController, :facilitators
    get "/event/facilitators/filter", EventController, :filter_facilitators
    get "/event/details/:id", EventController, :details
    get "/event/search", EventController, :search
    get "/aboutus", PageController, :about_us
    get "/contactus", PageController, :contact_us
    post "/contact/send", PageController, :contact_send
    get "/daeventbox", PageController, :daeventbox
    get "/privacypolicy", PageController, :privacypolicy
    get "/", PageController, :index

    # admin login
    get "/admin/login", AdminController, :login
    post "/admin/signin", AdminController, :signin

    # render pages
    get "/register", AuthController, :signup
    get "/login", AuthController, :login

    # process requests
    post "/user/create", SessionController, :signup
    post "/signin", SessionController, :signin

    #render pages
    get "/recover", SessionController, :reset_password
    get "/reset-password", SessionController, :recover

    #process requests
    post "/recover", SessionController, :reset_password
    post "/reset-password", SessionController, :recover

    get "/*path", PageController, :index
  end


  # Other scopes may use custom stacks.
  # scope "/api", DaeventboxWeb do
  #   pipe_through :api
  # end
end
