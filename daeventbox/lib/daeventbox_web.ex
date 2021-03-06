defmodule DaeventboxWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use DaeventboxWeb, :controller
      use DaeventboxWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def model do
    quote do
      use Ecto.Schema
      use Calecto.Schema, usec: true

      # ...
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, namespace: DaeventboxWeb
      import Plug.Conn
      import DaeventboxWeb.Router.Helpers
      import DaeventboxWeb.Gettext

      alias Daeventbox.{Repo, User, Facilitator, Ticketdetail, Registrationdetails, Ticket}
      alias Daeventbox.{Registration, SavedEvent, LikedEvent, Ad, Option, Action, Event}
      alias DaEventBox.{Follower, Comment, Chat, Chat.Message, Chat.Room, Notification}
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/daeventbox_web/templates",
                        namespace: DaeventboxWeb

      # Import convenience functions from controllers
      # import Phoenix.Controller, only: [get_flash: 2, view_module: 1]
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]


      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import DaeventboxWeb.Router.Helpers
      import DaeventboxWeb.ErrorHelpers
      import DaeventboxWeb.Gettext
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import DaeventboxWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
