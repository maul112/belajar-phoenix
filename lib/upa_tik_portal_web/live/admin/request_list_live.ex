defmodule UpaTikPortalWeb.Admin.RequestListLive do
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

  def render(assigns) do
    ~H"""
    <nav class="sticky top-4 z-50 bg-white/80 backdrop-blur-md shadow-sm border border-slate-200/60 transition-all mb-8 rounded-2xl mx-auto max-w-7xl px-4 sm:px-6">
      <div class="flex justify-between h-16">
        <div class="flex items-center gap-3">
          <div class="p-1 bg-white rounded-xl shadow-sm border border-slate-100 flex items-center justify-center">
            <img src={~p"/images/utm_logo.png"} class="h-8 w-auto hover:scale-105 transition-transform drop-shadow-sm" alt="UTM Logo">
          </div>
          <span class="text-slate-900 font-extrabold text-lg tracking-tight uppercase italic">Admin <span class="text-indigo-600">Console</span></span>
        </div>
        <div class="flex items-center space-x-1 sm:space-x-4">
          <a href="/admin" class="px-4 py-2 rounded-xl text-slate-500 hover:text-indigo-600 hover:bg-slate-50 font-bold text-sm transition-all">Overview</a>
          <a href="/admin/pengajuan" class="px-4 py-2 rounded-xl text-indigo-600 bg-indigo-50 font-bold text-sm transition-all">Pengajuan</a>
          <a href="/admin/keluhan" class="px-4 py-2 rounded-xl text-slate-500 hover:text-indigo-600 hover:bg-slate-50 font-bold text-sm transition-all">Keluhan</a>
          <a href="/admin/users" class="px-4 py-2 rounded-xl text-slate-500 hover:text-indigo-600 hover:bg-slate-50 font-bold text-sm transition-all text-xs uppercase">Users</a>
          <div class="w-px h-6 bg-slate-200 mx-1 hidden sm:block"></div>
          <a href="/auth/logout" class="p-2 text-slate-400 hover:text-rose-500 transition-colors">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/></svg>
          </a>
        </div>
      </div>
    </nav>

    <div class="space-y-8 max-w-7xl mx-auto pb-20">
      <div class="flex flex-col md:flex-row justify-between items-center bg-white p-8 rounded-[2rem] shadow-xl shadow-slate-200/50 border border-slate-100 gap-6">
        <div class="space-y-1">
          <h1 class="text-3xl font-black text-slate-900 tracking-tight uppercase italic">Permohonan <span class="text-indigo-600">Aktivasi</span></h1>
          <p class="text-slate-400 font-bold text-xs uppercase tracking-[0.2em] italic"><%= Enum.count(@requests) %> Entri Pengguna Ditemukan</p>
        </div>

        <div class="flex flex-col sm:flex-row items-center gap-4 w-full md:w-auto">
          <form phx-change="search" class="relative w-full sm:w-64">
            <input type="text" name="q" value={@search} placeholder="Cari Mahasiswa/NIM..."
              class="w-full pl-12 pr-6 py-4 bg-slate-50 border border-slate-100 rounded-2xl text-sm font-bold focus:ring-4 focus:ring-indigo-50 focus:border-indigo-500 outline-none transition-all placeholder:text-slate-300"/>
            <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none text-slate-300">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>
            </div>
          </form>

          <div class="flex bg-slate-50 p-2 rounded-2xl border border-slate-100 gap-1 w-full sm:w-auto">
             <%= for {label, val} <- [{"Semua", "all"}, {"Pending", "pending"}] do %>
               <button phx-click="filter" phx-value-status={val}
                 class={["px-6 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all", if(@filter == val, do: "bg-white text-indigo-600 shadow-lg shadow-indigo-100", else: "text-slate-400 hover:text-slate-600")]}>
                 <%= label %>
               </button>
             <% end %>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-[2.5rem] shadow-2xl shadow-slate-200/50 border border-slate-100 overflow-hidden group">
        <div class="overflow-x-auto">
          <table class="w-full text-left border-collapse">
            <thead class="bg-slate-50/50 border-b border-slate-100">
              <tr>
                <th class="px-10 py-6 text-[10px] font-black text-slate-400 uppercase tracking-[0.2em]">Data Pengguna</th>
                <th class="px-10 py-6 text-[10px] font-black text-slate-400 uppercase tracking-[0.2em]">Permintaan Akun</th>
                <th class="px-10 py-6 text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] text-center">Tipe</th>
                <th class="px-10 py-6 text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] text-center">Status</th>
                <th class="px-10 py-6 text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] text-right px-10">Aksi</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-50">
              <%= for request <- filtered_requests(@requests, @filter, @search) do %>
                <tr class="hover:bg-slate-50/30 transition-all cursor-default">
                  <td class="px-10 py-8">
                    <div class="flex items-center gap-4">
                      <div class="w-12 h-12 bg-indigo-50 rounded-2xl flex items-center justify-center text-indigo-600 font-black text-xl italic border border-indigo-100">
                        <%= String.at(request.full_name, 0) %>
                      </div>
                      <div>
                        <p class="font-black text-slate-900 text-lg tracking-tight uppercase"><%= request.full_name %></p>
                        <p class="text-xs text-indigo-600 font-mono font-bold tracking-tight bg-indigo-50/50 px-2 py-0.5 rounded-md border border-indigo-100/50 inline-block mt-1"><%= request.nim %></p>
                      </div>
                    </div>
                  </td>
                  <td class="px-10 py-8">
                    <div class="space-y-1">
                      <p class="text-sm font-bold text-slate-600 font-mono tracking-tight"><%= request.email_requested %></p>
                      <p class="text-[9px] font-black text-slate-300 uppercase tracking-[0.1em]">Waktu: <%= Calendar.strftime(request.inserted_at, "%d/%m/%y %H:%M") %></p>
                    </div>
                  </td>
                  <td class="px-10 py-8 text-center">
                    <span class="text-[9px] font-black px-4 py-1.5 bg-slate-50 text-slate-400 rounded-xl border border-slate-100 uppercase tracking-widest group-hover:bg-white transition-colors">
                      <%= format_type(request.request_type) %>
                    </span>
                  </td>
                  <td class="px-10 py-8 text-center">
                    <span class={["px-5 py-2 rounded-[0.8rem] text-[9px] font-black uppercase tracking-[0.15em] shadow-sm", status_class(request.status)]}>
                      <%= status_label(request.status) %>
                    </span>
                  </td>
                  <td class="px-10 py-8 text-right">
                    <div class="flex justify-end gap-3">
                      <.link navigate={~p"/admin/pengajuan/#{request.id}"} class="p-3 bg-slate-900 text-white rounded-2xl hover:bg-indigo-600 transition-all shadow-lg shadow-slate-200 hover:shadow-indigo-100 group/btn">
                        <svg class="w-5 h-5 group-hover/btn:scale-125 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M14 5l7 7m0 0l-7 7m7-7H3"/></svg>
                      </.link>
                      <button phx-click="delete" phx-value-id={request.id} data-confirm="Hapus data pengajuan ini secara permanen?" class="p-3 bg-rose-50 text-rose-500 rounded-2xl hover:bg-rose-500 hover:text-white transition-all hover:shadow-lg hover:shadow-rose-100 group/del">
                        <svg class="w-5 h-5 group-hover/del:rotate-12 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
                      </button>
                    </div>
                  </td>
                </tr>
              <% end %>
              <%= if Enum.empty?(filtered_requests(@requests, @filter, @search)) do %>
                <tr>
                  <td colspan="5" class="px-10 py-32 text-center bg-slate-50/20">
                    <div class="w-20 h-20 bg-slate-50 rounded-[2rem] flex items-center justify-center mx-auto mb-6 text-slate-200 border-2 border-dashed border-slate-100">
                      <svg class="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>
                    </div>
                    <p class="text-[10px] font-black text-slate-300 uppercase tracking-[0.4em] italic">Data tidak ditemukan</p>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
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
