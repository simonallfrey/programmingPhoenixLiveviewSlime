#---
# Excerpted from "Programming Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/liveview for more book information.
#---
defmodule PentoslimeWeb.PromoLive do
  use PentoslimeWeb, :live_view
  alias Pentoslime.Promo
  alias Pentoslime.Promo.Recipient

  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> assign_recipient()
      |> assign(:timestamp, DateTime.to_string(DateTime.utc_now))
      |> assign_changeset()}
  end

  def assign_recipient(socket) do
    socket
    |> assign(:recipient, %Recipient{})
  end

  def assign_changeset(%{assigns: %{recipient: recipient}} = socket) do
    socket
    |> assign(:changeset, Promo.change_recipient(recipient))
  end

  def handle_event(
      "validate",
      %{"recipient" => recipient_params},
      %{assigns: %{recipient: recipient}} = socket) do
    changeset =
      recipient
      |> Promo.change_recipient(recipient_params)
      |> Map.put(:action, :validate)

      {:noreply,
      socket
      |> assign(:timestamp, DateTime.to_string(DateTime.utc_now))
      |> assign(:changeset, changeset)}
  end

  def handle_event("save", %{"recipient" => recipient_params}, socket) do
    :timer.sleep(1000)
    case Promo.send_promo(socket.assigns.recipient, recipient_params) do
      {:ok, _recipient} ->
        {:noreply,
          socket
          |> put_flash(:info, "Sent promo!")
          |> assign_changeset()}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
        socket
        |> put_flash(:error, "Failed to send promo")
        |> assign(:changeset, changeset)}
    end
  end
end
