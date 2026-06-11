defmodule UpaTikPortalWeb.Admin.InternLive.Index do
  use UpaTikPortalWeb, :live_view

  alias UpaTikPortal.Recruitment.InternshipParticipationService
  alias UpaTikPortal.Recruitment.PresenceService

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Daftar Intern Aktif")
     |> assign(:search, "")
     |> assign(:current_page, 1)
     |> assign(:total_pages, 1)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    search = params["search"] || ""
    page = String.to_integer(params["page"] || "1")

    result = InternshipParticipationService.list_active_interns(search: search, page: page, per_page: 10)

    {:noreply,
     socket
     |> assign(:search, search)
     |> assign(:current_page, result.current_page)
     |> assign(:total_pages, result.total_pages)
     |> stream(:interns, result.entries, reset: true)}
  end

  @impl true
  def handle_event("filter", %{"search" => search}, socket) do
    {:noreply, push_patch(socket, to: ~p"/admin/intern?search=#{search}&page=1")}
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
