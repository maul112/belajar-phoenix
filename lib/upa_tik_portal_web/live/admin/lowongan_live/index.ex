defmodule UpaTikPortalWeb.Admin.LowonganLive.Index do
  use UpaTikPortalWeb, :live_view
  alias UpaTikPortal.Recruitment.InternshipOpeningService
  alias UpaTikPortal.Recruitment.InternshipOpening
  alias UpaTikPortalWeb.Admin.LowonganLive.FormComponent

  @impl true
  def mount(_params, _session, socket) do
    lowongans = InternshipOpeningService.list_internship_openings()
    {:ok,
      socket
      |> assign(:any_lowongan?, lowongans != [])
      |> assign(:search, "")
      |> stream(:lowongans, lowongans)
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("filter", %{"search" => search}, socket) do
    lowongans = InternshipOpeningService.list_internship_openings(search: search)
    {:noreply,
     socket
     |> assign(:any_lowongan?, lowongans != [])
     |> assign(:search, search)
     |> stream(:lowongans, lowongans, reset: true)}
  end

  def apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Lowongan")
    |> put_flash(:info, "Fitur edit masih dalam pengembangan. Silakan buat lowongan baru untuk saat ini.")
    |> assign(:opening, InternshipOpeningService.get_internship_opening!(id))
  end

  def apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Tambah Lowongan Baru")
    |> assign(:opening, %InternshipOpening{})
  end

  def apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Daftar Lowongan")
    |> assign(:opening, nil)
  end

  @impl true
  def handle_info({FormComponent, {:saved, opening}}, socket) do
    {:noreply, stream_insert(socket, :lowongans, opening, at: 0)}
  end
end
