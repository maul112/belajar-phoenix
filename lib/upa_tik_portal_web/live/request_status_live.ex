defmodule UpaTikPortalWeb.RequestStatusLive do
  use UpaTikPortalWeb, :live_view

  alias UpaTikPortal.Requests
  alias UpaTikPortal.Keluhans

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    user = UpaTikPortal.Accounts.get_user!(user_id)
    requests = Requests.list_requests_by_user(user_id)
    keluhans = Keluhans.list_keluhans_by_user(user_id)

    {:ok,
     assign(socket,
       page_title: "Status Pengajuan – UPA TIK Portal",
       current_user: user,
       requests: requests,
       keluhans: keluhans,
       keluhan_subject: "",
       keluhan_description: "",
       keluhan_errors: %{},
       keluhan_submitted: false
     )}
  end



  def render(assigns) do
    ~H"""
    <nav class="sticky top-4 z-50 bg-white/80 backdrop-blur-md shadow-sm border border-slate-200/60 transition-all mb-8 rounded-2xl mx-auto max-w-5xl px-4 sm:px-6">
      <div class="flex justify-between h-16">
        <div class="flex items-center gap-3">
          <div class="p-1 bg-white rounded-xl shadow-sm border border-slate-100 flex items-center justify-center">
            <img src={~p"/images/utm_logo.png"} class="h-8 w-auto hover:scale-105 transition-transform drop-shadow-sm" alt="UTM Logo">
          </div>
          <span class="text-slate-900 font-extrabold text-lg tracking-tight">UPA TIK <span class="text-indigo-600">Portal</span></span>
        </div>
        <div class="flex items-center space-x-1 sm:space-x-4">
          <a href="/portal/ajukan" class="px-4 py-2 rounded-xl text-slate-500 hover:text-indigo-600 hover:bg-slate-50 font-bold text-sm transition-all">Pengajuan</a>
          <a href="/portal/status" class="px-4 py-2 rounded-xl text-indigo-600 bg-indigo-50 font-bold text-sm transition-all">Status</a>
          <a href="/portal/keluhan" class="px-4 py-2 rounded-xl text-slate-500 hover:text-indigo-600 hover:bg-slate-50 font-bold text-sm transition-all">Lapor</a>
          <div class="w-px h-6 bg-slate-200 mx-2 hidden sm:block"></div>
          <a href="/auth/logout" class="p-2 text-slate-400 hover:text-rose-500 transition-colors">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/></svg>
          </a>
        </div>
      </div>
    </nav>

    <div class="max-w-4xl mx-auto space-y-16 pb-20">
      <div class="flex flex-col md:flex-row justify-between items-center bg-white p-10 rounded-[2.5rem] shadow-2xl shadow-slate-200/50 border border-slate-100 gap-6">
        <div class="text-center md:text-left">
          <h1 class="text-3xl font-black text-slate-900 tracking-tight uppercase italic">Monitor <span class="text-indigo-600">Layanan</span></h1>
          <p class="text-slate-500 mt-2 font-medium">Memantau riwayat pengajuan akun untuk <span class="text-indigo-600 font-bold text-lg"><%= @current_user.name %></span></p>
        </div>
        <a href="/portal/ajukan" class="px-10 py-4 bg-indigo-600 text-white rounded-[2rem] font-bold hover:bg-indigo-700 transition-all shadow-lg shadow-indigo-100 flex items-center gap-2 group">
          <svg class="w-5 h-5 group-hover:rotate-12 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 4v16m8-8H4"/></svg>
          <span>Buat Baru</span>
        </a>
      </div>

      <section class="space-y-8">
        <div class="flex items-center gap-4">
          <div class="h-8 w-2 bg-indigo-600 rounded-full"></div>
          <h2 class="text-2xl font-black text-slate-900 tracking-tight uppercase">Riwayat Aktivasi & Reset</h2>
        </div>
        
        <%= if Enum.empty?(@requests) do %>
          <div class="bg-white rounded-[2.5rem] p-20 text-center border-2 border-dashed border-slate-100 shadow-inner">
            <div class="w-20 h-20 bg-slate-50 text-slate-300 rounded-full flex items-center justify-center mx-auto mb-6">
              <svg class="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/></svg>
            </div>
            <p class="text-slate-400 font-bold uppercase tracking-[0.2em] text-sm">Belum ada pengajuan</p>
          </div>
        <% else %>
          <div class="grid grid-cols-1 gap-6">
            <%= for request <- @requests do %>
              <div class="group bg-white rounded-[2.5rem] border border-slate-100 shadow-xl shadow-slate-200/40 p-10 hover:shadow-indigo-100 transition-all relative overflow-hidden">
                <div class="absolute top-0 right-0 w-32 h-32 bg-indigo-50/50 rounded-bl-[100%] translate-x-16 -translate-y-16 group-hover:scale-150 transition-transform duration-700"></div>
                
                <div class="flex flex-col md:flex-row justify-between gap-8 relative z-10">
                  <div class="space-y-5 flex-1">
                    <div class="flex flex-wrap items-center gap-3">
                      <span class={"px-4 py-1.5 rounded-xl text-[10px] font-black uppercase tracking-widest shadow-sm #{status_class(request.status)}"}>
                        <%= status_label(request.status) %>
                      </span>
                      <span class="text-[10px] font-black text-indigo-600 uppercase tracking-widest bg-indigo-50 px-4 py-1.5 rounded-xl">
                        <%= format_type(request.request_type) %>
                      </span>
                    </div>

                    <div class="space-y-1">
                      <h3 class="text-2xl font-black text-slate-900 tracking-tight"><%= request.full_name %></h3>
                      <p class="text-indigo-600 font-bold font-mono text-sm tracking-tight bg-slate-50 inline-block px-3 py-1 rounded-lg border border-slate-100"><%= request.email_requested %></p>
                    </div>
                    
                    <%= if request.status == "disetujui" && request.otp_code do %>
                      <div class="mt-6 p-6 bg-indigo-50 border border-indigo-100 rounded-3xl shadow-inner relative overflow-hidden">
                        <div class="absolute -right-4 -bottom-4 text-indigo-100 opacity-30 rotate-12">
                          <svg class="w-32 h-32" fill="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/></svg>
                        </div>
                        <p class="text-[10px] text-indigo-600 font-black uppercase tracking-[0.2em] mb-2">Pemberitahuan</p>
                        <p class="text-lg font-black text-slate-900 tracking-tight">Kredensial Terkirim!</p>
                        <p class="text-[10px] text-slate-400 mt-2 font-bold uppercase italic">*Silakan cek kotak masuk Gmail Anda untuk melihat kode akses.</p>
                      </div>
                    <% end %>

                    <%= if request.admin_notes do %>
                      <div class="mt-6 p-6 bg-slate-50 rounded-3xl border border-slate-100 relative">
                        <div class="absolute -left-2 top-6 w-1 h-8 bg-amber-400 rounded-full"></div>
                        <p class="text-[10px] text-slate-400 font-black uppercase tracking-[0.2em] mb-2">Catatan dari Admin</p>
                        <p class="text-slate-700 font-medium leading-relaxed italic">"<%= request.admin_notes %>"</p>
                      </div>
                    <% end %>
                  </div>

                  <div class="md:text-right flex md:flex-col justify-between items-center md:items-end">
                    <div class="space-y-1">
                      <p class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Waktu Pengajuan</p>
                      <p class="text-sm font-bold text-slate-900"><%= Calendar.strftime(request.inserted_at, "%d %b %Y") %></p>
                      <p class="text-[10px] text-slate-400 font-medium"><%= Calendar.strftime(request.inserted_at, "%H:%M WIB") %></p>
                    </div>
                    <div class="md:mt-auto hidden group-hover:block animate-in fade-in slide-in-from-right-2">
                       <div class="w-12 h-12 bg-slate-50 rounded-2xl flex items-center justify-center text-slate-200">
                          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 5l7 7-7 7"/></svg>
                       </div>
                    </div>
                  </div>
                </div>
              </div>
            <% end %>
          </div>
        <% end %>
      </section>

      <div class="h-px bg-slate-100"></div>

      <section class="space-y-8">
        <div class="flex items-center gap-4">
          <div class="h-8 w-2 bg-rose-500 rounded-full"></div>
          <h2 class="text-2xl font-black text-slate-900 tracking-tight uppercase italic">Status <span class="text-rose-500">Keluhan</span></h2>
        </div>
        
        <div class="grid grid-cols-1 lg:grid-cols-12 gap-10">
          <div class="lg:col-span-12">
            <div class="bg-white p-10 rounded-[2.5rem] shadow-2xl shadow-slate-200/50 border border-slate-100">
              <div class="flex flex-col gap-6">
                <div class="flex items-center justify-between">
                  <h3 class="text-xl font-black text-slate-900 tracking-tight uppercase italic">Riwayat <span class="text-rose-500">Laporan</span></h3>
                  <span class="text-[10px] font-black text-slate-400 uppercase tracking-widest"><%= Enum.count(@keluhans) %> Laporan</span>
                </div>
                
                <div class="space-y-4 overflow-y-auto max-h-[500px] pr-2 custom-scrollbar">
                  <%= if Enum.empty?(@keluhans) do %>
                    <div class="p-16 text-center bg-slate-50 rounded-3xl border-2 border-dashed border-slate-100">
                      <p class="text-slate-300 font-black uppercase tracking-[0.2em] text-[10px]">Belum ada data keluhan</p>
                    </div>
                  <% else %>
                    <%= for keluhan <- @keluhans do %>
                      <% {badge_class, badge_text} = keluhan_badge(keluhan.status) %>
                      <div class="group bg-white p-6 rounded-3xl border border-slate-100 shadow-sm hover:shadow-md transition-all relative overflow-hidden flex flex-col md:flex-row justify-between md:items-center gap-4">
                        <div class="flex-1">
                          <h4 class="font-black text-slate-900 text-lg tracking-tight group-hover:text-rose-500 transition-colors uppercase"><%= keluhan.subject %></h4>
                          <p class="text-slate-500 text-sm mt-2 font-medium leading-relaxed"><%= keluhan.description %></p>
                        </div>
                        <div class="flex flex-col items-start md:items-end gap-2">
                          <span class={"text-[9px] font-black px-4 py-1.5 rounded-xl uppercase tracking-widest shadow-sm #{badge_class}"}>
                            <%= badge_text %>
                          </span>
                          <span class="text-[10px] font-bold text-slate-400 bg-slate-50 px-3 py-1 rounded-lg border border-slate-100"><%= Calendar.strftime(keluhan.inserted_at, "%d %b %Y") %></span>
                          <a href="/portal/keluhan" class="text-[9px] font-black text-rose-500 hover:text-rose-600 uppercase tracking-widest mt-2 underline transition-all">Lihat Chat Detail ➝</a>
                        </div>
                      </div>
                    <% end %>
                  <% end %>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>
    """
  end

  defp status_class("pending"), do: "bg-amber-50 text-amber-600 border border-amber-100"
  defp status_class("disetujui"), do: "bg-emerald-50 text-emerald-600 border border-emerald-100"
  defp status_class("ditolak"), do: "bg-rose-50 text-rose-600 border border-rose-100"
  defp status_class(_), do: "bg-slate-50 text-slate-400 border border-slate-100"

  defp status_label("pending"), do: "⏳ Menunggu"
  defp status_label("disetujui"), do: "✅ Disetujui"
  defp status_label("ditolak"), do: "❌ Ditolak"
  defp status_label(s), do: s

  defp format_type("aktivasi"), do: "Aktivasi Akun"
  defp format_type("reset"), do: "Reset Password"
  defp format_type(t), do: t

  defp keluhan_badge("baru"), do: {"bg-indigo-50 text-indigo-600 border border-indigo-100", "🆕 Baru"}
  defp keluhan_badge("diproses"), do: {"bg-amber-50 text-amber-600 border border-amber-100", "⏳ Diproses"}
  defp keluhan_badge("selesai"), do: {"bg-emerald-50 text-emerald-600 border border-emerald-100", "✅ Selesai"}
  defp keluhan_badge(_), do: {"bg-slate-100 text-slate-700", "?"}
end
