defmodule DaeventboxWeb.HelpController do
  use DaeventboxWeb, :controller
  import Ecto.Query
  alias Daeventbox.Faq

  alias Daeventbox.ContactRequest
  def index(conn, _params) do
      faqs = Repo.all(from f in Faq)
      render conn, "faqs.html", faqs: faqs

  end

  def contact(conn, params) do
    required_params = %{email: params["email"], title: params["title"], name: params["name"], message: params["message"], status: "New"  }
    contact_requests_changeset = ContactRequest.changeset(%ContactRequest{}, required_params)
      case Repo.insert(contact_requests_changeset) do
        {:ok, contact_requests} -> IO.puts "Added Contact Request"
        {:error, changeset} -> IO.inspect changeset
      end
    faqs = Repo.all(from f in Faq)
    render conn, "faqs.html", faqs: faqs
  end



end
