defmodule PentoslimeWeb.WrongLive do
  # use Phoenix.LiveView, layout: {PentoWeb.LayoutView, "live.html"}
  use PentoslimeWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, score: 0, message: "Hi! Make a guess:", target: :rand.uniform(10))}
  end

  def render(assigns) do
    ~H"""
    h1 Your score: #{@score}
    h2 #{@message}
    h2
     = for n <- 1..10 do
       a href="#" phx-click="guess" phx-value-guess="#{n}" phx-value-target="#{@target}" #{n}&nbsp
    """
    # a href="#" phx-click="guess" phx-value-guess={n} #{n}
  end

  def handle_event("guess", %{"guess" => guess, "target" => guess}, socket) do
    {:noreply, assign(socket,
      message: "Your guess: #{guess}. Correct. Guess again. ",
      score: socket.assigns.score + 1)}
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
