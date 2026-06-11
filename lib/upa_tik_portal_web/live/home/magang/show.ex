defmodule UpaTikPortalWeb.Home.Magang.Show do
  use UpaTikPortalWeb, :live_view

  on_mount {UpaTikPortalWeb.UserAuth, :mount_current_user}

  alias UpaTikPortal.Recruitment.InternshipParticipationService
  alias UpaTikPortal.Recruitment.WeeklyLogService
  alias UpaTikPortal.Recruitment.PresenceService
  alias UpaTikPortal.Recruitment.InternComplaintService

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    user = socket.assigns.current_user
    participation = InternshipParticipationService.get_internship_participation!(id)

    # Pastikan ini partisipasi milik user tersebut
    if participation.user_id != user.id do
      {:ok, push_navigate(socket, to: ~p"/portal/magang")}
    else
      # Cek apakah sudah lewat masa magang berdasarkan opening.end_date
      today = UpaTikPortalWeb.Helpers.TimeHelper.today_wib()
      start_date = participation.internship_opening.start_date
      end_date = participation.internship_opening.end_date
      
      is_completed = end_date && Date.compare(today, end_date) == :gt
      is_started = start_date && Date.compare(today, start_date) != :lt
      is_active = participation.status == "accepted" && is_started && not is_completed
      today_presence = PresenceService.get_today(participation.id)
      presence_stats = PresenceService.stats(participation.id)
      log_stats = WeeklyLogService.stats(participation.id)
      complaint_stats = InternComplaintService.stats(participation.id)

      token = UpaTikPortal.Recruitment.QrCodeService.generate_token(participation.id)
      qr_svg = UpaTikPortal.Recruitment.QrCodeService.generate_svg(token)

      {:ok,
       socket
       |> assign(:page_title, "Dashboard Magang")
       |> assign(:participation, participation)
       |> assign(:is_completed, is_completed)
       |> assign(:is_active, is_active)
       |> assign(:today_presence, today_presence)
       |> assign(:presence_stats, presence_stats)
       |> assign(:log_stats, log_stats)
       |> assign(:complaint_stats, complaint_stats)
       |> assign(:qr_svg, qr_svg)}
    end
  end

  @impl true
  def handle_event("check_in", _params, socket) do
    if socket.assigns.is_completed do
      {:noreply, socket}
    else
      participation = socket.assigns.participation

      case PresenceService.check_in(participation.id) do
        {:ok, presence} ->
          {:noreply,
           socket
           |> assign(:today_presence, presence)
           |> put_flash(:info, "Check-in berhasil! Selamat bekerja 🎉")}

        {:error, :already_checked_in, _existing} ->
          {:noreply, put_flash(socket, :error, "Kamu sudah check-in hari ini.")}

        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Gagal check-in. Coba lagi.")}
      end
    end
  end

  @impl true
  def handle_event("check_out", _params, socket) do
    if socket.assigns.is_completed do
      {:noreply, socket}
    else
      participation = socket.assigns.participation

      case PresenceService.check_out(participation.id) do
        {:ok, presence} ->
          {:noreply,
           socket
           |> assign(:today_presence, presence)
           |> put_flash(:info, "Check-out berhasil! Sampai besok 👋")}

        {:error, :not_checked_in} ->
          {:noreply, put_flash(socket, :error, "Kamu belum check-in hari ini.")}

        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Gagal check-out. Coba lagi.")}
      end
    end
  end
end
