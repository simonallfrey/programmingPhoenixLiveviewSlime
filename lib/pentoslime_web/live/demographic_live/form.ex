defmodule PentoslimeWeb.DemographicLive.Form do
   use PentoslimeWeb, :live_component
   alias Pentoslime.Survey
   alias Pentoslime.Survey.Demographic

   def update(assigns, socket) do
     {
       :ok,
        socket
        |> assign(assigns)
        |> assign_demographic()
        |> assign_changeset()
      }
   end

   defp assign_demographic(
      %{assigns: %{current_user: current_user}} = socket) do
     assign(socket, :demographic, %Demographic{user_id: current_user.id})
   end

   defp assign_changeset(%{assigns: %{demographic: demographic}} = socket) do
     assign(socket, :changeset, Survey.change_demographic(demographic))
   end

   def handle_event("save", %{"demographic" => demographic_params}, socket) do
     {:noreply, save_demographic(socket, demographic_params)}
   end

   def handle_event("validate", %{"demographic" => demographic_params}, socket) do
     {:noreply, validate_demographic(socket, demographic_params)}
   end

   defp save_demographic(socket, demographic_params) do
     case Survey.create_demographic(demographic_params) do
       {:ok, demographic} ->
         send(self(), {:created_demographic, demographic})
         socket

       {:error, %Ecto.Changeset{} = changeset} ->
         assign(socket, changeset: changeset)
     end
   end

   defp validate_demographic(socket, demographic_params) do
     changeset =
       socket.assigns.demographic
       |> Survey.change_demographic(demographic_params)
       |> Map.put(:action, :validate)

     assign(socket, :changeset, changeset)
   end


 end
