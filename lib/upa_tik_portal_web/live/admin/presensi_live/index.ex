defmodule UpaTikPortalWeb.Admin.PresensiLive.Index do
  use UpaTikPortalWeb, :live_view

  alias UpaTikPortal.Recruitment.PresenceService
  alias UpaTikPortal.Recruitment.QrCodeService
  alias UpaTikPortal.Recruitment.InternshipParticipationService

  on_mount {UpaTikPortalWeb.UserAuth, :mount_current_user}

  @impl true
  def mount(_params, _session, socket) do
    today = UpaTikPortalWeb.Helpers.TimeHelper.today_wib()
    presences = PresenceService.list_by_date(today)
    interns = InternshipParticipationService.list_active_interns()

    # Kelompokkan berdasarkan lowongan
    grouped_interns = Enum.group_by(interns, & &1.internship_opening.title)

    {:ok,
     socket
     |> assign(:page_title, "Monitor Presensi & Scanner")
     |> assign(:today, today)
     |> assign(:scan_result, nil)
     |> assign(:selected_category, "Semua")
     |> assign(:show_manual_modal, false)
     |> assign(:manual_error, nil)
     |> assign(:search, "")
     |> assign(:opening, "")
     |> assign(:already_present_ids, [])
     |> stream(:presences, presences)}
  end

  @impl true
  def handle_event("set_mode", %{"mode" => mode}, socket) do
    {:noreply, assign(socket, :scan_mode, mode)}
  end

  @impl true
  def handle_event("open_manual_modal", _, socket) do
    today_presences = PresenceService.list_by_date(socket.assigns.today)
    already_present_ids = Enum.map(today_presences, & &1.participation_id)

    {:noreply, assign(socket, show_manual_modal: true, edit_presence: nil, manual_error: nil, already_present_ids: already_present_ids)}
  end

  @impl true
  def handle_event("close_manual_modal", _, socket) do
    {:noreply, assign(socket, show_manual_modal: false, manual_error: nil)}
  end

  @impl true
  def handle_event("select_category", %{"category" => cat}, socket) do
    {:noreply, assign(socket, :selected_category, cat)}
  end

  @impl true
  def handle_event("filter_presences", %{"search" => search, "opening" => opening}, socket) do
    presences = PresenceService.list_by_date(socket.assigns.today, search: search, opening: opening)

    {:noreply,
     socket
     |> assign(:search, search)
     |> assign(:opening, opening)
     |> stream(:presences, presences, reset: true)}
  end

  @impl true
  def handle_event("edit_presence", %{"id" => id}, socket) do
    presence = PresenceService.get_presence!(id)
    today_presences = PresenceService.list_by_date(socket.assigns.today)
    already_present_ids = Enum.map(today_presences, & &1.participation_id)

    {:noreply, assign(socket, show_manual_modal: true, edit_presence: presence, manual_error: nil, already_present_ids: already_present_ids)}
  end

  @impl true
  def handle_event("delete_presence", %{"id" => id}, socket) do
    presence = PresenceService.get_presence!(id)
    case PresenceService.delete_presence(presence) do
      {:ok, _} ->
        {:noreply, 
         socket 
         |> put_flash(:info, "Presensi berhasil dihapus.")
         |> stream_delete(:presences, presence)}
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Gagal menghapus presensi.")}
    end
  end

  @impl true
  def handle_event("save_manual", params, socket) do
    p_id = params["participation_id"]
    status = params["status"]
    notes = params["notes"]
    check_in = params["check_in"]
    check_out = params["check_out"]
    
    already_present? = is_nil(socket.assigns.edit_presence) and PresenceService.get_today(p_id) != nil
    
    if already_present? do
      {:noreply, assign(socket, :manual_error, "Gagal: Peserta ini sudah melakukan presensi hari ini.")}
    else
      if check_out != "" and (is_nil(check_in) or check_in == "") do
        {:noreply, assign(socket, :manual_error, "Gagal: Harus mengisi jam Check-In terlebih dahulu jika ingin mengisi Check-Out.")}
      else
        case PresenceService.set_manual_presence(p_id, socket.assigns.today, status, notes, check_in, check_out) do
          {:ok, presence} ->
            presence = PresenceService.get_presence!(presence.id) |> UpaTikPortal.Repo.preload(participation: [:user])
            {:noreply,
             socket
             |> put_flash(:info, "Presensi manual berhasil disimpan.")
             |> assign(show_manual_modal: false, manual_error: nil)
             |> stream_insert(:presences, presence, at: 0)}
          {:error, _changeset} ->
            {:noreply, assign(socket, :manual_error, "Gagal menyimpan presensi manual. Pastikan data valid.")}
        end
      end
    end
  end

  @impl true
  def handle_event("scan_success", %{"token" => token}, socket) do
    case QrCodeService.verify_token(token) do
      {:ok, participation_id} ->
        # Cek apakah dia mau check-in atau check-out
        today_presence = PresenceService.get_today(participation_id)

        if socket.assigns.scan_mode == "check_in" do
          if is_nil(today_presence) || is_nil(today_presence.check_in) do
            case PresenceService.check_in(participation_id) do
              {:ok, presence} ->
                # Ambil ulang data karena butuh preload user
                presence = PresenceService.get_presence!(presence.id) |> UpaTikPortal.Repo.preload(participation: [:user])
                {:reply, %{status: "ok"},
                 socket
                 |> put_flash(:info, "Berhasil Check-in: #{presence.participation.user.name}")
                 |> assign(:scan_result, {:ok, "Check-in berhasil untuk #{presence.participation.user.name}"})
                 |> stream_insert(:presences, presence, at: 0)}

              {:error, _} ->
                {:reply, %{status: "error"},
                 socket
                 |> assign(:scan_result, {:error, "Gagal Check-in. Coba lagi."})}
            end
          else
            {:reply, %{status: "error"},
             socket
             |> assign(:scan_result, {:error, "Gagal: Peserta ini sudah Check-in sebelumnya."})}
          end
        else
          # scan_mode == "check_out"
          if is_nil(today_presence) || is_nil(today_presence.check_in) do
            {:reply, %{status: "error"},
             socket
             |> assign(:scan_result, {:error, "Gagal: Peserta ini belum Check-in."})}
          else
            if not is_nil(today_presence.check_out) do
              {:reply, %{status: "error"},
               socket
               |> assign(:scan_result, {:error, "Gagal: Peserta ini sudah Check-out sebelumnya."})}
            else
              case PresenceService.check_out(participation_id) do
                {:ok, presence} ->
                  presence = PresenceService.get_presence!(presence.id) |> UpaTikPortal.Repo.preload(participation: [:user])
                  {:reply, %{status: "ok"},
                   socket
                   |> put_flash(:info, "Berhasil Check-out: #{presence.participation.user.name}")
                   |> assign(:scan_result, {:ok, "Check-out berhasil untuk #{presence.participation.user.name}"})
                   |> stream_insert(:presences, presence)}

                {:error, _} ->
                  {:reply, %{status: "error"},
                   socket
                   |> assign(:scan_result, {:error, "Gagal Check-out. Coba lagi."})}
              end
            end
          end
        end

      {:error, :invalid_or_expired_token} ->
        {:reply, %{status: "error"},
         socket
         |> assign(:scan_result, {:error, "QR Code tidak valid atau sudah kedaluwarsa!"})}
    end
  end

  defp status_label("present"), do: "Hadir"
  defp status_label("sick"), do: "Sakit"
  defp status_label("permit"), do: "Izin"
  defp status_label("absent"), do: "Alpha"
  defp status_label(_), do: "-"

  defp status_color("present"), do: "bg-green-100 text-green-700"
  defp status_color("sick"), do: "bg-blue-100 text-blue-700"
  defp status_color("permit"), do: "bg-yellow-100 text-yellow-700"
  defp status_color("absent"), do: "bg-red-100 text-red-700"
  defp status_color(_), do: "bg-gray-100 text-gray-600"
end
