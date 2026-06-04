defmodule UpaTikPortalWeb.Home.Magang.Index do
  use UpaTikPortalWeb, :live_view

  on_mount {UpaTikPortalWeb.UserAuth, :mount_current_user}

  alias UpaTikPortal.Recruitment.InternshipParticipationService
  alias UpaTikPortal.Recruitment.WeeklyLogService
  alias UpaTikPortal.Recruitment.PresenceService
  alias UpaTikPortal.Recruitment.InternComplaintService

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    participation = InternshipParticipationService.get_active_participation_by_user(user.id)

    socket =
      if participation do
        today_presence = PresenceService.get_today(participation.id)
        presence_stats = PresenceService.stats(participation.id)
        log_stats = WeeklyLogService.stats(participation.id)
        complaint_stats = InternComplaintService.stats(participation.id)

        token = UpaTikPortal.Recruitment.QrCodeService.generate_token(participation.id)
        qr_svg = UpaTikPortal.Recruitment.QrCodeService.generate_svg(token)

        socket
        |> assign(:participation, participation)
        |> assign(:today_presence, today_presence)
        |> assign(:presence_stats, presence_stats)
        |> assign(:log_stats, log_stats)
        |> assign(:complaint_stats, complaint_stats)
        |> assign(:qr_svg, qr_svg)
        |> assign(:has_active_internship, true)
      else
        participations = InternshipParticipationService.get_participation_by_user(user.id)

        socket
        |> assign(:participation, nil)
        |> assign(:participations, participations)
        |> assign(:search, "")
        |> assign(:status, "")
        |> assign(:has_active_internship, false)
      end

    {:ok, assign(socket, :page_title, "Magang Saya")}
  end

  @impl true
  def handle_event("filter", params, socket) do
    user = socket.assigns.current_user
    search = params["search"] || ""
    status = params["status"] || ""
    
    opts = [search: search, status: status]
    participations = InternshipParticipationService.get_participation_by_user(user.id, opts)

    {:noreply,
     socket
     |> assign(:participations, participations)
     |> assign(:search, search)
     |> assign(:status, status)}
  end

  @impl true
  def handle_event("check_in", _params, socket) do
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

  @impl true
  def handle_event("check_out", _params, socket) do
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

  defp status_label("applied"), do: "Menunggu Review"
  defp status_label("interview"), do: "Tahap Interview"
  defp status_label("accepted"), do: "Diterima"
  defp status_label("rejected"), do: "Ditolak"
  defp status_label(_), do: "Tidak Diketahui"

  defp status_color("applied"), do: "bg-blue-100 text-blue-700"
  defp status_color("interview"), do: "bg-yellow-100 text-yellow-700"
  defp status_color("accepted"), do: "bg-green-100 text-green-700"
  defp status_color("rejected"), do: "bg-red-100 text-red-700"
  defp status_color(_), do: "bg-gray-100 text-gray-700"
end
