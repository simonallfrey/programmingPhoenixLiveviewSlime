defmodule PentoslimeWeb.ProductLive.FormComponent do
  use PentoslimeWeb, :live_component

  alias Pentoslime.Catalog

  @impl true
  def update(%{product: product} = assigns, socket) do
    changeset = Catalog.change_product(product)
    Process.sleep(250)
    {:ok, socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
      |> allow_upload(:image,
        accept: ~w(.jpg .jpeg .png),
        max_entries: 1,
        max_file_size: 9_000_000,
        auto_upload: true,
        progress: &handle_progress/3)
    }
  end

  @impl true
  def handle_event("validate", %{"product" => product_params}, socket) do
    changeset =
      socket.assigns.product
      |> Catalog.change_product(product_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"product" => product_params}, socket) do
    save_product(socket, socket.assigns.action, product_params)
  end

  defp handle_progress(:image, entry, socket) do
    :timer.sleep(2000)
    if entry.done? do
      # {:ok, path} =
      path =
        consume_uploaded_entry(
          socket,
          entry,
          &upload_static_file(&1, socket)
        )
      # dbg(path)
      {:noreply,
       socket
       |> put_flash(:info, "file #{entry.client_name} uploaded")
       |> assign(:image_upload, path)
       |> IO.inspect
      }
    else
      {:noreply, socket}
    end
  end

  defp save_product(socket, :edit, params) do
    case Catalog.update_product(socket.assigns.product, product_params(socket, params)) do
      {:ok, _product} ->
        {:noreply,
         socket
         |> put_flash(:info, "Product updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_product(socket, :new, params) do
    case Catalog.create_product(product_params(socket, params)) do
      {:ok, _product} ->
        {:noreply,
         socket
         |> put_flash(:info, "Product created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp upload_static_file(%{path: path}, socket) do
    # Plug in your production image file persistence implementation here!
    # this returns the priv directory independent of build mode
    dest = :code.priv_dir(:pentoslime)
     |> Path.join("static/images")
     |> Path.join(Path.basename(path))
     # |> IO.inspect
    # this will work only in dev mode.
    # dest = Path.join("priv/static/images", Path.basename(path))
    File.cp!(path, dest)
    # dbg(path)
    # dbg(dest)
    # dbg(Routes.static_path(socket, "/images/#{Path.basename(dest)}"))
    {:ok, Routes.static_path(socket, "/images/#{Path.basename(dest)}")}
  end


  def upload_image_error(%{image: %{errors: errors}}, entry) when length(errors) > 0 do
    {_, msg} =
      Enum.find(errors, fn {ref, _} ->
        ref == entry.ref || ref == entry.upload_ref
      end)

    upload_error_msg(msg)
  end

  def upload_image_error(_, _), do: ""

  defp upload_error_msg(:not_accepted) do
    "Invalid file type"
  end

  defp upload_error_msg(:too_many_files) do
    "Too many files"
  end

  defp upload_error_msg(:too_large) do
    "File exceeds max size"
  end

  def product_params(%{assigns: %{image_upload: path}}=_socket, params) do
    # if we have an :image_upload in socket copy it to params
    # Map.put(params, "image_upload", socket.assigns.image_upload)
    Map.put(params, "image_upload", path)
  end
  def product_params(_socket, params) do
    # no image_upload in socket
    params
  end
end
