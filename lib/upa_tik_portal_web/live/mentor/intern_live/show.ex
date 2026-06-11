defmodule UpaTikPortalWeb.Mentor.InternLive.Show do
  use UpaTikPortalWeb, :live_view

  on_mount {UpaTikPortalWeb.UserAuth, :mount_current_user}

  alias UpaTikPortal.Recruitment.InternshipParticipationService
  alias UpaTikPortal.Recruitment.WeeklyLogService
  alias UpaTikPortal.Recruitment.PresenceService
  alias UpaTikPortal.Recruitment.InternComplaintService

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    user = socket.assigns.current_user
    participation = InternshipParticipationService.get_internship_participation!(id)

    # Guard: mentor hanya boleh akses intern yang dia bimbing
    if to_string(participation.mentor_id) != to_string(user.id) do
      {:ok,
       socket
       |> put_flash(:error, "Kamu tidak memiliki akses ke intern ini.")
       |> push_navigate(to: ~p"/mentor")}
    else
      logs = WeeklyLogService.list_by_participation(id)
      presences = PresenceService.list_by_participation(id)
      complaints = InternComplaintService.list_by_participation(id)
      presence_stats = PresenceService.stats(id)

      {:ok,
       socket
       |> assign(:page_title, "Detail Intern – #{participation.user.name}")
       |> assign(:participation, participation)
       |> assign(:presence_stats, presence_stats)
       |> assign(:editing_log_id, nil)
       |> assign(:feedback_text, "")
       |> assign(:active_tab, :logbook)
       |> stream(:logs, logs)
       |> stream(:presences, presences)
       |> stream(:complaints, complaints)}
    end
  end

  @impl true
  def handle_event("switch_tab", %{"tab" => "logbook"}, socket), do: {:noreply, assign(socket, :active_tab, :logbook)}
  def handle_event("switch_tab", %{"tab" => "presensi"}, socket), do: {:noreply, assign(socket, :active_tab, :presensi)}
  def handle_event("switch_tab", %{"tab" => "complaints"}, socket), do: {:noreply, assign(socket, :active_tab, :complaints)}
  def handle_event("switch_tab", _, socket), do: {:noreply, socket}

  @impl true
  def handle_event("edit_feedback", %{"log_id" => log_id}, socket) do
    log = WeeklyLogService.get_weekly_log!(log_id)

    {:noreply,
     socket
     |> stream_insert(:logs, log)
     |> assign(:editing_log_id, log_id)
     |> assign(:feedback_text, log.feedback || "")}
  end

  @impl true
  def handle_event("cancel_feedback", %{"log_id" => log_id}, socket) do
    log = WeeklyLogService.get_weekly_log!(log_id)
    {:noreply,
     socket
     |> stream_insert(:logs, log)
     |> assign(:editing_log_id, nil)}
  end

  @impl true
  def handle_event("save_feedback", %{"log_id" => log_id, "feedback" => feedback}, socket) do
    log = WeeklyLogService.get_weekly_log!(log_id)

    case WeeklyLogService.give_feedback(log, feedback) do
      {:ok, updated_log} ->
        {:noreply,
         socket
         |> stream_insert(:logs, updated_log)
         |> assign(:editing_log_id, nil)
         |> assign(:feedback_text, "")
         |> put_flash(:info, "Feedback berhasil disimpan.")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Gagal menyimpan feedback.")}
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

  defp presence_status_color("present"), do: "bg-green-100 text-green-700"
  defp presence_status_color("sick"), do: "bg-blue-100 text-blue-700"
  defp presence_status_color("permit"), do: "bg-yellow-100 text-yellow-700"
  defp presence_status_color("absent"), do: "bg-red-100 text-red-700"
  defp presence_status_color(_), do: "bg-gray-100 text-gray-600"

  defp presence_status_label("present"), do: "Hadir"
  defp presence_status_label("sick"), do: "Sakit"
  defp presence_status_label("permit"), do: "Izin"
  defp presence_status_label("absent"), do: "Alpha"
  defp presence_status_label(_), do: "-"

  defp category_color("Fasilitas"), do: "bg-purple-100 text-purple-700"
  defp category_color("Teknis"), do: "bg-blue-100 text-blue-700"
  defp category_color("Lingkungan"), do: "bg-green-100 text-green-700"
  defp category_color(_), do: "bg-slate-100 text-slate-700"
end
