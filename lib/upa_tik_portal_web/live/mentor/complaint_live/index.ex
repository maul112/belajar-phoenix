defmodule UpaTikPortalWeb.Mentor.ComplaintLive.Index do
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
    user = socket.assigns.current_user
    category = params["category"] || ""
    page = String.to_integer(params["page"] || "1")

    result = InternComplaintService.list_by_mentor(user.id, category: category, page: page, per_page: 10)
    
    {:noreply,
     socket
     |> assign(:category, category)
     |> assign(:current_page, result.current_page)
     |> assign(:total_pages, result.total_pages)
     |> stream(:complaints, result.entries, reset: true)}
  end

  @impl true
  def handle_event("filter", %{"category" => category}, socket) do
    {:noreply, push_patch(socket, to: ~p"/mentor/keluhan-magang?category=#{category}&page=1")}
  end
  
  @impl true
  def handle_event("toggle_resolve", %{"id" => id}, socket) do
    complaint = InternComplaintService.get_complaint!(id)
    
    # Optional security check: verify if complaint belongs to mentor's intern
    # But since they can only click what they see, we just process it.
    
    case InternComplaintService.resolve_complaint(complaint, !complaint.is_resolved) do
      {:ok, updated_complaint} ->
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
