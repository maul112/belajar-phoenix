defmodule UpaTikPortalWeb.Admin.KeluhanLive.Index do
  use UpaTikPortalWeb, :live_view

  alias UpaTikPortal.Keluhans

  def mount(_params, session, socket) do
    user = UpaTikPortal.Accounts.get_user!(session["user_id"])
    keluhans = Keluhans.list_keluhans()
    stats = Keluhans.stats()

    {:ok,
     assign(socket,
       page_title: "Keluhan – Admin UPA TIK",
       keluhans: keluhans,
       baru: Map.get(stats, "baru", 0),
       diproses: Map.get(stats, "diproses", 0),
       selesai: Map.get(stats, "selesai", 0),
       selected_id: nil,
       selected_keluhan: nil,
       admin_notes: "",
       current_user: user,
       new_message: ""
     )}
  end

  def handle_event("select", %{"id" => id}, socket) do
    if socket.assigns.selected_id do
      Phoenix.PubSub.unsubscribe(UpaTikPortal.PubSub, "keluhan_#{socket.assigns.selected_id}")
    end
    
    Keluhans.subscribe(id)
    keluhan = Keluhans.get_keluhan_with_messages!(id)

    {:noreply,
     assign(socket,
       selected_id: id,
       selected_keluhan: keluhan,
       admin_notes: keluhan.admin_notes || "",
       new_message: ""
     )}
  end

  def handle_event("close", _params, socket) do
    if socket.assigns.selected_id do
      Phoenix.PubSub.unsubscribe(UpaTikPortal.PubSub, "keluhan_#{socket.assigns.selected_id}")
    end
    {:noreply, assign(socket, selected_id: nil, selected_keluhan: nil, new_message: "")}
  end

  def handle_event("update_status", %{"status" => status}, socket) do
    keluhan = socket.assigns.selected_keluhan

    case Keluhans.update_keluhan_status(keluhan, %{
           "status" => status,
           "admin_notes" => socket.assigns.admin_notes
         }) do
      {:ok, _updated} ->
        keluhans = Keluhans.list_keluhans()
        stats = Keluhans.stats()

        {:noreply,
         socket
         |> assign(keluhans: keluhans)
         |> assign(baru: Map.get(stats, "baru", 0))
         |> assign(diproses: Map.get(stats, "diproses", 0))
         |> assign(selesai: Map.get(stats, "selesai", 0))
         |> assign(selected_id: nil, selected_keluhan: nil)
         |> put_flash(:info, "Status keluhan berhasil diperbarui.")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Gagal memperbarui status.")}
    end
  end

  def handle_event("update_notes", %{"admin_notes" => notes}, socket) do
    {:noreply, assign(socket, admin_notes: notes)}
  end

  def handle_event("update_message", %{"new_message" => msg}, socket) do
    {:noreply, assign(socket, new_message: msg)}
  end

  def handle_event("send_message", %{"new_message" => msg}, socket) do
    if String.trim(msg) != "" and socket.assigns.selected_keluhan do
      attrs = %{
        "content" => msg,
        "is_admin" => true,
        "keluhan_id" => socket.assigns.selected_id,
        "user_id" => socket.assigns.current_user.id
      }
      
      case Keluhans.create_message(attrs) do
        {:ok, _message} ->
          {:noreply, assign(socket, new_message: "")}
        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Gagal mengirim pesan")}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_info({:new_message, message}, socket) do
    if socket.assigns.selected_keluhan && socket.assigns.selected_id == message.keluhan_id do
      updated_keluhan = Map.update!(socket.assigns.selected_keluhan, :messages, fn msgs ->
        msgs ++ [message]
      end)
      {:noreply, assign(socket, selected_keluhan: updated_keluhan)}
    else
      {:noreply, socket}
    end
  end

  defp status_badge("baru"), do: {"bg-blue-100 text-blue-700 border border-blue-200", "🆕 Baru"}
  defp status_badge("diproses"), do: {"bg-amber-100 text-amber-700 border border-amber-200", "⏳ Diproses"}
  defp status_badge("selesai"), do: {"bg-green-100 text-green-700 border border-green-200", "✅ Selesai"}
  defp status_badge(_), do: {"bg-slate-100 text-slate-700", "Unknown"}
end
