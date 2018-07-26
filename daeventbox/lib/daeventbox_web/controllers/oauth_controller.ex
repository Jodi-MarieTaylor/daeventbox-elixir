defmodule DaeventboxWeb.OAuthController do
  use DaeventboxWeb, :controller
  import Plug.Conn
  import Ecto.Query
  require Logger
  require Poison
  plug Ueberauth
  alias Ueberauth.Strategy.Helpers
  use OAuth2.Strategy

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  def delete_target(conn, params) do
    id = params["target"]
    post = Daeventbox.Repo.get!(Daeventbox.Account.Target, id)
    Daeventbox.Repo.delete(post)
    conn |> redirect(to: "/posts")
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, params) do
    IO.puts "FAIL BIG TIME"
    IO.inspect conn.assigns
    IO.inspect params
    IO.inspect conn

    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/posts")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
    IO.inspect auth
    IO.inspect params
    current_user = conn.assigns[:current_user]
    auth = auth |> Map.put(:params, params)
    case find_or_create(auth) do
      {:ok, user} ->
          facebook_handler(auth, user, current_user, conn)
      {:error, reason} ->
          IO.inspect reason
          {:error, reason}
    end
  end

  def find_or_create(%{provider: :identity} = auth) do
        {:ok, basic_info(auth)}
  end

  def find_or_create(%{} = auth) do
    {:ok, basic_info(auth)}
  end

  # github does it this way
  defp avatar_from_auth( %{info: %{urls: %{avatar_url: image}} }), do: image

  #facebook does it this way
  defp avatar_from_auth( %{info: %{image: image} }), do: image

  # default case if nothing matches
  defp avatar_from_auth( auth ) do
    Logger.warn auth.provider <> " needs to find an avatar URL!"
    Logger.debug(Poison.encode!(auth))
    nil
  end

  defp basic_info(auth) do
    %{id: auth.uid, name: name_from_auth(auth), avatar: avatar_from_auth(auth)}
  end

  defp name_from_auth(auth) do
    if auth.info.name do
      auth.info.name
    else
      name = [auth.info.first_name, auth.info.last_name]
      |> Enum.filter(&(&1 != nil and &1 != ""))

      cond do
        length(name) == 0 -> auth.info.nickname
        true -> Enum.join(name, " ")
      end
    end
  end

  def facebook_handler(auth, user, user_id, conn) do
    env = Application.get_env(:ueberauth, Ueberauth.Strategy.Facebook.OAuth)
    app_id = env |> Keyword.get(:client_id)
    app_secret = env |> Keyword.get(:client_secret)
    access_token = auth.credentials.token
    {:ok, resp} = HTTPoison.get("https://graph.facebook.com/oauth/access_token?grant_type=fb_exchange_token&client_id=#{app_id}&client_secret=#{app_secret}&fb_exchange_token=#{access_token}")

    resp = resp.body |> Poison.decode! |> Map.take(["access_token", "expires_at", "expires_in"])

    user =
      user
      |> Map.put(:access_token, resp["access_token"])
      |> Map.put(:code, auth.params["code"])
      |> Map.put(:email, auth.extra.raw_info.user["email"])
      |> Map.put(:profile_pic_url, user.avatar)
      |> Map.put(:firstname, Enum.at(String.split(user.name), 0))
      |> Map.put(:lastname, Enum.at(String.split(user.name), 1))
      |> Map.put(:password, UUID.uuid4)
      |> Map.put(:zid, UUID.uuid4)
      |> Map.put(:fb_id, user.id)
      |> Fitz.Map.atom_keys_to_string
      |> Map.drop(["id", "avatar", "provider"])

    user_res =
        case Repo.get_by(User, fb_id: user["fb_id"]) do
          nil ->
            User.create(user)
          existing_user ->
            User.update(existing_user, user)
        end

    case user_res do
      {:ok, user} ->
        time_in_secs_from_now = 86400 * 90
        conn
        |> delete_resp_cookie("daeventboxuser")
        |> delete_resp_cookie("daeventboxuser")
        |> put_resp_cookie("daeventboxuser", user.zid, max_age: time_in_secs_from_now)
        |> put_resp_cookie("daeventboxmode", "Guest", max_age: time_in_secs_from_now)
        |> Daeventbox.Auth.login(user)
        |> put_flash(:info, "Successfully Logged In")
        |> redirect(to: "/")
      {:error, reason} ->
        IO.inspect reason
        conn
        |> put_flash(:error, "Failed To Log In")
        |> redirect(to: "/login")
    end
  end

  def client do
    OAuth2.Client.new([
      strategy: __MODULE__,
      client_id: "be0ac59d0ddc4f329f9da4c500416578",
      client_secret: "21e26f0406774f228e076d781e99e5f9",
      redirect_uri: "https://4cc5e2b9.ngrok.io/auth/instagram/callback",
      site: "https://https://www.instagram.com",
      authorize_url: "https://www.instagram.com/oauth/authorize",
      token_url: "https://www.instagram.com/oauth/access_token"
    ])
  end

  def authorize_url! do
    OAuth2.Client.authorize_url!(client())
  end

  # you can pass options to the underlying http library via `opts` parameter
  def get_token!(params \\ [], headers \\ [], opts \\ []) do
    OAuth2.Client.get_token!(client(), params, headers, opts)
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_param(:client_secret, client.client_secret)
    |> put_header("accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end

end
