defmodule UpaTikPortalWeb.Home.Magang.Logbook.Index do
  use UpaTikPortalWeb, :live_view

  on_mount {UpaTikPortalWeb.UserAuth, :mount_current_user}

  alias UpaTikPortal.Recruitment.InternshipParticipationService
  alias UpaTikPortal.Recruitment.WeeklyLogService

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    participation = InternshipParticipationService.get_latest_accepted_participation(user.id)

    if is_nil(participation) do
      {:ok,
       socket
       |> put_flash(:error, "Kamu tidak memiliki magang aktif atau riwayat magang.")
       |> push_navigate(to: ~p"/portal/magang")}
    else
      is_completed = participation.internship_opening.end_date && Date.compare(UpaTikPortalWeb.Helpers.TimeHelper.today_wib(), participation.internship_opening.end_date) == :gt
      logs = WeeklyLogService.list_by_participation(participation.id)

      {:ok,
       socket
       |> assign(:page_title, "Logbook Mingguan")
       |> assign(:participation, participation)
       |> assign(:is_completed, is_completed)
       |> stream(:logs, logs)}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    log = WeeklyLogService.get_weekly_log!(id)

    # Optional: Delete file from MinIO if necessary
    # In this case, we just delete the DB record
    case WeeklyLogService.delete_weekly_log(log) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Weekly log berhasil dihapus.")
         |> stream_delete(:logs, log)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Gagal menghapus weekly log.")}
    end
  end

  defp feedback_badge(nil), do: {"Belum ada feedback", "bg-orange-100 text-orange-700"}
  defp feedback_badge(_), do: {"Ada Feedback", "bg-green-100 text-green-700"}
end
