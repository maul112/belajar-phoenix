defmodule UpaTikPortalWeb.Home.Lowongan.Ajukan do
  use UpaTikPortalWeb, :live_view
  alias UpaTikPortal.Recruitment.InternshipParticipationService
  alias UpaTikPortal.Recruitment.InternshipParticipation
  alias UpaTikPortal.Recruitment.InternshipOpeningService

  on_mount {UpaTikPortalWeb.UserAuth, :mount_current_user}

  @max_file_size 5_000_000

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    changeset = InternshipParticipationService.change_internship_participation(%InternshipParticipation{})
    opening = InternshipOpeningService.get_internship_opening!(id)
    user = socket.assigns.current_user

    socket =
      socket
      |> allow_upload(:cv,
        accept: ~w(.pdf),
        max_entries: 1,
        max_file_size: @max_file_size
      )
      |> allow_upload(:surat_pengantar,
        accept: ~w(.pdf),
        max_entries: 1,
        max_file_size: @max_file_size
      )
      |> allow_upload(:transkrip,
        accept: ~w(.pdf),
        max_entries: 1,
        max_file_size: @max_file_size
      )
      |> allow_upload(:portfolio_file,
        accept: ~w(.pdf .ppt .pptx),
        max_entries: 1,
        max_file_size: @max_file_size
      )

    {:ok,
     socket
     |> assign(:page_title, opening.title)
     |> assign(:opening, opening)
     |> assign(:user, user)
     |> assign(:portfolio_mode, "link")
     |> assign(:form, to_form(changeset))
     |> assign(:has_applied, false)}
  end

  @impl true
  def handle_event("validate", %{"internship_participation" => params}, socket) do
    # IO.inspect(socket.assigns.uploads, label: "Current Uploads in Socket")
    changeset =
      %InternshipParticipation{}
      |> InternshipParticipationService.change_internship_participation(params)
      |> validate_file_presence(:cv_url, socket.assigns.uploads.cv.entries)
      |> validate_file_presence(:surat_pengantar_url, socket.assigns.uploads.surat_pengantar.entries)
      |> validate_file_presence(:transkrip_nilai_url, socket.assigns.uploads.transkrip.entries)
      |> validate_portfolio_presence(socket.assigns.portfolio_mode, socket.assigns.uploads.portfolio_file.entries)
      |> Map.put(:action, :validate)
    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl true
  def handle_event("change_portfolio_mode", %{"mode" => mode}, socket) do
    {:noreply,
    assign(socket, :portfolio_mode, mode)}
  end

  @impl true
  def handle_event("save_application", %{"internship_participation" => params}, socket) do
    user_id = socket.assigns.current_user.id
    opening_id = socket.assigns.opening.id
    portfolio_mode = socket.assigns.portfolio_mode # Ambil mode portofolio saat ini

    final_params = params
      |> Map.put("user_id", user_id)
      |> Map.put("opening_id", opening_id)

    # 1. Ambil data antrean file dari socket uploads
    cv_entries = socket.assigns.uploads.cv.entries
    surat_entries = socket.assigns.uploads.surat_pengantar.entries
    transkrip_entries = socket.assigns.uploads.transkrip.entries
    portfolio_file_entries = socket.assigns.uploads.portfolio_file.entries

    # 2. Lakukan Pre-Validasi sebelum file benar-benar di-upload/di-consume
    # Menggunakan fungsi change_internship_participation dari service Anda
    changeset =
      %UpaTikPortal.Recruitment.InternshipParticipation{}
      |> InternshipParticipationService.change_internship_participation(final_params)
      |> validate_file_presence(:cv_url, cv_entries)
      |> validate_file_presence(:surat_pengantar_url, surat_entries)
      |> validate_file_presence(:transkrip_nilai_url, transkrip_entries)
      |> validate_portfolio_presence(portfolio_mode, portfolio_file_entries)
      |> Map.put(:action, :insert) # Memaksa error langsung muncul di UI form

    if changeset.valid? do
      # --- PRE-FLIGHT CHECK MINIO ---
      # Memastikan server MinIO hidup sebelum memproses/mengonsumsi file,
      # sehingga jika MinIO mati, antrean file di UI tidak hilang (tidak di-consume).
      bucket = Application.get_env(:waffle, :bucket)
      case ExAws.S3.head_bucket(bucket) |> ExAws.request() do
        {:error, _reason} ->
          {:noreply,
           socket
           |> put_flash(:error, "Gagal terhubung ke layanan penyimpanan file (Server MinIO mati). File Anda masih tersimpan di form, silakan coba lagi nanti.")
           |> assign(:form, to_form(changeset))}

        {:ok, _} ->
          # --- JIKA FORM VALID & MINIO HIDUP: PROSES UPLOAD NYATA DIMULAI ---
          with {:ok, cv_url} <- consume_file(socket, :cv),
               {:ok, surat_url} <- consume_file(socket, :surat_pengantar),
               {:ok, nilai_} <- consume_file(socket, :transkrip),
               {:ok, portfolio_url} <- (if portfolio_mode == "file", do: consume_file(socket, :portfolio_file), else: {:ok, Map.get(final_params, "portfolio_url")}) do

            # Gabungkan URL hasil upload ke parameter untuk disimpan ke database
            completed_params =
              final_params
              |> Map.put("cv_url", cv_url)
              |> Map.put("surat_pengantar_url", surat_url)
              |> Map.put("transkrip_nilai_url", nilai_)
              |> Map.put("portfolio_url", portfolio_url)

            # Kirim parameter yang sudah lengkap ke Service untuk disimpan
            case InternshipParticipationService.create_internship_participation(completed_params) do
              {:ok, participation} ->
                # Ambil data lengkap participation beserta assoc (user, internship_opening)
                participation = InternshipParticipationService.get_internship_participation!(participation.id)

                Task.start(fn ->
                  email = UpaTikPortal.Emails.internship_status_email(participation)
                  deliver_now(email)
                end)

                {:noreply,
                socket
                |> put_flash(:info, "Lamaran berhasil dikirim! Silakan periksa email Anda.")
                |> push_navigate(to: ~p"/portal/lowongan")}

              {:error, :quota_full} ->
                {:noreply,
                socket
                |> put_flash(:error, "Maaf, kuota untuk lowongan ini sudah penuh!")
                |> push_navigate(to: ~p"/portal/lowongan")}

              {:error, :already_applied} ->
                {:noreply,
                socket
                |> put_flash(:error, "Kamu sudah melamar di lowongan ini sebelumnya.")
                |> push_navigate(to: ~p"/portal/lowongan")}

              {:error, :overlap_active_internship} ->
                {:noreply,
                socket
                |> put_flash(:error, "Maaf, tanggal magang ini bentrok dengan magang kamu yang sedang aktif.")
                |> push_navigate(to: ~p"/portal/lowongan")}

              {:error, %Ecto.Changeset{} = db_changeset} ->
                {:noreply, assign(socket, :form, to_form(%{db_changeset | action: :insert}))}
            end
          else
            {:error, _reason} ->
              # Jika terjadi error tidak terduga saat proses put_object
              {:noreply,
               socket
               |> put_flash(:error, "Gagal mengunggah file karena gangguan koneksi. Silakan ulangi.")
               |> assign(:form, to_form(changeset))}
          end
      end
    else
      # --- JIKA FORM TIDAK VALID: JANGAN UPLOAD APAPUN ---
      # File CV/Surat tidak hilang dari browser, error muncul instan murni tanpa delay
      {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  # --- Fungsi Helper Tambahan (Letakkan di bawah handle_event atau akhir file .ex) ---
  
  defp error_to_string(:too_large), do: "Ukuran file terlalu besar (maksimal 5MB)"
  defp error_to_string(:not_accepted), do: "Tipe file tidak valid"
  defp error_to_string(:too_many_files), do: "Anda memilih terlalu banyak file"
  defp error_to_string(_), do: "Terjadi kesalahan saat mengunggah"


  defp validate_file_presence(changeset, field, entries) do
    has_error? = Keyword.has_key?(changeset.errors, field)
    if not has_error? and Enum.empty?(entries) and is_nil(Ecto.Changeset.get_field(changeset, field)) do
      Ecto.Changeset.add_error(changeset, field, "can't be blank")
    else
      changeset
    end
  end

  defp validate_portfolio_presence(changeset, "file", entries) do
    validate_file_presence(changeset, :portfolio_url, entries)
  end
  defp validate_portfolio_presence(changeset, "link", _entries) do
    Ecto.Changeset.validate_required(changeset, [:portfolio_url], message: "can't be blank")
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
              # Kita bungkus error di dalam :ok agar LiveView tidak crash
              {:ok, {:error, reason}}
          end
        end)

      case List.first(uploaded_results) do
        nil -> {:ok, nil}
        result -> result # akan bernilai {:ok, url} atau {:error, reason}
      end
    end
  end

  defp deliver_now(email) do
    user = System.get_env("SMTP_USER")
    pass = System.get_env("SMTP_PASSWORD")

    config = [
      relay: "smtp.gmail.com",
      username: user,
      password: pass,
      port: 587,
      ssl: false,
      tls: :always,
      auth: :always,
      retries: 1,
      tls_options: [verify: :verify_none],
      ssl_options: [verify: :verify_none]
    ]

    IO.puts(">>> [INTERNAL] Mengirim via Port 587 (STARTTLS)...")
    Swoosh.Adapters.SMTP.deliver(email, config)
  end
end
