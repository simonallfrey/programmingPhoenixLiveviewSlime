defmodule PentoslimeWeb.SurveyLive do
  use PentoslimeWeb, :live_view
  alias Pentoslime.{Survey}
  alias PentoslimeWeb.DemographicLive
  alias __MODULE__.Component

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_demographic}
  end

  defp assign_demographic(%{assigns: %{current_user: current_user}} = socket) do
    assign(socket,
      :demographic,
      Survey.get_demographic_by_user(current_user))
  end
end
