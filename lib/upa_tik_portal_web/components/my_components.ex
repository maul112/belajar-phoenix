defmodule UpaTikPortalWeb.Components.MyComponents do
  use Phoenix.Component
  use Phoenix.VerifiedRoutes,
    endpoint: UpaTikPortalWeb.Endpoint,
    router: UpaTikPortalWeb.Router
  alias Phoenix.LiveView.JS
  import UpaTikPortalWeb.CoreComponents

  attr :active_tab, :atom, default: :home
  attr :current_user, :any, default: nil
  slot :inner_block, required: true

  def navbarDynamic(assigns) do
    ~H"""
    <%= cond do %>
      <% @current_user && @current_user.role == "admin" -> %>
        <.navbarAdmin active_tab={@active_tab} current_user={@current_user}>
          <%= render_slot(@inner_block) %>
        </.navbarAdmin>
      <% @current_user && @current_user.role == "mentor" -> %>
        <.navbarMentor active_tab={@active_tab} current_user={@current_user}>
          <%= render_slot(@inner_block) %>
        </.navbarMentor>
      <% true -> %>
        <.navbar active_tab={@active_tab} current_user={@current_user}>
          <%= render_slot(@inner_block) %>
        </.navbar>
    <% end %>
    """
  end

  def navbar(assigns) do
    ~H"""
      <nav class="border-b border-slate-200 bg-white dark:bg-slate-900 shadow-sm sticky top-0 z-40">
        <div class="max-w-7xl mx-auto px-4 h-16 flex items-center justify-between">
          <div class="flex items-center gap-3">
            <button type="button" class="p-2 -ml-2 md:hidden hover:bg-slate-100 rounded-lg" phx-click={show_mobile_sidebar()}>
              <.icon name="hero-bars-3" class="w-6 h-6" />
            </button>
            <.link navigate={~p"/portal/"} class="flex items-center gap-2 group">
              <div class="w-8 h-8 rounded-lg flex items-center justify-center transition-transform group-hover:scale-110">
                <img src="/images/utm_logo.png" class="h-8 w-auto hover:scale-105 transition-transform drop-shadow-sm" alt="UTM Logo">
              </div>
              <span class="font-bold">UPA TIK Portal</span>
            </.link>
          </div>
          <div class="flex items-center gap-6">
            <div class="hidden md:flex items-center gap-2 border-r border-slate-200 pr-6">
              <.nav_link navigate={~p"/portal/"} active={@active_tab == :home}>Beranda</.nav_link>
              <.nav_link navigate={~p"/portal/lowongan"} active={@active_tab == :lowongan}>Lowongan</.nav_link>
              <.nav_link navigate={~p"/portal/magang"} active={@active_tab == :magang}>Magang Saya</.nav_link>
              <.nav_link navigate={~p"/portal/ajukan"} active={@active_tab == :ajukan}>Pengajuan</.nav_link>
              <.nav_link navigate={~p"/portal/status"} active={@active_tab == :status}>Status</.nav_link>
              <.nav_link navigate={~p"/portal/keluhan"} active={@active_tab == :keluhan}>Lapor Masalah</.nav_link>
            </div>
            <div class="relative">
              <button type="button" class="group cursor-pointer flex items-center gap-2 p-1 rounded-full hover:bg-slate-100 transition-colors" id="user-menu-button" phx-click={JS.toggle(to: "#profile-dropdown", in: {"ease-out duration-100", "opacity-0 scale-95", "opacity-100 scale-100"}, out: {"ease-in duration-75", "opacity-100 scale-100", "opacity-0 scale-95"})} phx-click-away={JS.hide(to: "#profile-dropdown")}>
                <div class="w-8 h-8 rounded-full bg-gradient-to-tr from-blue-500 to-indigo-600 flex items-center justify-center text-white text-xs font-bold shadow-sm transition-transform group-hover:scale-105">
                  <%= if @current_user do %><%= String.at(@current_user.name, 0) %><% else %>G<% end %>
                </div>
                <.icon name="hero-chevron-down" class="w-4 h-4 transition-colors group-hover:text-blue-600" />
              </button>
              <div id="profile-dropdown" class="hidden absolute right-0 mt-2 w-48 bg-white rounded-xl shadow-lg z-50 overflow-hidden">
                <div class="px-4 py-3 border-b border-slate-100 bg-slate-50/50">
                  <p class="text-xs text-slate-500">Masuk sebagai</p>
                  <p class="text-sm font-semibold text-slate-900 truncate">
                    <%= @current_user && @current_user.name %>
                  </p>
                </div>
                <div class="py-1">
                  <.link navigate={~p"/portal/profile"} class="flex items-center gap-2 px-4 py-2 text-sm text-slate-700 hover:bg-slate-50 transition-colors"><.icon name="hero-user" class="w-4 h-4" /> Profil Saya</.link>
                  <.link navigate={~p"/portal/setting"} class="flex items-center gap-2 px-4 py-2 text-sm text-slate-700 hover:bg-slate-50 transition-colors"><.icon name="hero-cog-6-tooth" class="w-4 h-4" /> Pengaturan</.link>
                  <.link navigate={~p"/portal/keluhan"} class="flex items-center gap-2 px-4 py-2 text-sm text-slate-700 hover:bg-slate-50 transition-colors"><.icon name="hero-chat-bubble-left-right" class="w-4 h-4" /> Lapor Masalah</.link>
                </div>
                <div class="py-1 border-t border-slate-100 bg-red-50/20">
                  <.link href={~p"/auth/logout"} class="flex items-center gap-2 px-4 py-2 text-sm text-red-600 hover:bg-red-50 transition-colors font-medium"><.icon name="hero-arrow-right-on-rectangle" class="w-4 h-4" /> Keluar</.link>
                </div>
              </div>
            </div>
          </div>
        </div>
      </nav>

      <.mobile_sidebar active_tab={@active_tab} />

      <main class="w-full mx-auto flex-grow">
        <%= render_slot(@inner_block) %>
      </main>

      <.footer />
    """
  end

  attr :active_tab, :atom, default: :home
  defp mobile_sidebar(assigns) do
    ~H"""
      <div id="mobile-sidebar-container" class="relative z-50 md:hidden hidden" role="dialog" aria-modal="true">
        <div id="mobile-sidebar-backdrop" class="fixed inset-0 bg-slate-900/50 backdrop-blur-sm" phx-click={hide_mobile_sidebar()}></div>
        <div id="mobile-sidebar-panel" class="fixed inset-y-0 left-0 w-full max-w-xs bg-white shadow-xl flex flex-col overflow-y-auto">
          <div class="p-6 border-b border-slate-100 flex items-center justify-between">
            <div class="flex items-center gap-2">
              <div class="w-7 h-7 rounded-lg flex items-center justify-center">
                <img src="/images/utm_logo.png" class="h-8 w-auto hover:scale-105 transition-transform drop-shadow-sm" alt="UTM Logo">
              </div>
              <span class="font-bold text-slate-900">Menu Portal</span>
            </div>
            <button type="button" phx-click={hide_mobile_sidebar()} class="p-2 text-slate-400 hover:text-slate-500"><.icon name="hero-x-mark" class="w-6 h-6" /></button>
          </div>
          <nav class="flex-1 px-4 py-6 space-y-2">
            <.mobile_nav_link navigate={~p"/portal/"} active={@active_tab == :home} icon="hero-home">Beranda</.mobile_nav_link>
            <.mobile_nav_link navigate={~p"/portal/lowongan"} active={@active_tab == :lowongan} icon="hero-briefcase">Lowongan</.mobile_nav_link>
            <.mobile_nav_link navigate={~p"/portal/magang"} active={@active_tab == :magang} icon="hero-academic-cap">Magang Saya</.mobile_nav_link>
            <.mobile_nav_link navigate={~p"/portal/ajukan"} active={@active_tab == :ajukan} icon="hero-document-plus">Pengajuan</.mobile_nav_link>
            <.mobile_nav_link navigate={~p"/portal/status"} active={@active_tab == :status} icon="hero-clock">Status</.mobile_nav_link>
            <hr class="border-slate-100 my-4" />
            <.mobile_nav_link navigate={~p"/portal/keluhan"} active={@active_tab == :keluhan} icon="hero-chat-bubble-left-right">Lapor Masalah</.mobile_nav_link>
          </nav>
          <div class="p-4 border-t border-slate-100">
            <.link href={~p"/auth/logout"} method="delete" class="flex items-center gap-3 w-full px-4 py-3 text-sm font-medium text-red-600 hover:bg-red-50 rounded-xl transition-colors"><.icon name="hero-arrow-right-on-rectangle" class="w-5 h-5" /> Keluar</.link>
          </div>
        </div>
      </div>
    """
  end

  attr :navigate, :any, required: true
  attr :active, :boolean, default: false
  attr :icon, :string
  slot :inner_block, required: true

  defp mobile_nav_link(assigns) do
    ~H"""
    <.link navigate={@navigate} class={["flex items-center gap-3 px-4 py-3 text-sm font-medium rounded-xl transition-all", @active && "bg-blue-600 text-white shadow-md shadow-blue-200 dark:shadow-none", !@active && "text-slate-600 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-slate-800"]}>
      <.icon name={@icon} class={["w-5 h-5", @active && "text-white", !@active && "text-slate-400 dark:text-slate-500"]} />
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  attr :active_tab, :atom, default: :dashboard
  attr :current_user, :any, default: nil
  slot :inner_block, required: false

  def navbarAdmin(assigns) do
    ~H"""
      <div class="flex h-screen bg-slate-50 dark:bg-slate-950 overflow-hidden">
        <!-- Desktop Sidebar -->
        <aside class="hidden md:flex flex-col w-64 bg-white dark:bg-slate-900 shadow-xl overflow-y-auto border-r border-slate-200 dark:border-slate-800">
          <div class="p-4 flex items-center gap-3 border-b border-slate-200 dark:border-slate-800 sticky top-0 bg-white dark:bg-slate-900 z-10">
            <div class="w-9 h-9 rounded-xl flex items-center justify-center shadow-sm bg-slate-50 dark:bg-slate-950 border border-slate-100 dark:border-slate-800">
              <img src="/images/utm_logo.png" class="h-8 w-auto hover:scale-105 transition-transform" alt="UTM Logo">
            </div>
            <div>
              <p class="font-bold text-sm text-slate-900 dark:text-white">UPA TIK Admin</p>
              <p class="text-xs text-slate-500 dark:text-slate-400">Panel Manajemen</p>
            </div>
          </div>

          <nav class="flex-1 px-4 py-6 space-y-1">
            <p class="px-2 text-xs font-semibold text-slate-500 uppercase tracking-wider mb-2">Menu Utama</p>
            <.sidebar_link navigate={~p"/admin"} active={@active_tab == :dashboard} icon="hero-home">Dashboard</.sidebar_link>
            <.sidebar_link navigate={~p"/admin/pengajuan"} active={@active_tab == :pengajuan} icon="hero-document-text">Pengajuan</.sidebar_link>
            <.sidebar_link navigate={~p"/admin/pelamar"} active={@active_tab == :pelamar} icon="hero-users">Pelamar</.sidebar_link>
            <.sidebar_link navigate={~p"/admin/lowongan"} active={@active_tab == :lowongan} icon="hero-briefcase">Lowongan</.sidebar_link>
            <.sidebar_link navigate={~p"/admin/divisi"} active={@active_tab == :divisi} icon="hero-building-office">Divisi</.sidebar_link>

            <p class="px-2 text-xs font-semibold text-slate-500 uppercase tracking-wider mt-6 mb-2">Manajemen Magang</p>
            <.sidebar_link navigate={~p"/admin/intern"} active={@active_tab == :intern} icon="hero-academic-cap">Intern Aktif</.sidebar_link>
            <.sidebar_link navigate={~p"/admin/presensi"} active={@active_tab == :presensi} icon="hero-camera">Presensi</.sidebar_link>
            <.sidebar_link navigate={~p"/admin/keluhan"} active={@active_tab == :keluhan} icon="hero-chat-bubble-left-right">Keluhan Publik</.sidebar_link>
            <.sidebar_link navigate={~p"/admin/keluhan-magang"} active={@active_tab == :keluhan_magang} icon="hero-chat-bubble-left-ellipsis">Keluhan Magang</.sidebar_link>

            <p class="px-2 text-xs font-semibold text-slate-500 uppercase tracking-wider mt-6 mb-2">Sistem</p>
            <.sidebar_link navigate={~p"/admin/users"} active={@active_tab == :users} icon="hero-user-group">Pengguna</.sidebar_link>
          </nav>

          <div class="p-4 border-t border-slate-200 dark:border-slate-800 mt-auto relative" id="admin-user-menu-container">
            <button type="button" class="group flex w-full items-center gap-3 px-2 py-2 text-sm font-medium rounded-lg hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors" id="admin-user-menu-button" phx-click={JS.toggle(to: "#admin-profile-dropdown", in: {"ease-out duration-100", "opacity-0 scale-95", "opacity-100 scale-100"}, out: {"ease-in duration-75", "opacity-100 scale-100", "opacity-0 scale-95"})} phx-click-away={JS.hide(to: "#admin-profile-dropdown")}>
              <div class="w-8 h-8 rounded-full bg-gradient-to-tr from-slate-700 to-slate-900 flex items-center justify-center text-white text-xs font-bold shadow-sm">
                <%= if @current_user do %><%= String.at(@current_user.name, 0) %><% else %>A<% end %>
              </div>
              <div class="flex-1 text-left">
                <p class="text-slate-900 dark:text-white truncate w-32"><%= @current_user && @current_user.name %></p>
              </div>
              <.icon name="hero-chevron-up" class="w-4 h-4 text-slate-400 group-hover:text-slate-600 dark:group-hover:text-slate-300" />
            </button>
            <div id="admin-profile-dropdown" class="hidden absolute bottom-16 left-4 w-56 bg-white dark:bg-slate-900 rounded-xl shadow-lg border border-slate-100 dark:border-slate-800 z-50 overflow-hidden">
              <div class="py-1">
                <.link navigate={~p"/portal/profile"} class="flex items-center gap-2 px-4 py-2 text-sm text-slate-700 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors"><.icon name="hero-user" class="w-4 h-4" /> Profil Saya</.link>
                <.link navigate={~p"/portal/setting"} class="flex items-center gap-2 px-4 py-2 text-sm text-slate-700 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors"><.icon name="hero-cog-6-tooth" class="w-4 h-4" /> Pengaturan</.link>
              </div>
              <div class="py-1 border-t border-slate-100 dark:border-slate-800 bg-red-50/20 dark:bg-red-900/10">
                <.link href={~p"/auth/logout"} class="flex items-center gap-2 px-4 py-2 text-sm text-red-600 hover:bg-red-50 dark:hover:bg-red-900/20 transition-colors font-medium"><.icon name="hero-arrow-right-on-rectangle" class="w-4 h-4" /> Keluar</.link>
              </div>
            </div>
          </div>
        </aside>

        <!-- Main Content Area -->
        <div class="flex-1 flex flex-col overflow-hidden">
          <!-- Mobile Header -->
          <header class="md:hidden border-b border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 h-16 flex items-center justify-between px-4 shrink-0">
             <div class="flex items-center gap-3">
               <button type="button" phx-click={show_mobile_sidebar()} class="text-slate-500 dark:text-slate-400 hover:text-slate-700 dark:hover:text-slate-300">
                 <.icon name="hero-bars-3" class="w-6 h-6" />
               </button>
               <span class="font-bold text-slate-900 dark:text-white">Admin Panel</span>
             </div>
          </header>

          <.admin_mobile_sidebar active_tab={@active_tab} />

          <main class="flex-1 overflow-y-auto">
            <div class="max-w-7xl mx-auto flex-grow min-h-[calc(100vh-12rem)]">
              <%= render_slot(@inner_block) %>
            </div>
            <.footer />
          </main>
        </div>
      </div>
    """
  end

  attr :navigate, :string, required: true
  attr :active, :boolean, default: false
  attr :icon, :string, required: true
  slot :inner_block, required: true

  def sidebar_link(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      class={[
        "flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors",
        @active && "bg-blue-50 dark:bg-blue-900/30 text-blue-700 dark:text-blue-400 shadow-sm ring-1 ring-blue-700/10 dark:ring-blue-400/20",
        !@active && "text-slate-600 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-slate-800 hover:text-slate-900 dark:hover:text-white"
      ]}
    >
      <.icon name={@icon} class="w-5 h-5 shrink-0" />
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  attr :active_tab, :atom, default: :dashboard
  defp admin_mobile_sidebar(assigns) do
    ~H"""
      <div id="mobile-sidebar-container" class="relative z-50 md:hidden hidden" role="dialog" aria-modal="true">
        <div id="mobile-sidebar-backdrop" class="fixed inset-0 bg-slate-900/50 backdrop-blur-sm" phx-click={hide_mobile_sidebar()}></div>
        <div id="mobile-sidebar-panel" class="fixed inset-y-0 left-0 w-full max-w-xs bg-white dark:bg-slate-900 shadow-xl flex flex-col overflow-y-auto">
          <div class="p-6 border-b border-slate-100 dark:border-slate-800 flex items-center justify-between">
            <div class="flex items-center gap-2">
              <div class="w-7 h-7 rounded-lg flex items-center justify-center shadow-sm bg-white dark:bg-slate-800">
                <img src="/images/utm_logo.png" class="h-8 w-auto" alt="UTM Logo">
              </div>
              <span class="font-bold text-slate-900 dark:text-white">Menu Admin</span>
            </div>
            <button type="button" phx-click={hide_mobile_sidebar()} class="p-2 text-slate-400 dark:text-slate-500 hover:text-slate-500 dark:hover:text-slate-400"><.icon name="hero-x-mark" class="w-6 h-6" /></button>
          </div>
          <nav class="flex-1 px-4 py-6 space-y-2">
            <.mobile_nav_link navigate={~p"/admin"} active={@active_tab == :dashboard} icon="hero-home">Dashboard</.mobile_nav_link>
            <.mobile_nav_link navigate={~p"/admin/pengajuan"} active={@active_tab == :pengajuan} icon="hero-document-text">Pengajuan</.mobile_nav_link>
            <.mobile_nav_link navigate={~p"/admin/pelamar"} active={@active_tab == :pelamar} icon="hero-users">Pelamar</.mobile_nav_link>
            <.mobile_nav_link navigate={~p"/admin/intern"} active={@active_tab == :intern} icon="hero-academic-cap">Intern Aktif</.mobile_nav_link>
            <.mobile_nav_link navigate={~p"/admin/presensi"} active={@active_tab == :presensi} icon="hero-camera">Presensi</.mobile_nav_link>
            <.mobile_nav_link navigate={~p"/admin/keluhan"} active={@active_tab == :keluhan} icon="hero-chat-bubble-left-right">Keluhan Publik</.mobile_nav_link>
            <.mobile_nav_link navigate={~p"/admin/keluhan-magang"} active={@active_tab == :keluhan_magang} icon="hero-chat-bubble-left-ellipsis">Keluhan Magang</.mobile_nav_link>
            <.mobile_nav_link navigate={~p"/admin/users"} active={@active_tab == :users} icon="hero-user-group">Pengguna</.mobile_nav_link>
            <.mobile_nav_link navigate={~p"/admin/lowongan"} active={@active_tab == :lowongan} icon="hero-briefcase">Lowongan</.mobile_nav_link>
          </nav>
          <div class="p-4 border-t border-slate-100 dark:border-slate-800">
            <.link href={~p"/auth/logout"} method="delete" class="flex items-center gap-3 w-full px-4 py-3 text-sm font-medium text-red-600 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-xl transition-colors"><.icon name="hero-arrow-right-on-rectangle" class="w-5 h-5" /> Keluar</.link>
          </div>
        </div>
      </div>
    """
  end

  attr :active_tab, :atom, default: :dashboard
  attr :current_user, :any, default: nil
  slot :inner_block, required: false

  def navbarMentor(assigns) do
    ~H"""
      <nav class="border-b border-slate-200 dark:border-slate-800 shadow-sm bg-white dark:bg-slate-900 sticky top-0 z-40">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 h-16 flex items-center justify-between">
          <div class="flex items-center gap-3">
            <button type="button" class="p-2 -ml-2 md:hidden hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg text-slate-500 dark:text-slate-400" phx-click={show_mobile_sidebar()}><.icon name="hero-bars-3" class="w-6 h-6" /></button>
            <div class="flex items-center gap-3">
              <div class="w-9 h-9 rounded-xl flex items-center justify-center shadow-md bg-white dark:bg-slate-800 border border-slate-100 dark:border-slate-700">
                <img src="/images/utm_logo.png" class="h-8 w-auto hover:scale-105 transition-transform drop-shadow-sm" alt="UTM Logo">
              </div>
              <div class="hidden sm:block">
                <p class="font-bold text-sm leading-none text-slate-900 dark:text-white">UPA TIK Mentor</p>
                <p class="text-xs text-slate-500">Panel Pembimbing</p>
              </div>
            </div>
          </div>
          <div class="hidden md:flex gap-2 items-center">
            <.nav_link navigate={~p"/mentor"} active={@active_tab == :dashboard}>Beranda</.nav_link>
            <.nav_link navigate={~p"/mentor/presensi"} active={@active_tab == :presensi}>Scanner Presensi</.nav_link>
            <.nav_link navigate={~p"/mentor/keluhan-magang"} active={@active_tab == :keluhan_magang}>Keluhan Magang</.nav_link>
            <div class="w-px h-6 bg-slate-200 mx-2"></div>

            <div class="relative ml-2">
              <button type="button" class="group cursor-pointer flex items-center gap-2 p-1 rounded-full hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors" id="user-menu-button-mentor" phx-click={JS.toggle(to: "#profile-dropdown-mentor", in: {"ease-out duration-100", "opacity-0 scale-95", "opacity-100 scale-100"}, out: {"ease-in duration-75", "opacity-100 scale-100", "opacity-0 scale-95"})} phx-click-away={JS.hide(to: "#profile-dropdown-mentor")}>
                <div class="w-8 h-8 rounded-full bg-gradient-to-tr from-green-500 to-teal-600 flex items-center justify-center text-white text-xs font-bold shadow-sm transition-transform group-hover:scale-105">
                  <%= if @current_user do %><%= String.at(@current_user.name, 0) %><% else %>M<% end %>
                </div>
                <.icon name="hero-chevron-down" class="w-4 h-4 transition-colors group-hover:text-green-600" />
              </button>
              <div id="profile-dropdown-mentor" class="hidden absolute right-0 mt-2 w-48 bg-white dark:bg-slate-800 rounded-xl shadow-lg z-50 overflow-hidden border border-slate-100 dark:border-slate-700">
                <div class="px-4 py-3 border-b border-slate-100 dark:border-slate-700 bg-slate-50/50 dark:bg-slate-900/50">
                  <p class="text-xs text-slate-500 dark:text-slate-400">Masuk sebagai Mentor</p>
                  <p class="text-sm font-semibold text-slate-900 dark:text-white truncate">
                    <%= @current_user && @current_user.name %>
                  </p>
                </div>
                <div class="py-1">
                  <.link navigate={~p"/portal/profile"} class="flex items-center gap-2 px-4 py-2 text-sm text-slate-700 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-slate-700 transition-colors"><.icon name="hero-user" class="w-4 h-4" /> Profil Saya</.link>
                  <.link navigate={~p"/portal/setting"} class="flex items-center gap-2 px-4 py-2 text-sm text-slate-700 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-slate-700 transition-colors"><.icon name="hero-cog-6-tooth" class="w-4 h-4" /> Pengaturan</.link>
                </div>
                <div class="py-1 border-t border-slate-100 dark:border-slate-700 bg-red-50/20 dark:bg-red-900/10">
                  <.link href={~p"/auth/logout"} class="flex items-center gap-2 px-4 py-2 text-sm text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20 transition-colors font-medium"><.icon name="hero-arrow-right-on-rectangle" class="w-4 h-4" /> Keluar</.link>
                </div>
              </div>
            </div>
          </div>
        </div>
      </nav>

      <.mentor_mobile_sidebar active_tab={@active_tab} />

      <main class="max-w-7xl mx-auto mt-4 px-4 sm:px-6 pb-20 flex-grow">
        <%= render_slot(@inner_block) %>
      </main>

      <.footer />
    """
  end

  attr :active_tab, :atom, default: :dashboard
  defp mentor_mobile_sidebar(assigns) do
    ~H"""
      <div id="mobile-sidebar-container" class="relative z-50 md:hidden hidden" role="dialog" aria-modal="true">
        <div id="mobile-sidebar-backdrop" class="fixed inset-0 bg-slate-900/50 backdrop-blur-sm" phx-click={hide_mobile_sidebar()}></div>
        <div id="mobile-sidebar-panel" class="fixed inset-y-0 left-0 w-full max-w-xs bg-white dark:bg-slate-900 shadow-xl flex flex-col overflow-y-auto">
          <div class="p-6 border-b border-slate-100 dark:border-slate-800 flex items-center justify-between">
            <div class="flex items-center gap-2">
              <div class="w-7 h-7 rounded-lg flex items-center justify-center shadow-sm bg-white dark:bg-slate-800">
                <img src="/images/utm_logo.png" class="h-8 w-auto" alt="UTM Logo">
              </div>
              <span class="font-bold text-slate-900 dark:text-white">Menu Mentor</span>
            </div>
            <button type="button" phx-click={hide_mobile_sidebar()} class="p-2 text-slate-400 dark:text-slate-500 hover:text-slate-500 dark:hover:text-slate-400"><.icon name="hero-x-mark" class="w-6 h-6" /></button>
          </div>
          <nav class="flex-1 px-4 py-6 space-y-2">
            <.mobile_nav_link navigate={~p"/mentor"} active={@active_tab == :dashboard} icon="hero-home">Beranda</.mobile_nav_link>
            <.mobile_nav_link navigate={~p"/mentor/presensi"} active={@active_tab == :presensi} icon="hero-camera">Scanner Presensi</.mobile_nav_link>
            <.mobile_nav_link navigate={~p"/mentor/keluhan-magang"} active={@active_tab == :keluhan_magang} icon="hero-chat-bubble-left-ellipsis">Keluhan Magang</.mobile_nav_link>
          </nav>
          <div class="p-4 border-t border-slate-100 dark:border-slate-800">
            <.link href={~p"/auth/logout"} method="delete" class="flex items-center gap-3 w-full px-4 py-3 text-sm font-medium text-red-600 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-xl transition-colors"><.icon name="hero-arrow-right-on-rectangle" class="w-5 h-5" /> Keluar</.link>
          </div>
        </div>
      </div>
    """
  end

  attr :heading_text_primary, :string, required: true
  attr :heading_text_secondary, :string, required: true
  attr :sub_heading_text, :string, required: true

  def heading_page(assigns) do
    ~H"""
      <div class="text-center space-y-3 py-8">
        <h1 class="text-4xl font-extrabold text-slate-900 dark:text-white tracking-tight sm:text-5xl uppercase italic">
          {@heading_text_primary} <span class="text-blue-600">{@heading_text_secondary}</span>
        </h1>
        <p class="text-slate-500 dark:text-white text-lg font-medium max-w-7xl mx-auto">{@sub_heading_text}</p>
      </div>
    """
  end

  attr :navigate, :string, required: true
  attr :active, :boolean, default: false
  slot :inner_block, required: true

  defp nav_link(assigns) do
    ~H"""
      <.link navigate={@navigate} class={["text-sm font-medium transition-colors px-3 py-2 rounded-md", @active && "bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-400", !@active && "text-slate-600 dark:text-slate-400 hover:text-blue-600 dark:hover:text-blue-400 hover:bg-slate-100 dark:hover:bg-slate-800"]}>
        <%= render_slot(@inner_block) %>
      </.link>
    """
  end

  defp show_mobile_sidebar(js \\ %JS{}) do
    js |> JS.show(to: "#mobile-sidebar-container") |> JS.transition("fade-in", to: "#mobile-sidebar-backdrop") |> JS.transition({"ease-out duration-300", "-translate-x-full", "translate-x-0"}, to: "#mobile-sidebar-panel") |> JS.add_class("overflow-hidden", to: "body")
  end

  defp hide_mobile_sidebar(js \\ %JS{}) do
    js |> JS.transition("fade-out", to: "#mobile-sidebar-backdrop") |> JS.transition({"ease-in duration-200", "translate-x-0", "-translate-x-full"}, to: "#mobile-sidebar-panel") |> JS.hide(to: "#mobile-sidebar-container", transition: "fade-out") |> JS.remove_class("overflow-hidden", to: "body")
  end

  def footer(assigns) do
    ~H"""
    <footer class="bg-white dark:bg-slate-900 border-t border-slate-200 dark:border-slate-800 mt-16">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 py-12">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-8">
          <div class="md:col-span-2">
            <div class="flex items-center gap-3 mb-4">
              <img src="/images/utm_logo.png" class="h-10 w-auto" alt="UTM Logo">
              <div>
                <p class="font-bold text-lg text-slate-900 dark:text-white">UPA TIK</p>
                <p class="text-sm text-slate-500 dark:text-white">Universitas Trunojoyo Madura</p>
              </div>
            </div>
            <p class="text-sm text-slate-600 dark:text-slate-400 leading-relaxed max-w-sm">
              Sistem Informasi Manajemen Magang UPA TIK. Platform terpadu untuk pendaftaran, monitoring, dan evaluasi kegiatan magang mahasiswa di lingkungan Universitas Trunojoyo Madura.
            </p>
          </div>
          <div>
            <h3 class="font-bold text-slate-900 dark:text-white mb-4">Tautan Cepat</h3>
            <ul class="space-y-3">
              <li><.link navigate={~p"/"} class="text-sm text-slate-600 dark:text-slate-400 hover:text-blue-600">Beranda</.link></li>
              <li><.link navigate={~p"/portal/lowongan"} class="text-sm text-slate-600 dark:text-slate-400 hover:text-blue-600">Lowongan Magang</.link></li>
              <li><.link navigate={~p"/portal/ajukan"} class="text-sm text-slate-600 dark:text-slate-400 hover:text-blue-600">Pengajuan Magang</.link></li>
            </ul>
          </div>
          <div>
            <h3 class="font-bold text-slate-900 dark:text-white mb-4">Kontak Kami</h3>
            <ul class="space-y-3 text-sm text-slate-600 dark:text-slate-400">
              <li class="flex items-start gap-3">
                <.icon name="hero-map-pin" class="w-5 h-5 shrink-0 text-slate-400" />
                <span>Jl. Raya Telang, PO. Box. 2 Kamal, Bangkalan - Madura</span>
              </li>
              <li class="flex items-center gap-3">
                <.icon name="hero-envelope" class="w-5 h-5 shrink-0 text-slate-400" />
                <a href="mailto:upatik@trunojoyo.ac.id" class="hover:text-blue-600">upatik@trunojoyo.ac.id</a>
              </li>
            </ul>
          </div>
        </div>
        <div class="border-t border-slate-100 dark:border-slate-800 mt-12 pt-8 flex flex-col md:flex-row items-center justify-between gap-4">
          <p class="text-sm text-slate-500">
            &copy; {Date.utc_today().year} UPA TIK Universitas Trunojoyo Madura. Hak Cipta Dilindungi.
          </p>
          <div class="flex items-center gap-4 text-slate-400">
          </div>
        </div>
      </div>
    </footer>
    """
  end
  def custom_confirm(assigns) do
    ~H"""
    <div id="custom-confirm-modal" class="hidden fixed inset-0 z-[100] flex items-center justify-center bg-slate-900/40 backdrop-blur-sm transition-opacity opacity-0">
      <div class="bg-white rounded-2xl shadow-xl border border-slate-100 max-w-sm w-full mx-4 transform scale-95 transition-transform overflow-hidden">
        <div class="p-6 text-center">
          <div class="w-12 h-12 rounded-full bg-red-100 flex items-center justify-center mx-auto mb-4">
            <.icon name="hero-exclamation-triangle" class="w-6 h-6 text-red-600" />
          </div>
          <h3 class="text-lg font-bold text-slate-900 mb-2">Konfirmasi</h3>
          <p id="custom-confirm-msg" class="text-sm text-slate-600 mb-6"></p>
          <div class="flex gap-3 justify-center">
            <button id="custom-confirm-cancel" class="px-4 py-2 text-sm font-semibold text-slate-600 hover:bg-slate-100 rounded-xl transition-colors">
              Batal
            </button>
            <button id="custom-confirm-ok" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 text-sm font-semibold rounded-xl transition-colors">
              Ya, Lanjutkan
            </button>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
