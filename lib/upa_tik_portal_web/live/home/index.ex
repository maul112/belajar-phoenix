defmodule UpaTikPortalWeb.Home.Index do
  use UpaTikPortalWeb, :live_view

  on_mount {UpaTikPortalWeb.UserAuth, :mount_current_user}

  # 1. Inisialisasi Data
  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    openings = UpaTikPortal.Recruitment.InternshipOpeningService.list_top_urgent_openings(3)

    {:ok,
     socket
     |> assign(:page_title, "Dashboard Portal")
     |> assign(user: user)
     |> assign(:urgent_openings, openings)}
  end

  # 2. Reaksi Terhadap URL (Live Action)
  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  # 3. Menangani Interaksi User (Event)
  @impl true
  def handle_event("delete", %{"id" => _id}, socket) do
    {:noreply, socket}
  end
end
