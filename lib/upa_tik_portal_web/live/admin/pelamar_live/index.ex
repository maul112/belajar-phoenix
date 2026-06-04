defmodule UpaTikPortalWeb.Admin.PelamarLive.Index do
  use UpaTikPortalWeb, :live_view
  alias UpaTikPortal.Recruitment.InternshipParticipationService

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Kelola Pelamar Magang")}
  end

  @impl true
  def handle_params(params, _url, socket) do
    page = String.to_integer(params["page"] || "1")
    search = params["search"]
    status = params["status"]
    
    per_page = 10
    opts = [search: search, status: status]
    total_count = InternshipParticipationService.count_internship_participations(opts)
    total_pages = max(1, ceil(total_count / per_page))
    
    # Pastikan page tidak out of bounds
    page = max(1, min(page, total_pages))

    participations = InternshipParticipationService.list_internship_participations_paginated(page, per_page, opts)

    {:noreply,
     socket
     |> assign(:participations, participations)
     |> assign(:page, page)
     |> assign(:total_pages, total_pages)
     |> assign(:search, search || "")
     |> assign(:status, status || "")}
  end

  @impl true
  def handle_event("filter", params, socket) do
    search = params["search"] || ""
    status = params["status"] || ""
    
    {:noreply, push_patch(socket, to: ~p"/admin/pelamar?page=1&search=#{search}&status=#{status}")}
  end

  # Fungsi kecil untuk mewarnai badge status
  defp status_badge("applied"), do: "bg-blue-100 text-blue-800"
  defp status_badge("accepted"), do: "bg-green-100 text-green-800"
  defp status_badge("rejected"), do: "bg-red-100 text-red-800"
  defp status_badge(_), do: "bg-gray-100 text-gray-800"
end
