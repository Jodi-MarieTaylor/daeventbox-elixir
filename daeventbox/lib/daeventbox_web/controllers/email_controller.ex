defmodule DaeventboxWeb.EmailController do
  use DaeventboxWeb, :controller
  import Ecto.Query


  def user_email(user) do
    #template = Data.Repo.get(Data.Content.Post, 4078)
    context =
      Map.new
      |> Map.put("user", user)
      |> Map.put("year", Timex.now.year)
      |> Map.put("month", Timex.now.month)
      |> Map.put("day", Timex.now.day)
    {:ok, template} =
      Render.get_template(:daeventbox, :templates, "welcome.html")

    email = Render.eex(template, data: context)

    Bamboo.Email.new_email
      |> Bamboo.Email.to(user.email)
      |> Bamboo.Email.from({"DaEventBox" , "admin@mg.romariofitzgerald.com"})
      |> Bamboo.Email.put_header("Reply-To", "sirromariofitz@gmail.com")
      |> Bamboo.Email.subject("Welcome To DaEventBox!")
      |> Bamboo.Email.html_body(email)
      |> Daeventbox.Mailer.deliver_later
  end

  def ticket_email(ticket, user) do
    #template = Data.Repo.get(Data.Content.Post, 4078)
    #event must be preloaded for ticket.event to be used in the email template
    event = Repo.get(Event, ticket.event_id)
    ticket_details = Repo.get_by(Ticketdetail, id: ticket.ticket_id)
    ticket =
      ticket
      |> Map.put(:event, event)

    context =
      Map.new
      |> Map.put("user", user)
      |> Map.put("ticket", ticket)
      |> Map.put("ticket_details", ticket_details)
      |> Map.put("year", Timex.now.year)
      |> Map.put("month", Timex.now.month)
      |> Map.put("day", Timex.now.day)

      {:ok, template} =
      Render.get_template(:daeventbox, :templates, "ticket.html")
      IO.inspect template
      email = Render.eex(template, data: context)


    Bamboo.Email.new_email
      |> Bamboo.Email.to(user.email)
      |> Bamboo.Email.from({"DaEventBox" , "admin@mg.romariofitzgerald.com"})
      |> Bamboo.Email.put_header("Reply-To", "sirromariofitz@gmail.com")
      |> Bamboo.Email.subject("Your Ticket to #{ticket.event.title}")
      |> Bamboo.Email.html_body(email)
      |> Daeventbox.Mailer.deliver_later
  end

  def generic_email(user, email) do
    #template = Data.Repo.get(Data.Content.Post, 4078)
    context =
      Map.new
      |> Map.put("user", user)
      |> Map.put("year", Timex.now.year)
      |> Map.put("month", Timex.now.month)
      |> Map.put("day", Timex.now.day)

    {:ok, template} =
      Render.get_template(:daeventbox, :templates, email["template"])

    email_body = Render.eex(template, data: context)

    Bamboo.Email.new_email
      |> Bamboo.Email.to(user.email)
      |> Bamboo.Email.from({"DaEventBox" , "admin@mg.romariofitzgerald.com"})
      |> Bamboo.Email.put_header("Reply-To", "sirromariofitz@gmail.com")
      |> Bamboo.Email.subject(email["title"])
      |> Bamboo.Email.html_body(email_body)
      |> Daeventbox.Mailer.deliver_later
  end

  def generic_admin_email(user, email) do
    #template = Data.Repo.get(Data.Content.Post, 4078)
    context =
      Map.new
      |> Map.put("user", user)
      |> Map.put("year", Timex.now.year)
      |> Map.put("month", Timex.now.month)
      |> Map.put("day", Timex.now.day)

    {:ok, template} =
      Render.get_template(:daeventbox, :templates, email["template"])

    email_body = Render.eex(template, data: context)

    Bamboo.Email.new_email
      |> Bamboo.Email.to(user.email)
      |> Bamboo.Email.from({"DaEventBox" , "admin@mg.romariofitzgerald.com"})
      |> Bamboo.Email.put_header("Reply-To", "sirromariofitz@gmail.com")
      |> Bamboo.Email.subject(email["title"])
      |> Bamboo.Email.html_body(email_body)
      |> Daeventbox.Mailer.deliver_later
  end

  def email_validation(recipients) do

    full_list = recipients |> String.split(",")
    recipients =
      full_list
      |> Enum.map(fn(x) -> Regex.run(~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/, x) end)
      |> Enum.filter(fn(x) -> x != nil  end)
      |> List.flatten

    bad_emails = full_list -- recipients

    [recipients, bad_emails]

  end


end
