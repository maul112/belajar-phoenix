defmodule UpaTikPortalWeb.Admin.PengajuanLive.Show do
  use UpaTikPortalWeb, :live_view

  alias UpaTikPortal.Requests

  def mount(%{"id" => id}, _session, socket) do
    request = Requests.get_request!(id)

    {:ok,
     assign(socket,
       page_title: "Detail Pengajuan – Admin UPA TIK",
       request: request,
       notes: request.admin_notes || "",
       manual_otp: "",
       sending_otp: false,
       otp_sent: false
     )}
  end

  def handle_event("approve", _params, socket) do
    case Requests.update_status(socket.assigns.request, "disetujui", socket.assigns.notes) do
      {:ok, updated} ->
        {:noreply,
         socket
         |> assign(request: updated)
         |> put_flash(:info, "PENGATURAN STATUS: Pengajuan BERHASIL Disetujui.")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Gagal mengupdate status.")}
    end
  end

  def handle_event("reject", _params, socket) do
    case Requests.update_status(socket.assigns.request, "ditolak", socket.assigns.notes) do
      {:ok, updated} ->
        {:noreply,
         socket
         |> assign(request: updated)
         |> put_flash(:info, "PENGATURAN STATUS: Pengajuan Telah Ditolak.")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Gagal mengupdate status.")}
    end
  end

  def handle_event("update-field", %{"notes" => notes, "otp" => otp}, socket) do
    {:noreply, assign(socket, notes: notes, manual_otp: otp)}
  end

  def handle_event("update-field", %{"notes" => notes}, socket) do
    {:noreply, assign(socket, notes: notes)}
  end

  def handle_event("update-field", %{"otp" => otp}, socket) do
    {:noreply, assign(socket, manual_otp: otp)}
  end

  def handle_event("send-otp", params, socket) do
    manual_otp = Map.get(params, "manual_otp", socket.assigns.manual_otp)
    request = socket.assigns.request

    if request.status != "disetujui" do
      {:noreply, put_flash(socket, :error, "ERROR: Setujui pengajuan terlebih dahulu.")}
    else
      socket = assign(socket, sending_otp: true, manual_otp: manual_otp)

      otp = if manual_otp != "" and not is_nil(manual_otp), do: manual_otp, else: (:crypto.strong_rand_bytes(3) |> Base.encode16() |> String.slice(0, 6))
      now = DateTime.utc_now() |> DateTime.truncate(:second)

      case UpaTikPortal.Repo.update(UpaTikPortal.Requests.EmailRequest.otp_changeset(request, %{otp_code: otp, otp_sent_at: now})) do
        {:ok, updated_request} ->
          email = UpaTikPortal.Emails.otp_email(updated_request)
          case deliver_now(email) do
            {:ok, _} ->
              {:noreply,
               socket
               |> assign(request: updated_request, sending_otp: false, otp_sent: true, manual_otp: "")
               |> put_flash(:info, "SUKSES: Kode OTP #{otp} Berhasil Dikirim!")}
            {:error, reason} ->
              IO.inspect(reason, label: "SEND ERROR")
              {:noreply, assign(socket, sending_otp: false) |> put_flash(:error, "Gagal kirim email: #{inspect(reason)}")}
          end
        {:error, _} ->
          {:noreply, assign(socket, sending_otp: false) |> put_flash(:error, "Gagal update OTP di database.")}
      end
    end
  end

  def handle_event("debug-email", _params, socket) do
    request = socket.assigns.request
    IO.puts(">>> [INTERNAL DEBUG] MEMULAI PENGIRIMAN...")

    socket = put_flash(socket, :info, "MENGHUBUNGI GOOGLE DENGAN MESIN INTERNAL...")

    email = UpaTikPortal.Emails.otp_email(request)
    case deliver_now(email) do
      {:ok, _} ->
        {:noreply, put_flash(socket, :info, "SUKSES: Koneksi Berhasil!")}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "GAGAL: #{inspect(reason)}")}
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

  defp status_class("pending"), do: "bg-amber-100 text-amber-700 border border-amber-200"
  defp status_class("disetujui"), do: "bg-emerald-100 text-emerald-700 border border-emerald-200"
  defp status_class("ditolak"), do: "bg-rose-100 text-rose-700 border border-rose-200"
  defp status_class(_), do: "bg-slate-100 text-slate-700"

  defp status_label("pending"), do: "⏳ Menunggu"
  defp status_label("disetujui"), do: "✅ Disetujui"
  defp status_label("ditolak"), do: "❌ Ditolak"
  defp status_label(s), do: s

  defp format_type("aktivasi"), do: "Aktivasi Akun"
  defp format_type("reset"), do: "Reset Password"
  defp format_type(t), do: t
end
