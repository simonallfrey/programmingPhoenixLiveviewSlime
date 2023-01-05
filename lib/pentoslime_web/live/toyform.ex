defmodule PentoslimeWeb.Toystruct2 do
  defstruct name: "a toy"
end

defmodule PentoslimeWeb.ToyformLive do
  # use Phoenix.LiveView, layout: {PentoslimeWeb.LayoutView, "live.html"}
  use PentoslimeWeb, :live_view2
  # :live_view2 to use heex rather than sheex
  # import Ecto.Changeset
  alias PentoslimeWeb.Toystruct2

  def mount(_params, session, socket) do
    toystruct = %Toystruct2{}
    types = %{name: :string}
    params = %{"name" => "Simon"}
    changeset =
      {toystruct,types}
      |> Ecto.Changeset.cast(params,Map.keys(types))
      |> IO.inspect
    {
     :ok,
     socket
     |> assign(changeset: changeset)
    }
  end

  def render(assigns) do
    ~H"""
    <div>
    <.form
    let={f}
    for={@changeset}
    phx-change="validate"
    phx-submit="save"
    id="toyform">

    <%= label f, :name %>
    <%= text_input f, :name %>
    <%= error_tag f, :name %>

    <%= submit "Save", phx_disable_with: "Saving..." %>
    </.form>
    </div>
    """
  end

  def handle_event("validate", metadata, socket) do
    metadata |> IO.inspect
    {:noreply, socket}
  end

  def handle_event("save", metadata, socket) do
    {:noreply,
     socket
     # |> put_flash(:info, "METADATA was #{metadata}")
     |> assign(:oldmetadata, metadata |> IO.inspect)
    }
  end


 end
