defmodule UpaTikPortalWeb.Admin.InternLive.Index do
  use UpaTikPortalWeb, :live_view

  alias UpaTikPortal.Recruitment.InternshipParticipationService
  alias UpaTikPortal.Recruitment.PresenceService

  @impl true
  def mount(_params, _session, socket) do
    interns = InternshipParticipationService.list_active_interns()

    {:ok,
     socket
     |> assign(:page_title, "Daftar Intern Aktif")
     |> assign(:search, "")
     |> stream(:interns, interns)}
  end

  @impl true
  def handle_event("filter", %{"search" => search}, socket) do
    interns = InternshipParticipationService.list_active_interns(search: search)

    {:noreply,
     socket
     |> assign(:search, search)
     |> stream(:interns, interns, reset: true)}
  end

  defp attendance_rate(participation_id) do
    stats = PresenceService.stats(participation_id)

    if stats.total > 0 do
      pct = Float.round(stats.present / stats.total * 100, 1)
      "#{pct}%"
    else
      "N/A"
    end
  end
end
