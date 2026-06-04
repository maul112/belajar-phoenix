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

  # ─── Public routes ────────────────────────────────────────────────────────
  scope "/", UpaTikPortalWeb do
    pipe_through :browser

    live "/", LoginLive, :index
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
    pipe_through [:browser, :require_auth]

    get "/", PortalController, :index
    live "/ajukan", RequestLive, :index
    live "/status", RequestStatusLive, :index
    live "/keluhan", KeluhanLive, :index

    live "/", Home.Index, :index
    live "/lowongan", Home.Lowongan.Index, :index
    live "/lowongan/:id", Home.Lowongan.Detail, :show
    live "/lowongan/:id/ajukan", Home.Lowongan.Ajukan, :index

    live "/profile", Home.Setting.Profile, :index
    live "/setting", Home.Setting.Index, :index
  end

  # ─── Admin-only routes ────────────────────────────────────────────────────
  scope "/admin", UpaTikPortalWeb.Admin do
    pipe_through [:browser, :require_auth, :require_admin_access]

    live "/", DashboardLive, :index
    live "/pengajuan", RequestListLive, :index
    live "/pengajuan/:id", RequestDetailLive, :show
    live "/keluhan", KeluhanListLive, :index
    live "/users", UserListLive, :index

    live "/lowongan", LowonganLive.Index, :index
    live "/lowongan/new", LowonganLive.New, :new
    live "/lowongan/:id/edit", LowonganLive.Edit, :edit
  end

  scope "/storage", UpaTikPortalWeb do
    pipe_through [:browser]

    get "/view-image/:key", StorageController, :view_image
  end
end
