# lib/upa_tik_portal_web/user_auth.ex
defmodule UpaTikPortalWeb.UserAuth do
  import Phoenix.Component
  import Phoenix.LiveView
  alias UpaTikPortal.Accounts

  def on_mount(:mount_current_user, _params, session, socket) do
    case session["user_id"] do
      nil ->
        {:halt, redirect(socket, to: "/auth/google")}

      user_id ->
        user = Accounts.get_user(user_id)
        {:cont, assign(socket, :current_user, user)}
    end
  end

  def on_mount(:ensure_admin, _params, _session, socket) do
    case socket.assigns.current_user do
      %{role: "admin"} ->
        {:cont, socket}

      %{role: "mentor"} ->
        {:halt,
         socket
         |> put_flash(:error, "Akses ditolak. Mentor tidak dapat mengakses halaman admin.")
         |> redirect(to: "/mentor")}

      _ ->
        {:halt,
         socket
         |> put_flash(:error, "Akses ditolak. Hanya admin yang dapat mengakses halaman ini.")
         |> redirect(to: "/portal")}
    end
  end

  def on_mount(:ensure_mentor, _params, _session, socket) do
    case socket.assigns.current_user do
      %{role: "mentor"} ->
        {:cont, socket}

      %{role: "admin"} ->
        {:halt,
         socket
         |> put_flash(:error, "Akses ditolak. Admin tidak dapat mengakses halaman mentor.")
         |> redirect(to: "/admin")}

      _ ->
        {:halt,
         socket
         |> put_flash(:error, "Akses ditolak. Hanya mentor yang dapat mengakses halaman ini.")
         |> redirect(to: "/portal")}
    end
  end

  def on_mount(:ensure_mahasiswa, _params, _session, socket) do
    case socket.assigns.current_user do
      %{role: "mahasiswa"} ->
        {:cont, socket}

      %{role: "admin"} ->
        {:halt,
         socket
         |> put_flash(:error, "Admin tidak dapat mengakses portal mahasiswa.")
         |> redirect(to: "/admin")}

      %{role: "mentor"} ->
        {:halt,
         socket
         |> put_flash(:error, "Mentor tidak dapat mengakses portal mahasiswa.")
         |> redirect(to: "/mentor")}

      _ ->
        {:halt,
         socket
         |> put_flash(:error, "Akses ditolak.")
         |> redirect(to: "/")}
    end
  end
end
