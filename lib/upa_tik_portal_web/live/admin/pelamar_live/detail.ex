defmodule UpaTikPortalWeb.Admin.PelamarLive.Detail do
  use UpaTikPortalWeb, :live_view

  alias UpaTikPortal.Accounts
  alias UpaTikPortal.Recruitment.InternshipParticipationService

  on_mount {UpaTikPortalWeb.UserAuth, :mount_current_user}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    participation = InternshipParticipationService.get_internship_participation!(id)
    mentors = Accounts.list_mentors()
    audit_logs = UpaTikPortal.Recruitment.AuditLogService.list_by_participation(id)

    {:ok,
     socket
     |> assign(:page_title, "Detail Pelamar – #{participation.user.name}")
     |> assign(:participation, participation)
     |> assign(:mentors, mentors)
     |> assign(:audit_logs, audit_logs)
     |> assign(:selected_mentor_id, participation.mentor_id && to_string(participation.mentor_id))}
  end

  @impl true
  def handle_event("update_status", %{"status" => status}, socket) do
    participation = socket.assigns.participation
    admin_id = socket.assigns.current_user.id

    case InternshipParticipationService.update_status(participation, status, admin_id) do
      {:ok, updated} ->
        updated = InternshipParticipationService.get_internship_participation!(updated.id)

        {:noreply,
         socket
         |> assign(:participation, updated)
         |> put_flash(:info, "Status lamaran diperbarui menjadi \"#{status_label(status)}\".")}

      {:error, reason} when is_binary(reason) ->
        {:noreply, put_flash(socket, :error, reason)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Gagal mengubah status.")}
    end
  end

  @impl true
  def handle_event("assign_mentor", %{"mentor_id" => mentor_id}, socket) do
    participation = socket.assigns.participation
    mentor_id = if mentor_id == "", do: nil, else: mentor_id

    case InternshipParticipationService.assign_mentor(participation, mentor_id) do
      {:ok, updated} ->
        updated = InternshipParticipationService.get_internship_participation!(updated.id)

        {:noreply,
         socket
         |> assign(:participation, updated)
         |> assign(:selected_mentor_id, mentor_id && to_string(mentor_id))
         |> put_flash(:info, "Mentor berhasil diperbarui.")}

      {:error, reason} when is_binary(reason) ->
        {:noreply, put_flash(socket, :error, reason)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Gagal mengubah mentor.")}
    end
  end

  defp status_label("applied"), do: "Menunggu Review"
  defp status_label("interview"), do: "Tahap Interview"
  defp status_label("accepted"), do: "Diterima"
  defp status_label("rejected"), do: "Ditolak"
  defp status_label(_), do: "-"

  defp status_color("applied"), do: "bg-blue-100 text-blue-700"
  defp status_color("interview"), do: "bg-yellow-100 text-yellow-700"
  defp status_color("accepted"), do: "bg-green-100 text-green-700"
  defp status_color("rejected"), do: "bg-red-100 text-red-700"
  defp status_color(_), do: "bg-gray-100 text-gray-600"
end
