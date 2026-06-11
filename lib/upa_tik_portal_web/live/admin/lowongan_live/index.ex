defmodule UpaTikPortalWeb.Admin.LowonganLive.Index do
  use UpaTikPortalWeb, :live_view
  alias UpaTikPortal.Recruitment.InternshipOpeningService
  alias UpaTikPortal.Recruitment.InternshipOpening
  alias UpaTikPortalWeb.Admin.LowonganLive.FormComponent

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> assign(:search, "")
      |> assign(:status, "")
      |> assign(:page, 1)
      |> assign(:total_pages, 1)
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :index, params) do
    page = String.to_integer(params["page"] || "1")
    search = params["search"] || ""
    status = params["status"] || ""

    is_active = case status do
      "true" -> true
      "false" -> false
      _ -> nil
    end

    per_page = 10
    opts = [search: search, is_active: is_active, sort_by: [desc: :inserted_at]]
    total_count = InternshipOpeningService.count_internship_openings(opts)
    total_pages = max(1, ceil(total_count / per_page))
    page = max(1, min(page, total_pages))

    lowongans = InternshipOpeningService.list_internship_openings_paginated(page, per_page, opts)

    socket
    |> assign(:page_title, "Daftar Lowongan")
    |> assign(:opening, nil)
    |> assign(:any_lowongan?, total_count > 0)
    |> assign(:search, search)
    |> assign(:status, status)
    |> assign(:page, page)
    |> assign(:total_pages, total_pages)
    |> stream(:lowongans, lowongans, reset: true)
  end

  @impl true
  def handle_event("filter", %{"search" => search, "status" => status}, socket) do
    {:noreply, push_patch(socket, to: ~p"/admin/lowongan?page=1&search=#{search}&status=#{status}")}
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



  @impl true
  def handle_info({FormComponent, {:saved, opening}}, socket) do
    {:noreply, stream_insert(socket, :lowongans, opening, at: 0)}
  end
end
