defmodule PentoslimeWeb.Toystruct2 do
  defstruct name: "a toy"
end

defmodule PentoslimeWeb.ToyformLive do
  use PentoslimeWeb, :live_view2
  # :live_view2 to use ~H heex rather than sheex
  alias PentoslimeWeb.Toystruct2

  def mount(_params, session, socket) do
    #create a changeset backed by a struct (rather than schema)
    # https://hexdocs.pm/ecto/Ecto.Changeset.html
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
    # metadata named as lowercase of struct of changeset of form.
    # The struct is PentoslimeWeb.Toystruct2
    # so the name of the metadata is "toystruct2"
    # %{"_target" => ["toystruct2", "name"], "toystruct2" => %{"name" => "Simo"}}
    {:noreply, socket}
  end

  def handle_event("save", metadata, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "METADATA was #{inspect(metadata)}")
    }
  end


 end
