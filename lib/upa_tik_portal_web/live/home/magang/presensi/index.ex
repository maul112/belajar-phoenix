defmodule UpaTikPortalWeb.Home.Magang.Presensi.Index do
  use UpaTikPortalWeb, :live_view

  on_mount {UpaTikPortalWeb.UserAuth, :mount_current_user}

  alias UpaTikPortal.Recruitment.InternshipParticipationService
  alias UpaTikPortal.Recruitment.PresenceService

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    participation = InternshipParticipationService.get_active_participation_by_user(user.id)

    if is_nil(participation) do
      {:ok,
       socket
       |> put_flash(:error, "Kamu tidak memiliki magang aktif.")
       |> push_navigate(to: ~p"/portal/magang")}
    else
      presences = PresenceService.list_by_participation(participation.id)
      stats = PresenceService.stats(participation.id)

      token = UpaTikPortal.Recruitment.QrCodeService.generate_token(participation.id)
      qr_svg = UpaTikPortal.Recruitment.QrCodeService.generate_svg(token)

      {:ok,
       socket
       |> assign(:page_title, "Presensi Saya")
       |> assign(:participation, participation)
       |> assign(:stats, stats)
       |> assign(:qr_svg, qr_svg)
       |> stream(:presences, presences)}
    end
  end

  defp status_label("present"), do: "Hadir"
  defp status_label("sick"), do: "Sakit"
  defp status_label("permit"), do: "Izin"
  defp status_label("absent"), do: "Alpha"
  defp status_label(_), do: "-"

  defp status_color("present"), do: "bg-green-100 text-green-700"
  defp status_color("sick"), do: "bg-blue-100 text-blue-700"
  defp status_color("permit"), do: "bg-yellow-100 text-yellow-700"
  defp status_color("absent"), do: "bg-red-100 text-red-700"
  defp status_color(_), do: "bg-gray-100 text-gray-600"
end
