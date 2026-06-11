defmodule UpaTikPortalWeb.Admin.InternLive.Show do
  use UpaTikPortalWeb, :live_view

  alias UpaTikPortal.Accounts
  alias UpaTikPortal.Recruitment.InternshipParticipationService
  alias UpaTikPortal.Recruitment.WeeklyLogService
  alias UpaTikPortal.Recruitment.PresenceService
  alias UpaTikPortal.Recruitment.InternComplaintService

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    participation = InternshipParticipationService.get_internship_participation!(id)
    mentors = Accounts.list_mentors()
    logs = WeeklyLogService.list_by_participation(id)
    presences = PresenceService.list_by_participation(id)
    complaints = InternComplaintService.list_by_participation(id)
    presence_stats = PresenceService.stats(id)

    {:ok,
     socket
     |> assign(:page_title, "Detail Intern – #{participation.user.name}")
     |> assign(:participation, participation)
     |> assign(:mentors, mentors)
     |> assign(:selected_mentor_id, participation.mentor_id && to_string(participation.mentor_id))
     |> assign(:presence_stats, presence_stats)
     |> assign(:active_tab, :logbook)
     |> stream(:logs, logs)
     |> stream(:presences, presences)
     |> stream(:complaints, complaints)}
  end

  @impl true
  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :active_tab, String.to_existing_atom(tab))}
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

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Gagal mengubah mentor.")}
    end
  end

  @impl true
  def handle_event("resolve_complaint", %{"id" => id}, socket) do
    complaint = InternComplaintService.get_complaint!(id)

    case InternComplaintService.resolve_complaint(complaint, !complaint.is_resolved) do
      {:ok, updated} ->
        {:noreply,
         socket
         |> stream_insert(:complaints, updated)
         |> put_flash(:info, "Status keluhan diperbarui.")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Gagal mengubah status.")}
    end
  end

  defp status_badge("present"), do: {"Hadir", "bg-green-100 text-green-700"}
  defp status_badge("sick"), do: {"Sakit", "bg-blue-100 text-blue-700"}
  defp status_badge("permit"), do: {"Izin", "bg-yellow-100 text-yellow-700"}
  defp status_badge("absent"), do: {"Alpha", "bg-red-100 text-red-700"}
  defp status_badge(_), do: {"-", "bg-gray-100 text-gray-600"}

  defp category_color("Fasilitas"), do: "bg-purple-100 text-purple-700"
  defp category_color("Teknis"), do: "bg-blue-100 text-blue-700"
  defp category_color("Lingkungan"), do: "bg-green-100 text-green-700"
  defp category_color(_), do: "bg-slate-100 text-slate-700"
end
