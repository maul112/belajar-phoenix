defmodule UpaTikPortalWeb.Admin.KeluhanListLive do
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

  def render(assigns) do
    ~H"""
    <nav class="sticky top-4 z-50 bg-white/80 backdrop-blur-md shadow-sm border border-slate-200/60 transition-all mb-8 rounded-2xl mx-auto max-w-5xl px-4 sm:px-6">
      <div class="flex justify-between h-16">
        <div class="flex items-center gap-3">
          <div class="p-1 bg-white rounded-xl shadow-sm border border-slate-100 flex items-center justify-center">
            <img src={~p"/images/utm_logo.png"} class="h-8 w-auto hover:scale-105 transition-transform drop-shadow-sm" alt="UTM Logo">
          </div>
          <span class="text-slate-900 font-extrabold text-lg tracking-tight uppercase italic">Admin <span class="text-indigo-600">Console</span></span>
        </div>
        <div class="flex items-center space-x-1 sm:space-x-4">
          <a href="/admin" class="px-4 py-2 rounded-xl text-slate-500 hover:text-indigo-600 hover:bg-slate-50 font-bold text-sm transition-all">Overview</a>
          <a href="/admin/pengajuan" class="px-4 py-2 rounded-xl text-slate-500 hover:text-indigo-600 hover:bg-slate-50 font-bold text-sm transition-all">Pengajuan</a>
          <a href="/admin/keluhan" class="px-4 py-2 rounded-xl text-indigo-600 bg-indigo-50 font-bold text-sm transition-all">Keluhan</a>
          <a href="/admin/users" class="px-4 py-2 rounded-xl text-slate-500 hover:text-indigo-600 hover:bg-slate-50 font-bold text-sm transition-all text-xs uppercase">Users</a>
          <div class="w-px h-6 bg-slate-200 mx-1 hidden sm:block"></div>
          <a href="/auth/logout" class="p-2 text-slate-400 hover:text-rose-500 transition-colors">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/></svg>
          </a>
        </div>
      </div>
    </nav>

    <div class="space-y-8 max-w-5xl mx-auto pb-20">
      <div class="flex flex-col md:flex-row justify-between items-center bg-white p-8 rounded-[2rem] shadow-xl shadow-slate-200/50 border border-slate-100 gap-6">
        <div class="space-y-1">
          <h1 class="text-3xl font-black text-slate-900 tracking-tight uppercase italic">Pusat <span class="text-rose-500">Keluhan</span></h1>
          <p class="text-slate-400 font-bold text-xs uppercase tracking-[0.2em] italic">Laporan Mahasiswa Diterima</p>
        </div>
        <div class="flex items-center gap-3">
           <div class="px-6 py-3 bg-indigo-50 rounded-2xl border border-indigo-100/50 text-center">
             <p class="text-[9px] font-black text-indigo-400 uppercase tracking-widest">Baru</p>
             <p class="text-xl font-black text-indigo-600 tracking-tight"><%= @baru %></p>
           </div>
           <div class="px-6 py-3 bg-amber-50 rounded-2xl border border-amber-100/50 text-center">
             <p class="text-[9px] font-black text-amber-400 uppercase tracking-widest">Diproses</p>
             <p class="text-xl font-black text-amber-600 tracking-tight"><%= @diproses %></p>
           </div>
        </div>
      </div>

      <div class="bg-white rounded-[2.5rem] shadow-2xl shadow-slate-200/50 border border-slate-100 overflow-hidden group">
        <div class="overflow-x-auto">
          <table class="w-full text-left border-collapse">
            <thead class="bg-slate-50/50 border-b border-slate-100">
              <tr>
                <th class="px-10 py-6 text-[10px] font-black text-slate-400 uppercase tracking-[0.2em]">Data Pelapor</th>
                <th class="px-10 py-6 text-[10px] font-black text-slate-400 uppercase tracking-[0.2em]">Masalah Utama</th>
                <th class="px-10 py-6 text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] text-center">Status</th>
                <th class="px-10 py-6 text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] text-right px-10">Aksi</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-50">
              <%= for keluhan <- @keluhans do %>
                <% {badge_class, badge_text} = status_badge(keluhan.status) %>
                <tr class="hover:bg-slate-50/30 transition-all cursor-default">
                  <td class="px-10 py-8">
                    <div class="flex items-center gap-4">
                      <div class="w-12 h-12 bg-rose-50 rounded-2xl flex items-center justify-center text-rose-500 font-black text-xl italic border border-rose-100">
                        <%= String.at(keluhan.user.name, 0) %>
                      </div>
                      <div>
                        <p class="font-black text-slate-900 text-lg tracking-tight uppercase"><%= keluhan.user.name %></p>
                        <p class="text-[10px] text-slate-400 font-black uppercase tracking-widest bg-slate-50 px-2 py-0.5 rounded-md border border-slate-200/50 inline-block mt-1">
                          <%= Calendar.strftime(keluhan.inserted_at, "%d %b %Y") %>
                        </p>
                      </div>
                    </div>
                  </td>
                  <td class="px-10 py-8">
                    <div class="space-y-1">
                      <p class="text-lg font-black text-slate-800 tracking-tight uppercase italic"><%= keluhan.subject %></p>
                      <p class="text-xs text-slate-500 font-medium line-clamp-1 italic">"<%= keluhan.description %>"</p>
                    </div>
                  </td>
                  <td class="px-10 py-8 text-center">
                    <span class={["px-5 py-2 rounded-[0.8rem] text-[9px] font-black uppercase tracking-[0.15em] shadow-sm", badge_class]}>
                      <%= badge_text %>
                    </span>
                  </td>
                  <td class="px-10 py-8 text-right">
                    <button phx-click="select" phx-value-id={keluhan.id} class="p-3 bg-slate-900 text-white rounded-2xl hover:bg-rose-500 transition-all shadow-lg shadow-slate-200 hover:shadow-rose-100 group/btn flex items-center gap-2 ml-auto uppercase text-[10px] font-black tracking-widest">
                      <span>Tinjau</span>
                      <svg class="w-4 h-4 group-hover/btn:scale-125 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M14 5l7 7m0 0l-7 7m7-7H3"/></svg>
                    </button>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
          <%= if Enum.empty?(@keluhans) do %>
            <div class="p-32 text-center bg-slate-50/20">
              <div class="w-20 h-20 bg-slate-50 rounded-[2rem] flex items-center justify-center mx-auto mb-6 text-slate-200 border-2 border-dashed border-slate-100">
                <svg class="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"/></svg>
              </div>
              <p class="text-[10px] font-black text-slate-300 uppercase tracking-[0.4em] italic">Antrean keluhan kosong</p>
            </div>
          <% end %>
        </div>
      </div>
    </div>

    <%= if @selected_keluhan do %>
      <div class="fixed inset-0 bg-slate-900/40 backdrop-blur-md z-[100] flex items-center justify-center p-4 animate-in fade-in duration-300">
        <div class="bg-white rounded-[3rem] shadow-2xl w-full max-w-2xl overflow-hidden border border-slate-100 animate-in zoom-in-95 duration-300">
          <div class="px-10 py-8 bg-slate-900 flex justify-between items-center text-white relative">
            <div class="absolute right-20 top-0 w-24 h-24 bg-white/5 rounded-full translate-x-12 -translate-y-12"></div>
            <div>
              <h3 class="text-xl font-black uppercase italic tracking-tight">Detail <span class="text-indigo-400">Kasus</span></h3>
              <p class="text-white/40 text-[10px] font-black uppercase tracking-widest mt-1">ID Keluhan: #<%= @selected_keluhan.id %></p>
            </div>
            <button phx-click="close" class="bg-white/10 hover:bg-rose-500 hover:rotate-90 p-2.5 rounded-2xl transition-all duration-300 group/close shadow-xl">
              <svg class="w-6 h-6 group-hover/close:scale-110 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M6 18L18 6M6 6l12 12"/></svg>
            </button>
          </div>

          <div class="p-10 space-y-8 max-h-[75vh] overflow-y-auto custom-scrollbar">
            <div class="grid grid-cols-2 gap-8">
              <div class="space-y-1 bg-slate-50 p-6 rounded-3xl border border-slate-100">
                <p class="text-[9px] font-black text-slate-400 uppercase tracking-[.2em] mb-1">Entitas Pelapor</p>
                <p class="font-black text-slate-900 uppercase italic"><%= @selected_keluhan.user.name %></p>
                <p class="text-xs font-bold text-indigo-600 font-mono tracking-tight"><%= @selected_keluhan.user.email %></p>
              </div>
              <div class="space-y-1 bg-slate-50 p-6 rounded-3xl border border-slate-100">
                <p class="text-[9px] font-black text-slate-400 uppercase tracking-[.2em] mb-1">Subjek Masalah</p>
                <p class="font-black text-slate-900 uppercase italic"><%= @selected_keluhan.subject %></p>
              </div>
            </div>

            <div class="bg-slate-50 p-8 rounded-[2rem] border-2 border-dashed border-slate-200 relative group/msg">
              <div class="absolute -left-2 top-8 w-1 h-12 bg-rose-500 rounded-full transition-all group-hover/msg:h-20"></div>
              <p class="text-[9px] font-black text-slate-400 uppercase tracking-[0.2em] mb-4">Kronologi Kendala</p>
              <p class="text-slate-800 font-bold leading-relaxed italic">"<%= @selected_keluhan.description %>"</p>
            </div>

            <div class="bg-slate-50 p-6 rounded-[2rem] border border-slate-200">
              <h4 class="text-[9px] font-black text-slate-400 uppercase tracking-[0.2em] mb-4">Riwayat Percakapan</h4>
              <div class="space-y-4 max-h-[300px] overflow-y-auto custom-scrollbar pr-2 mb-4">
                <%= if Enum.empty?(@selected_keluhan.messages) do %>
                  <div class="text-center text-slate-400 text-xs italic py-4">Belum ada percakapan.</div>
                <% else %>
                  <%= for msg <- @selected_keluhan.messages do %>
                    <div class={["flex", if(msg.is_admin, do: "justify-end", else: "justify-start")]}>
                      <div class={["max-w-[80%] rounded-2xl p-4 shadow-sm", if(msg.is_admin, do: "bg-indigo-600 text-white rounded-tr-sm", else: "bg-white border border-slate-200 text-slate-800 rounded-tl-sm")]}>
                        <p class="text-xs mb-1 opacity-70 font-bold"><%= if msg.is_admin, do: "Admin", else: msg.user.name %></p>
                        <p class="text-sm font-medium whitespace-pre-wrap"><%= msg.content %></p>
                        <p class="text-[9px] text-right mt-2 opacity-50"><%= Calendar.strftime(msg.inserted_at, "%d %b %Y %H:%M") %></p>
                      </div>
                    </div>
                  <% end %>
                <% end %>
              </div>
              
              <form phx-submit="send_message" class="flex gap-2">
                <input type="text" name="new_message" value={@new_message} phx-change="update_message" placeholder="Ketik balasan..." autocomplete="off"
                       class="flex-1 px-6 py-3 bg-white border border-slate-200 rounded-xl text-sm font-bold focus:ring-4 focus:ring-indigo-50 focus:border-indigo-500 outline-none transition-all shadow-inner" />
                <button type="submit" class="px-6 py-3 bg-indigo-600 text-white rounded-xl font-black uppercase tracking-widest text-[10px] hover:bg-indigo-700 transition-all shadow-md">Kirim</button>
              </form>
            </div>

            <form phx-submit="update_status" class="space-y-4">
              <h4 class="text-[9px] font-black text-slate-400 uppercase tracking-[0.2em] block ml-1 mb-2">Update Status Laporan</h4>
              <div class="flex flex-wrap gap-3">
                <button type="button" phx-click="update_status" phx-value-status="baru" class="flex-1 py-4 px-4 rounded-2xl text-[10px] font-black uppercase tracking-widest bg-slate-100 text-slate-400 hover:bg-slate-900 hover:text-white transition-all border border-slate-200">🆕 Baru</button>
                <button type="button" phx-click="update_status" phx-value-status="diproses" class="flex-1 py-4 px-4 rounded-2xl text-[10px] font-black uppercase tracking-widest bg-amber-50 text-amber-600 hover:bg-amber-600 hover:text-white transition-all border border-amber-100 shadow-lg shadow-amber-50">⏳ Proses</button>
                <button type="button" phx-click="update_status" phx-value-status="selesai" class="flex-1 py-4 px-4 rounded-2xl text-[10px] font-black uppercase tracking-widest bg-emerald-50 text-emerald-600 hover:bg-emerald-600 hover:text-white transition-all border border-emerald-100 shadow-lg shadow-emerald-50">✅ Selesai</button>
              </div>
            </form>
          </div>
        </div>
      </div>
    <% end %>
    """
  end
end
