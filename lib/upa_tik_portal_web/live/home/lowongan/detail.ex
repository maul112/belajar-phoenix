defmodule UpaTikPortalWeb.Home.Lowongan.Detail do
  use UpaTikPortalWeb, :live_view
  alias UpaTikPortal.Recruitment.InternshipOpeningService

  on_mount {UpaTikPortalWeb.UserAuth, :mount_current_user}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    opening = InternshipOpeningService.get_internship_opening!(id)
    user = socket.assigns.current_user

    {:ok,
     socket
     |> assign(:page_title, opening.title)
     |> assign(:opening, opening)
     |> assign(:user, user)
     |> assign(:has_applied, false)}
  end

  @impl true
  def handle_event("ajukan_magang", _params, socket) do
    # Logika Pengajuan Magang
    # Karena kita belum punya tabel 'Applications/Pendaftar',
    # kita buat simulasi dengan mengubah state 'has_applied' sementara.

    # Nanti di sini kamu panggil fungsi seperti:
    # Recruitment.create_application(%{user_id: user.id, opening_id: opening.id})

    {:noreply,
     socket
     |> put_flash(:info, "Pengajuan magang berhasil dikirim! Silakan cek status Anda secara berkala.")}
  end
end
