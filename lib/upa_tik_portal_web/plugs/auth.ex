defmodule UpaTikPortalWeb.Plugs.Auth do
  @moduledoc """
  Plugs untuk autentikasi dan otorisasi berbasis session.
  """
  import Plug.Conn
  import Phoenix.Controller
  alias UpaTikPortal.Accounts

  @doc "Muat user dari session ke assigns"
  def load_current_user(conn, _opts) do
    user_id = get_session(conn, :user_id)

    if user_id do
      case Accounts.get_user(user_id) do
        nil -> assign(conn, :current_user, nil)
        user -> assign(conn, :current_user, user)
      end
    else
      assign(conn, :current_user, nil)
    end
  end

  @doc "Wajib login — redirect ke / jika belum login"
  def require_authenticated(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "Silakan login terlebih dahulu.")
      |> redirect(to: "/")
      |> halt()
    end
  end

  @doc "Wajib admin — 403 jika bukan admin"
  def require_admin(conn, _opts) do
    case conn.assigns[:current_user] do
      %{role: "admin"} ->
        conn

      %{role: "mentor"} ->
        conn
        |> put_status(:forbidden)
        |> put_flash(:error, "Akses ditolak. Mentor tidak dapat mengakses halaman admin.")
        |> redirect(to: "/mentor")
        |> halt()

      _ ->
        conn
        |> put_status(:forbidden)
        |> put_flash(:error, "Akses ditolak. Hanya admin yang dapat mengakses halaman ini.")
        |> redirect(to: "/portal")
        |> halt()
    end
  end

  @doc "Wajib mentor — 403 jika bukan mentor"
  def require_mentor(conn, _opts) do
    case conn.assigns[:current_user] do
      %{role: "mentor"} ->
        conn

      %{role: "admin"} ->
        conn
        |> put_status(:forbidden)
        |> put_flash(:error, "Akses ditolak. Admin tidak dapat mengakses halaman mentor.")
        |> redirect(to: "/admin")
        |> halt()

      _ ->
        conn
        |> put_status(:forbidden)
        |> put_flash(:error, "Akses ditolak. Hanya mentor yang dapat mengakses halaman ini.")
        |> redirect(to: "/portal")
        |> halt()
    end
  end

  @doc "Wajib mahasiswa — redirect jika admin/mentor"
  def require_mahasiswa(conn, _opts) do
    case conn.assigns[:current_user] do
      %{role: "mahasiswa"} ->
        conn

      %{role: "admin"} ->
        conn
        |> put_flash(:error, "Admin tidak dapat mengakses portal mahasiswa.")
        |> redirect(to: "/admin")
        |> halt()

      %{role: "mentor"} ->
        conn
        |> put_flash(:error, "Mentor tidak dapat mengakses portal mahasiswa.")
        |> redirect(to: "/mentor")
        |> halt()

      _ ->
        conn
        |> put_flash(:error, "Akses ditolak.")
        |> redirect(to: "/")
        |> halt()
    end
  end
end
