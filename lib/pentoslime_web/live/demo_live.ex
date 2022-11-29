defmodule PentoslimeWeb.DemoLive do
  use PentoslimeWeb, :live_view

  # alias PhoenixSlimeTest.Accounts.User

  @gods ~w(Achelous Aeolus Aether Alastor Apollo Ares Aristaeus Asclepius Atlas Attis Boreas Caerus Castor Cerus Chaos Charon Cronos Crios Cronus Dinlas Deimos Dionysus Erebus Eros Eurus Glaucus Hades Helios Hephaestus Heracles Hermes Hesperus Hymenaios Hypnos Kratos Momus Morpheus Nereus Notus Oceanus Oneiroi Paean Pallas Pan Phosphorus Plutus Pollux Pontus Poseidon Priapus Pricus Prometheus Tartarus Thanatos Triton Typhon Uranus Zelus Zephyrus Zeus)

  def render(assigns) do
    Phoenix.View.render(PentoslimeWeb.DemoView, "demo.html", assigns)
  end

  def mount(_params, _session, socket) do
    start_timer()

    # changeset =  User.changeset(%User{name: "Gnusto"}, %{})

    socket = assign(socket, %{
      name: "Jonathan",
      # changeset: changeset,
      module: PentoslimeWeb.DemoLiveComponent
      })
    {:ok, socket}
  end

  def handle_info(:update_time, socket) do
    {:noreply, update(socket, :name, fn _ -> Enum.random(@gods) end)}
  end

  defp start_timer() do
    :timer.send_interval(666, self(), :update_time)
  end
end
