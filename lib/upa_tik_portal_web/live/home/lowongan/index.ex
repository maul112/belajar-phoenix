defmodule UpaTikPortalWeb.Home.Lowongan.Index do
  use UpaTikPortalWeb, :live_view
  alias UpaTikPortal.Recruitment.InternshipOpeningService

  on_mount {UpaTikPortalWeb.UserAuth, :mount_current_user}

  @impl true
  def mount(_params, _session, socket) do
    lowongans = InternshipOpeningService.list_internship_openings(is_active: true, sort_by: [asc: :quota])
    user = socket.assigns.current_user
    divisions = UpaTikPortal.Recruitment.DivisionService.list_divisions()

    {:ok,
     socket
     |> assign(:page_title, "Cari Lowongan Magang")
     |> assign(:any_lowongan?, lowongans != [])
     |> assign(:user, user)
     |> assign(:divisions, divisions)
     |> assign(:search_query, "")
     |> assign(:division_id, "")
     |> stream(:lowongans, lowongans)}
  end

  @impl true
  def handle_event("search", params, socket) do
    query = params["query"] || ""
    division_id = params["division_id"] || ""
    
    # Implementasi pencarian sederhana
    lowongans = InternshipOpeningService.list_internship_openings(
      is_active: true, 
      search: query, 
      division_id: division_id,
      sort_by: [asc: :quota]
    )

    {:noreply,
     socket
     |> assign(:any_lowongan?, lowongans != [])
     |> assign(:search_query, query)
     |> assign(:division_id, division_id)
     |> stream(:lowongans, lowongans, reset: true)}
  end
end
