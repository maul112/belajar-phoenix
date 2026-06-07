defmodule UpaTikPortalWeb.Home.Ajukan.Index do
  use UpaTikPortalWeb, :live_view

  alias UpaTikPortal.Requests

  @max_file_size 5_000_000

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    user = UpaTikPortal.Accounts.get_user!(user_id)

    socket =
      socket
      |> assign(page_title: "Pengajuan Bermasalah – UPA TIK Portal")
      |> assign(current_user: user)
      |> assign(request_type: "aktivasi")
      |> assign(nim: "")
      |> assign(full_name: "")
      |> assign(email_requested: "")
      |> assign(errors: %{})
      |> assign(submitted: false)
      |> allow_upload(:ktm_photo,
        accept: ~w(.jpg .jpeg .png .webp),
        max_entries: 1,
        max_file_size: @max_file_size
      )

    {:ok, socket}
  end

  def handle_event("set_type", %{"type" => type}, socket) do
    {:noreply, assign(socket, request_type: type)}
  end

  def handle_event("update_field", %{"_target" => ["ktm_photo"]}, socket) do
    # Ignore file changes in this handler; LiveView handles @uploads automatically.
    {:noreply, socket}
  end

  def handle_event("update_field", params, socket) do
    # Phoenix sends %{"field_name" => "value", "_target" => ["field_name"]}
    field_name = List.first(params["_target"])
    value = params[field_name]

    if field_name do
      {:noreply, assign(socket, String.to_existing_atom(field_name), value)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :ktm_photo, ref)}
  end


  def handle_event("submit", _params, socket) do
    user = socket.assigns.current_user

    # Upload foto ke MinIO jika ada, tapi tidak wajib berhasil
    ktm_url =
      try do
        case consume_uploaded_entries(socket, :ktm_photo, &save_upload/2) do
          [{:ok, url} | _] -> url
          [url | _] when is_binary(url) -> url
          _ -> nil
        end
      rescue
        _ -> nil
      end

    attrs = %{
      "request_type" => socket.assigns.request_type,
      "nim" => socket.assigns.nim,
      "full_name" => socket.assigns.full_name,
      "email_requested" => socket.assigns.email_requested,
      "ktm_photo_url" => ktm_url
    }

    case Requests.create_request(user.id, attrs) do
      {:ok, _request} ->
        {:noreply,
         socket
         |> assign(submitted: true)
         |> put_flash(:info, "Pengajuan berhasil dikirim!")}

      {:error, changeset} ->
        errors =
          Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)

        {:noreply, assign(socket, errors: errors)}
    end
  end

  def handle_event("reset", _params, socket) do
    {:noreply,
     socket
     |> assign(submitted: false, nim: "", full_name: "", email_requested: "", errors: %{})}
  end

  defp save_upload(%{path: tmp_path}, entry) do
    ext = Path.extname(entry.client_name)
    filename = "#{:crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)}#{ext}"
    bucket = Application.get_env(:waffle, :bucket, "upa-tik-uploads")

    content_type = case String.downcase(ext) do
      ".jpg" -> "image/jpeg"
      ".jpeg" -> "image/jpeg"
      ".png" -> "image/png"
      ".webp" -> "image/webp"
      _ -> "application/octet-stream"
    end

    try do
      file_content = File.read!(tmp_path)

      case ExAws.S3.put_object(bucket, filename, file_content, content_type: content_type)
           |> ExAws.request() do
        {:ok, _} ->
          s3_config = Application.get_env(:ex_aws, :s3, [])
          host = Keyword.get(s3_config, :host, System.get_env("MINIO_HOST", "127.0.0.1"))
          port = Keyword.get(s3_config, :port, (System.get_env("MINIO_PORT") || "9000") |> String.to_integer())
          {:ok, "http://#{host}:#{port}/#{bucket}/#{filename}"}

        {:error, reason} ->
          # MinIO gagal - simpan ke folder lokal sebagai fallback
          IO.warn("[MinIO Upload GAGAL] Reason: #{inspect(reason)}")
          uploads_dir = Path.join(:code.priv_dir(:upa_tik_portal), "static/uploads")
          File.mkdir_p!(uploads_dir)

          dest = Path.join(uploads_dir, filename)
          File.cp!(tmp_path, dest)
          {:ok, "/uploads/#{filename}"}
      end
    rescue
      _ ->
        # Jika semua gagal, kembalikan nil (request tetap tersimpan tanpa foto)
        {:ok, nil}
    end
  end

  defp upload_error_to_string(:too_large), do: "File terlalu besar (maks. 5MB)"
  defp upload_error_to_string(:too_many_files), do: "Hanya boleh 1 file"
  defp upload_error_to_string(:not_accepted), do: "Format tidak didukung (JPG/PNG/WEBP)"
end
