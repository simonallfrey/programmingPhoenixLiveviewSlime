defmodule PentoslimeWeb.WrongLive2 do
  # use Phoenix.LiveView, layout: {PentoslimeWeb.LayoutView, "live.html"}
  use PentoslimeWeb, :live_view
  alias Pentoslime.Accounts

  def mount(_params, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])
    {
     :ok,
     assign(
       socket,
       score: 0,
       wins: 0,
       message: "Hi! VERSION2 Make a guess:",
       target: :rand.uniform(10),
       session_id: session["live_socket_id"],
       current_user: user
     )
    }
  end

  def render(assigns) do
    Phoenix.View.render(PentoslimeWeb.DemoView, "demo.html", assigns)
  end

  # def render(assigns) do
  #   # https://github.com/slime-lang/slime
  #   ~H"""
  #   h1 Your score: #{@score}
  #   h2 #{@message}
  #   h2
  #    = for n <- 1..10 do
  #      a href="#" phx-click="guess" phx-value-guess="#{n}" phx-value-target="#{@target}" #{n}&nbsp
  #   pre #{@current_user.email}
  #       #{@session_id}
  #   """
  #   # a href="#" phx-click="guess" phx-value-guess={n} #{n}
  # end

  def handle_event("guess", %{"guess" => guess, "target" => guess}, socket) do
    {:noreply, assign(socket,
      message: "Your guess: #{guess}. Correct. Guess again. ",
      score: socket.assigns.score + 1,
      wins: socket.assigns.wins + 1)}
  end
  def handle_event("guess", %{"guess" => guess}, socket) do
    {:noreply, assign(socket,
      message: "Your guess: #{guess}. Incorrect. Guess again. ",
      score: socket.assigns.score - 1)}
  end

  # def handle_event("guess", %{"guess" => guess}, socket) do
  #   {m,s} =
  #   if guess == Integer.to_string(socket.assigns.target) do
  #     {, socket.assigns.score + 1}
  #   else
  #     {"Your guess: #{guess}. Incorrect. Guess again. ", }
  #   end
  #   {:noreply,
  #     assign(
  #       socket,
  #       message: m,
  #       score: s)}
  # end

  end
