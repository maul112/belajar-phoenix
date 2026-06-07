defmodule UpaTikPortalWeb.Home.Keluhan.Index do
  use UpaTikPortalWeb, :live_view

  alias UpaTikPortal.Keluhans

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    user = UpaTikPortal.Accounts.get_user!(user_id)
    keluhans = Keluhans.list_keluhans_by_user(user_id)

    if connected?(socket) do
      for keluhan <- keluhans do
        Keluhans.subscribe(keluhan.id)
      end
    end

    socket =
      socket
      |> assign(page_title: "Pengajuan Bermasalah – UPA TIK Portal")
      |> assign(current_user: user)
      |> assign(keluhans: keluhans)
      |> assign(subject: "")
      |> assign(description: "")
      |> assign(errors: %{})
      |> assign(submitted: false)
      |> assign(new_messages: %{})

    {:ok, socket}
  end

  def handle_event("update_field", params, socket) do
    field_name = List.first(params["_target"])
    value = params[field_name]

    if field_name do
      {:noreply, assign(socket, String.to_existing_atom(field_name), value)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("submit", _params, socket) do
    user = socket.assigns.current_user

    attrs = %{
      "subject" => socket.assigns.subject,
      "description" => socket.assigns.description
    }

    case Keluhans.create_keluhan(user.id, attrs) do
      {:ok, _keluhan} ->
        keluhans = Keluhans.list_keluhans_by_user(user.id)

        {:noreply,
         socket
         |> assign(submitted: true, subject: "", description: "", errors: %{})
         |> assign(keluhans: keluhans)
         |> put_flash(:info, "Keluhan berhasil dikirim!")}

      {:error, changeset} ->
        errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
        {:noreply, assign(socket, errors: errors)}
    end
  end

  def handle_event("new_keluhan", _params, socket) do
    {:noreply, assign(socket, submitted: false)}
  end

  def handle_event("update_message", %{"_target" => ["message_" <> keluhan_id]} = params, socket) do
    msg = params["message_" <> keluhan_id]
    {:noreply, assign(socket, new_messages: Map.put(socket.assigns.new_messages, keluhan_id, msg))}
  end
  def handle_event("update_message", _, socket), do: {:noreply, socket}

  def handle_event("send_message", %{"keluhan_id" => keluhan_id} = params, socket) do
    msg = params["message_" <> keluhan_id]
    if msg && String.trim(msg) != "" do
      attrs = %{
        "content" => msg,
        "is_admin" => false,
        "keluhan_id" => keluhan_id,
        "user_id" => socket.assigns.current_user.id
      }

      case Keluhans.create_message(attrs) do
        {:ok, _message} ->
          {:noreply, assign(socket, new_messages: Map.put(socket.assigns.new_messages, keluhan_id, ""))}
        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Gagal mengirim pesan")}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_info({:new_message, message}, socket) do
    keluhans = Enum.map(socket.assigns.keluhans, fn k ->
      if k.id == message.keluhan_id do
        Map.update!(k, :messages, fn msgs -> msgs ++ [message] end)
      else
        k
      end
    end)
    {:noreply, assign(socket, keluhans: keluhans)}
  end

  defp status_badge("baru"), do: {"bg-indigo-50 text-indigo-600 border border-indigo-100", "🆕 Baru"}
  defp status_badge("diproses"), do: {"bg-amber-50 text-amber-600 border border-amber-100", "⏳ Diproses"}
  defp status_badge("selesai"), do: {"bg-emerald-50 text-emerald-600 border border-emerald-100", "✅ Selesai"}
  defp status_badge(_), do: {"bg-slate-100 text-slate-700 border border-slate-100", "Unknown"}
end
