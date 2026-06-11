defmodule UpaTikPortalWeb.Home.Magang.Logbook.Edit do
  use UpaTikPortalWeb, :live_view

  on_mount {UpaTikPortalWeb.UserAuth, :mount_current_user}

  alias UpaTikPortal.Recruitment.InternshipParticipationService
  alias UpaTikPortal.Recruitment.WeeklyLogService
  alias UpaTikPortal.Recruitment.WeeklyLog

  @impl true
  def mount(%{"id" => log_id}, _session, socket) do
    user = socket.assigns.current_user
    participation = InternshipParticipationService.get_active_participation_by_user(user.id)

    if is_nil(participation) do
      {:ok,
       socket
       |> put_flash(:error, "Kamu tidak memiliki magang aktif.")
       |> push_navigate(to: ~p"/portal/magang")}
    else
      log = WeeklyLogService.get_weekly_log!(log_id)

      if log.participation_id != participation.id do
        {:ok,
         socket
         |> put_flash(:error, "Akses ditolak.")
         |> push_navigate(to: ~p"/portal/magang/logbook")}
      else
        form = WeeklyLog.changeset(log, %{}) |> to_form()

        {:ok,
         socket
         |> assign(:page_title, "Edit Weekly Log")
         |> assign(:participation, participation)
         |> assign(:log, log)
         |> assign(:form, form)
         |> allow_upload(:logbook_pdf, accept: ~w(.pdf), max_entries: 1, max_file_size: 5_000_000)}
      end
    end
  end

  @impl true
  def handle_event("validate", %{"weekly_log" => params}, socket) do
    form =
      socket.assigns.log
      |> WeeklyLog.changeset(params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, :form, form)}
  end

  @impl true
  def handle_event("save", %{"weekly_log" => params}, socket) do
    log = socket.assigns.log

    case consume_file(socket, :logbook_pdf) do
      {:ok, pdf_url} ->
        # If no new file uploaded, keep the old pdf_url
        final_params = if pdf_url, do: Map.put(params, "pdf_url", pdf_url), else: params

        case WeeklyLogService.update_weekly_log(log, final_params) do
          {:ok, _log} ->
            {:noreply,
             socket
             |> put_flash(:info, "Weekly log berhasil diperbarui! 📝")
             |> push_navigate(to: ~p"/portal/magang/logbook")}

          {:error, changeset} ->
            {:noreply, assign(socket, :form, to_form(changeset))}
        end

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Gagal mengunggah PDF Logbook.")
         |> assign(:form, to_form(params))}
    end
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :logbook_pdf, ref)}
  end

  defp consume_file(socket, upload_key) do
    if Enum.empty?(socket.assigns.uploads[upload_key].entries) do
      {:ok, nil}
    else
      bucket = Application.get_env(:waffle, :bucket)
      uploaded_results =
        consume_uploaded_entries(socket, upload_key, fn %{path: path}, entry ->
          filename = "#{Ecto.UUID.generate()}-#{entry.client_name}"
          file_content = File.read!(path)
          content_type = entry.client_type

          case ExAws.S3.put_object(
                bucket,
                filename,
                file_content,
                content_type: content_type
              )
              |> ExAws.request() do
            {:ok, _response} ->
              url = "http://localhost:9000/#{bucket}/#{filename}"
              {:ok, {:ok, url}}

            {:error, reason} ->
              IO.warn("[MinIO Upload GAGAL] Reason: #{inspect(reason)}")
              {:ok, {:error, reason}}
          end
        end)

      case List.first(uploaded_results) do
        nil -> {:ok, nil}
        result -> result
      end
    end
  end

  defp error_to_string(:too_large), do: "File terlalu besar (Maks 5MB)"
  defp error_to_string(:too_many_files), do: "Anda hanya bisa mengunggah 1 file"
  defp error_to_string(:not_accepted), do: "Format file tidak diterima (Harus PDF)"
  defp error_to_string(err), do: inspect(err)
end
