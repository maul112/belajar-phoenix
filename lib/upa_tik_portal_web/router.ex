defmodule UpaTikPortalWeb.Router do
  use UpaTikPortalWeb, :router

  import UpaTikPortalWeb.Plugs.Auth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {UpaTikPortalWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :require_auth do
    plug :require_authenticated
  end

  pipeline :require_admin_access do
    plug :require_admin
  end

  pipeline :require_mentor_access do
    plug :require_mentor
  end

  pipeline :require_mahasiswa_access do
    plug :require_mahasiswa
  end

  # ─── Public routes ────────────────────────────────────────────────────────
  scope "/", UpaTikPortalWeb do
    pipe_through :browser

    live "/", Auth.LoginLive, :index
    get "/logout", AuthController, :redirect_to_logout
  end

  # Ueberauth Google OAuth (Controller-based, not LiveView)
  scope "/auth", UpaTikPortalWeb do
    pipe_through :browser

    get "/google", AuthController, :request
    get "/google/callback", AuthController, :callback
    get "/logout", AuthController, :delete
  end

  # ─── Authenticated mahasiswa routes ───────────────────────────────────────
  scope "/portal", UpaTikPortalWeb do
    pipe_through [:browser, :require_auth, :require_mahasiswa_access]

    live "/", Home.Index, :index
    live "/ajukan", Home.Ajukan.Index, :index
    live "/status", Home.Status.Index, :index
    live "/keluhan", Home.Keluhan.Index, :index
    
    live "/lowongan", Home.Lowongan.Index, :index
    live "/lowongan/:id", Home.Lowongan.Detail, :show
    live "/lowongan/:id/ajukan", Home.Lowongan.Ajukan, :index


    # ─── Magang routes ────────────────────────────────────────────
    live "/magang", Home.Magang.Index, :index
    live "/magang/logbook", Home.Magang.Logbook.Index, :index
    live "/magang/logbook/new", Home.Magang.Logbook.New, :new
    live "/magang/logbook/:id/edit", Home.Magang.Logbook.Edit, :edit
    live "/magang/presensi", Home.Magang.Presensi.Index, :index
    live "/magang/complaint", Home.Magang.Complaint.Index, :index
    live "/magang/:id", Home.Magang.Show, :show
  end

  # ─── Authenticated generic routes (Profile & Settings) ──────────────────
  scope "/portal", UpaTikPortalWeb do
    pipe_through [:browser, :require_auth]

    live_session :account, on_mount: [{UpaTikPortalWeb.UserAuth, :mount_current_user}] do
      live "/profile", Home.Setting.Profile, :index
      live "/setting", Home.Setting.Index, :index
    end
  end

  # ─── Admin-only routes ────────────────────────────────────────────────────
  scope "/admin", UpaTikPortalWeb.Admin do
    pipe_through [:browser, :require_auth, :require_admin_access]

    live_session :admin, on_mount: [{UpaTikPortalWeb.UserAuth, :mount_current_user}] do
      live "/", DashboardLive, :index
      live "/pengajuan", PengajuanLive.Index, :index
      live "/pengajuan/:id", PengajuanLive.Show, :show
      live "/keluhan", KeluhanLive.Index, :index
      live "/users", UserLive.Index, :index
      live "/divisi", DivisionLive.Index, :index

      live "/lowongan", LowonganLive.Index, :index
      live "/lowongan/new", LowonganLive.New, :new
      live "/lowongan/:id/edit", LowonganLive.Edit, :edit

      live "/pelamar", PelamarLive.Index, :index
      live "/pelamar/:id", PelamarLive.Detail, :show

      live "/intern", InternLive.Index, :index
      live "/intern/:id", InternLive.Show, :show
      live "/presensi", PresensiLive.Index, :index
      live "/keluhan-magang", ComplaintLive.Index, :index
    end
  end
  
  scope "/admin", UpaTikPortalWeb do
    pipe_through [:browser, :require_auth, :require_admin_access]
    get "/presensi/export", PresenceCsvController, :export
  end

  # ─── Mentor-only routes ───────────────────────────────────────────────────
  scope "/mentor", UpaTikPortalWeb.Mentor do
    pipe_through [:browser, :require_auth, :require_mentor_access]

    live_session :mentor, on_mount: [{UpaTikPortalWeb.UserAuth, :mount_current_user}] do
      live "/", DashboardLive, :index
      live "/intern/:id", InternLive.Show, :show
      live "/presensi", PresensiLive.Index, :index
      live "/keluhan-magang", ComplaintLive.Index, :index
    end
  end

  scope "/storage", UpaTikPortalWeb do
    pipe_through [:browser]

    get "/view-image/:key", StorageController, :view_image
  end
end
