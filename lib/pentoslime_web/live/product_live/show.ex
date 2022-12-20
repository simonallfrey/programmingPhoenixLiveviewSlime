defmodule PentoslimeWeb.ProductLive.Show do
  use PentoslimeWeb, :live_view

  alias Pentoslime.Catalog

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket
     |> assign(:mount_time,currentTime())
    }
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:product, Catalog.get_product!(id))
     # |> IO.inspect
    }
  end

  defp page_title(:show), do: "Show Product"
  defp page_title(:edit), do: "Edit Product"
  defp currentTime() do
    # import DateTime
    # utc_now |> to_string
    DateTime.utc_now |> DateTime.to_string
  end
end
