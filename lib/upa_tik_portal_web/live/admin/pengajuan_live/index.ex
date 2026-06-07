defmodule UpaTikPortalWeb.Admin.PengajuanLive.Index do
  use UpaTikPortalWeb, :live_view

  alias UpaTikPortal.Requests

  def mount(_params, _session, socket) do
    requests = Requests.list_requests()

    {:ok,
     assign(socket,
       page_title: "Pengajuan – Admin UPA TIK",
       requests: requests,
       filter: "all",
       search: ""
     )}
  end

  def handle_event("filter", %{"status" => status}, socket) do
    {:noreply, assign(socket, filter: status)}
  end

  def handle_event("search", %{"q" => q}, socket) do
    {:noreply, assign(socket, search: String.downcase(q))}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    request = Requests.get_request!(id)

    case Requests.delete_request(request) do
      {:ok, _} ->
        requests = Requests.list_requests()

        {:noreply,
         socket
         |> assign(requests: requests)
         |> put_flash(:info, "Pengajuan berhasil dihapus.")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Gagal menghapus pengajuan.")}
    end
  end

  defp filtered_requests(requests, filter, search) do
    requests
    |> Enum.filter(fn r ->
      (filter == "all" || r.status == filter) &&
        (search == "" ||
           String.contains?(String.downcase(r.nim), search) ||
           String.contains?(String.downcase(r.full_name), search))
    end)
  end

  defp status_class("pending"), do: "bg-amber-100 text-amber-800"
  defp status_class("disetujui"), do: "bg-green-100 text-green-800"
  defp status_class("ditolak"), do: "bg-red-100 text-red-800"
  defp status_class(_), do: "bg-slate-100 text-slate-800"

  defp status_label("pending"), do: "Menunggu"
  defp status_label("disetujui"), do: "Disetujui"
  defp status_label("ditolak"), do: "Ditolak"
  defp status_label(s), do: s

  defp format_type("aktivasi"), do: "Aktivasi"
  defp format_type("reset"), do: "Reset"
  defp format_type(t), do: t
end
