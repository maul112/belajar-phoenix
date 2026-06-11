defmodule UpaTikPortalWeb.Mentor.DashboardLive do
  use UpaTikPortalWeb, :live_view

  on_mount {UpaTikPortalWeb.UserAuth, :mount_current_user}

  alias UpaTikPortal.Recruitment.InternshipParticipationService
  alias UpaTikPortal.Recruitment.PresenceService
  alias UpaTikPortal.Recruitment.WeeklyLogService
  alias UpaTikPortal.Recruitment.InternComplaintService

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    interns = fetch_interns(user.id, "")

    {:ok,
     socket
     |> assign(:page_title, "Dashboard Mentor")
     |> assign(:search, "")
     |> stream(:interns, interns)}
  end

  @impl true
  def handle_event("filter", %{"search" => search}, socket) do
    user = socket.assigns.current_user
    interns = fetch_interns(user.id, search)
    
    {:noreply,
     socket
     |> assign(:search, search)
     |> stream(:interns, interns, reset: true)}
  end

  defp fetch_interns(mentor_id, search) do
    InternshipParticipationService.list_by_mentor(mentor_id, search: search)
    |> Enum.map(fn intern ->
      stats = PresenceService.stats(intern.id)
      log_stats = WeeklyLogService.stats(intern.id)
      complaint_stats = InternComplaintService.stats(intern.id)
      
      intern
      |> Map.put(:presence_stats, stats)
      |> Map.put(:log_stats, log_stats)
      |> Map.put(:complaint_stats, complaint_stats)
    end)
  end

  defp presence_today(participation_id) do
    PresenceService.get_today(participation_id)
  end
end
