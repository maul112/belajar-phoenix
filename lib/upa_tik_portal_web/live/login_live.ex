defmodule UpaTikPortalWeb.LoginLive do
  use UpaTikPortalWeb, :live_view

  def mount(_params, session, socket) do
    current_user = get_user_from_session(session)

    if current_user do
      {:ok, push_navigate(socket, to: redirect_path(current_user))}
    else
      {:ok, assign(socket, :page_title, "Login - UPA TIK Portal")}
    end
  end

  defp get_user_from_session(%{"user_id" => id}) when not is_nil(id) do
    UpaTikPortal.Accounts.get_user(id)
  end

  defp get_user_from_session(_), do: nil

  defp redirect_path(%{role: "admin"}), do: ~p"/admin"
  defp redirect_path(%{role: "mentor"}), do: ~p"/mentor"
  defp redirect_path(_), do: ~p"/portal"

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-slate-50 flex flex-col justify-center items-center py-12 px-4 relative overflow-hidden">
      <%!-- Subtle aesthetic background decoration --%>
      <div class="absolute inset-0 z-0 overflow-hidden pointer-events-none w-full h-full flex justify-center items-center">
        <div class="absolute w-[800px] h-[800px] rounded-full bg-indigo-100/40 blur-[120px] mix-blend-multiply opacity-70 animate-pulse transition-all duration-1000"></div>
        <div class="absolute translate-x-1/2 translate-y-1/4 w-[600px] h-[600px] rounded-full bg-blue-50/60 blur-[100px] mix-blend-multiply opacity-50"></div>
      </div>

      <div class="relative z-10 w-full max-w-md">
        <div class="bg-white p-10 sm:p-14 shadow-2xl shadow-indigo-100/40 rounded-[2.5rem] border border-slate-100 backdrop-blur-sm group">

          <%!-- Logo & Header --%>
          <div class="text-center mb-10">
            <div class="inline-flex items-center justify-center p-4 bg-white rounded-[1.5rem] mb-6 shadow-xl shadow-slate-100 border border-slate-50 group-hover:scale-110 transition-transform duration-500">
              <img class="h-16 w-auto object-contain drop-shadow-sm" src={~p"/images/utm_logo.png"} alt="UTM Logo">
            </div>
            <h2 class="text-3xl font-black text-slate-900 tracking-tight uppercase italic">
              UPA TIK <span class="text-indigo-600">Portal</span>
            </h2>
            <p class="mt-3 text-[11px] text-slate-400 font-bold uppercase tracking-[0.2em] leading-relaxed">
              Sistem Informasi Manajemen Terpadu<br/>Universitas Trunojoyo Madura
            </p>
          </div>

          <div class="w-full h-px bg-slate-100 mb-10"></div>

          <%!-- Action section --%>
          <div class="space-y-6">
            <div class="text-center">
               <h3 class="text-xs font-black text-slate-900 uppercase tracking-widest">Akses Masuk Panel</h3>
               <p class="text-[10px] uppercase font-bold tracking-[0.1em] text-slate-400 mt-1">Gunakan akun Google universitas Anda</p>
            </div>

            <div>
              <a href="/auth/google" class="w-full flex justify-center items-center py-4 px-6 border-2 border-slate-100 rounded-2xl text-sm font-black text-slate-700 bg-white hover:bg-slate-50 hover:border-indigo-100 hover:text-indigo-600 hover:shadow-lg hover:shadow-indigo-50 transform hover:-translate-y-1 transition-all duration-300 focus:outline-none focus:ring-4 focus:ring-indigo-50 group gap-3 uppercase tracking-widest">
                <svg class="h-5 w-5 transition-transform group-hover:scale-125 duration-300" viewBox="0 0 24 24">
                  <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                  <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                  <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                  <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
                </svg>
                <span>Masuk Sistem</span>
              </a>
            </div>

            <div class="mt-8 flex justify-center text-center">
               <div class="inline-flex items-center text-[10px] font-black uppercase tracking-widest text-slate-400 bg-slate-50 px-4 py-2 rounded-xl border border-slate-100">
                  <svg class="w-4 h-4 mr-2 text-indigo-400" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z" clip-rule="evenodd"></path></svg>
                  Hanya Akun Resmi UTM
               </div>
            </div>
          </div>
        </div>

        <%!-- Footer --%>
        <div class="mt-8 text-center px-4">
          <p class="text-[10px] text-slate-400 font-bold uppercase tracking-[0.2em] leading-relaxed">
            © 2026 Universitas Trunojoyo Madura<br/>
            <span class="text-slate-300">Unit Pelaksana Akademik TIK</span>
          </p>
        </div>
      </div>

    </div>
    """
  end
end
