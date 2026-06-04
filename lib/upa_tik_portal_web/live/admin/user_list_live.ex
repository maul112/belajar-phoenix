defmodule UpaTikPortalWeb.Admin.UserListLive do
  use UpaTikPortalWeb, :live_view

  alias UpaTikPortal.Accounts

  def mount(_params, _session, socket) do
    users = Accounts.list_users()
    {:ok, assign(socket, users: users, page_title: "Daftar Pengguna – UPA TIK Admin")}
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
          <a href="/admin/pengajuan" class="px-4 py-2 rounded-xl text-slate-500 hover:text-indigo-600 hover:bg-slate-50 font-bold text-sm transition-all">Pengajuan</a>
          <a href="/admin/keluhan" class="px-4 py-2 rounded-xl text-slate-500 hover:text-indigo-600 hover:bg-slate-50 font-bold text-sm transition-all">Keluhan</a>
          <a href="/admin/users" class="px-4 py-2 rounded-xl text-indigo-600 bg-indigo-50 font-bold text-sm transition-all text-xs uppercase">Users</a>
          <div class="w-px h-6 bg-slate-200 mx-1 hidden sm:block"></div>
          <a href="/auth/logout" class="p-2 text-slate-400 hover:text-rose-500 transition-colors">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/></svg>
          </a>
        </div>
      </div>
    </nav>

    <div class="space-y-8 max-w-7xl mx-auto pb-20">
      <div class="flex flex-col md:flex-row justify-between items-center bg-white p-8 rounded-[2rem] shadow-xl shadow-slate-200/50 border border-slate-100 gap-6">
        <div class="space-y-1 text-center md:text-left">
          <h1 class="text-3xl font-black text-slate-900 tracking-tight uppercase italic">Basis <span class="text-indigo-600">Pengguna</span></h1>
          <p class="text-slate-400 font-bold text-xs uppercase tracking-[0.2em] italic">Otoritas Dan Akses Sistem</p>
        </div>
        <div class="flex items-center gap-4">
           <div class="px-8 py-3 bg-indigo-600 text-white rounded-2xl shadow-lg shadow-indigo-100/50 flex flex-col items-center">
             <span class="text-[9px] font-black uppercase tracking-widest text-indigo-100/60 mb-0.5">Total Terdaftar</span>
             <span class="text-xl font-black tracking-tighter"><%= length(@users) %> User</span>
           </div>
        </div>
      </div>

      <div class="bg-white rounded-[2.5rem] shadow-2xl shadow-slate-200/50 border border-slate-100 overflow-hidden group">
        <div class="overflow-x-auto">
          <table class="w-full text-left border-collapse">
            <thead class="bg-slate-50/50 border-b border-slate-100">
              <tr>
                <th class="px-10 py-6 text-[10px] font-black text-slate-400 uppercase tracking-[0.2em]">Identitas Pengguna</th>
                <th class="px-10 py-6 text-[10px] font-black text-slate-400 uppercase tracking-[0.2em]">Kredensial Email</th>
                <th class="px-10 py-6 text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] text-center">Hak Akses</th>
                <th class="px-10 py-6 text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] text-right">Aktivitas</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-50">
              <%= for user <- @users do %>
                <tr class="hover:bg-slate-50/30 transition-all cursor-default">
                  <td class="px-10 py-8">
                    <div class="flex items-center gap-4">
                      <div class="w-12 h-12 bg-slate-900 text-white rounded-2xl flex items-center justify-center font-black text-xl italic border shadow-lg shadow-slate-200 group-hover:bg-indigo-600 transition-colors">
                        <%= String.at(user.name, 0) %>
                      </div>
                      <div>
                        <p class="font-black text-slate-900 text-lg tracking-tight uppercase italic transition-colors group-hover:text-indigo-600"><%= user.name %></p>
                        <p class="text-[10px] text-slate-400 font-black uppercase tracking-widest mt-0.5">ID: #<%= user.id %></p>
                      </div>
                    </div>
                  </td>
                  <td class="px-10 py-8">
                    <div class="flex flex-col">
                      <span class="text-sm font-bold text-slate-600 font-mono tracking-tight bg-slate-50 px-3 py-1 rounded-lg border border-slate-100 inline-block">
                        <%= user.email %>
                      </span>
                    </div>
                  </td>
                  <td class="px-10 py-8 text-center">
                    <span class={["px-5 py-2 rounded-xl text-[9px] font-black uppercase tracking-[0.2em] shadow-sm", role_class(user.role)]}>
                      <%= user.role %>
                    </span>
                  </td>
                  <td class="px-10 py-8 text-right">
                    <div class="flex flex-col items-end">
                      <p class="text-[9px] font-black text-slate-300 uppercase tracking-widest">Update Terakhir</p>
                      <p class="text-xs font-bold text-slate-500"><%= Calendar.strftime(user.updated_at, "%d %b %Y") %></p>
                    </div>
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

  defp role_class("admin"), do: "bg-slate-900 text-white border border-slate-800"
  defp role_class(_), do: "bg-indigo-50 text-indigo-600 border border-indigo-100"
end
