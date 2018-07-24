defmodule DaeventboxWeb.RegistrationController do
  use DaeventboxWeb, :controller

  alias Daeventbox.Event
  alias Daeventbox.Registrationdetails
  alias Daeventbox.Registration

  def index(conn, _params) do
    render conn, "index.html"
  end


  def add_registration(conn, params) do
    params = Poison.decode!(params["registration_details_params"])
    IO.puts "registration details params"
    IO.inspect params
    total_items = String.to_integer(params["total_items"])-1
    for count <- 0..total_items do
      unless params["item#{count}"] == "" do
        registration_details = Repo.get!(Registrationdetails, String.to_integer(params["item#{count}"]))
        for i <- 1..String.to_integer(params["itemq#{count}"]) do
          person_details =
          [
            %{
              first_name: params["first_name#{registration_details.id}#{i} "],
              last_name: params["last_name#{registration_details.id}#{i}"],
              email: params["email#{registration_details.id}#{i}"],
              contact: params["contact#{registration_details.id}#{i}"]
            }

          ]
          required_params = %{persons_details: person_details, event_id: params["id"] , user_id: conn.assigns[:current_user].id , registrationdetails_id: registration_details.id }
          IO.puts "required params"
          IO.inspect required_params
          changeset = Registration.changeset(%Registration{}, required_params)
          case Repo.insert(changeset) do
            {:ok, ticket} -> IO.puts "Added Registration"
            {:error, changeset} -> IO.inspect changeset
          end

        end
      end
    end
    redirect conn, to: "/event/manage"

  end

end
