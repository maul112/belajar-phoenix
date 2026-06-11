defmodule UpaTikPortalWeb.Admin.ComplaintLive.Index do
  use UpaTikPortalWeb, :live_view

  alias UpaTikPortal.Recruitment.InternComplaintService

  on_mount {UpaTikPortalWeb.UserAuth, :mount_current_user}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Keluhan Magang")
     |> assign(:category, "")
     |> assign(:current_page, 1)
     |> assign(:total_pages, 1)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    category = params["category"] || ""
    page = String.to_integer(params["page"] || "1")

    result = InternComplaintService.list_all(category: category, page: page, per_page: 10)
    
    {:noreply,
     socket
     |> assign(:category, category)
     |> assign(:current_page, result.current_page)
     |> assign(:total_pages, result.total_pages)
     |> stream(:complaints, result.entries, reset: true)}
  end

  @impl true
  def handle_event("filter", %{"category" => category}, socket) do
    {:noreply, push_patch(socket, to: ~p"/admin/keluhan-magang?category=#{category}&page=1")}
  end

  @impl true
  def handle_event("toggle_resolve", %{"id" => id}, socket) do
    complaint = InternComplaintService.get_complaint!(id)
    
    case InternComplaintService.resolve_complaint(complaint, !complaint.is_resolved) do
      {:ok, updated_complaint} ->
        # Reload participation so the user data is available in the view
        updated_complaint = UpaTikPortal.Repo.preload(updated_complaint, participation: [:user])
        {:noreply,
         socket
         |> put_flash(:info, "Status keluhan berhasil diperbarui.")
         |> stream_insert(:complaints, updated_complaint)}
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Gagal memperbarui status keluhan.")}
    end
  end
end
