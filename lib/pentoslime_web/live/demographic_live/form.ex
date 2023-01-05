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
      if demographic = Survey.get_demographic_by_user(current_user) do
        socket
        |> assign(:demographic, demographic)
        |> assign(:is_update, true)
        |> IO.inspect
      else
        socket
        |> assign(:demographic, %Demographic{user_id: current_user.id})
        |> IO.inspect
      end
   end

   defp assign_changeset(%{assigns: %{demographic: demographic}} = socket) do
     assign(socket, :changeset, Survey.change_demographic(demographic))
   end

   def handle_event("save", %{"demographic" => demographic_params},
     %{assigns: %{is_update: _, demographic: demographic}} = socket) do
     {:noreply, update_demographic(socket, demographic, demographic_params)}
   end

   def handle_event("save", %{"demographic" => demographic_params}, socket) do
     {:noreply, create_demographic(socket, demographic_params)}
   end

   def handle_event("validate", %{"demographic" => demographic_params}, socket) do
     {:noreply, validate_demographic(socket, demographic_params)}
   end

   defp update_demographic(socket, demographic, demographic_params) do
     case Survey.update_demographic(demographic,demographic_params) |> IO.inspect do
       {:ok, demographic} ->
         send(self(), {:updated_demographic, demographic})
         socket

       {:error, %Ecto.Changeset{} = changeset} ->
         assign(socket, changeset: changeset)
     end
   end

   defp create_demographic(socket, demographic_params) do
     case Survey.create_demographic(demographic_params) |> IO.inspect do
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
