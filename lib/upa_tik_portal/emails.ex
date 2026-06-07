defmodule UpaTikPortal.Emails do
  @moduledoc """
  Email templates untuk portal UPA TIK.
  """
  import Swoosh.Email

  @from_name "UPA TIK Portal"

  def otp_email(request) do
    from_email = System.get_env("SMTP_USER") || "stokkgun7@gmail.com"
    type_label =
      if request.request_type == "aktivasi", do: "Aktivasi Akun", else: "Reset Password"

    new()
    |> to({request.full_name, request.user.email})
    |> from({@from_name, from_email})
    |> subject("[UPA TIK] Kode OTP #{type_label} Email Kampus")
    |> html_body(otp_html(request))
    |> text_body(otp_text(request))
  end

  defp otp_html(request) do
    type_label =
      if request.request_type == "aktivasi", do: "Aktivasi Akun", else: "Reset Password"

    """
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <style>
        body { font-family: 'Segoe UI', sans-serif; background: #f5f5f5; margin: 0; padding: 20px; }
        .container { max-width: 540px; margin: 0 auto; background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 24px rgba(0,0,0,0.08); }
        .header { background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%); padding: 32px 40px; text-align: center; }
        .header h1 { color: white; margin: 0; font-size: 22px; font-weight: 700; letter-spacing: 1px; }
        .header p { color: #bfdbfe; margin: 4px 0 0; font-size: 13px; }
        .body { padding: 36px 40px; }
        .body p { color: #374151; line-height: 1.7; margin: 0 0 16px; }
        .otp-box { background: #eff6ff; border: 2px dashed #3b82f6; border-radius: 10px; text-align: center; padding: 28px; margin: 24px 0; }
        .otp-code { font-size: 44px; font-weight: 800; letter-spacing: 10px; color: #1d4ed8; font-family: monospace; }
        .otp-note { font-size: 12px; color: #6b7280; margin-top: 8px; }
        .info-row { background: #f9fafb; border-radius: 8px; padding: 14px 18px; margin: 8px 0; display: flex; justify-content: space-between; }
        .info-label { color: #6b7280; font-size: 13px; }
        .info-value { color: #111827; font-size: 13px; font-weight: 600; }
        .footer { background: #f3f4f6; padding: 20px 40px; text-align: center; }
        .footer p { color: #9ca3af; font-size: 12px; margin: 0; }
      </style>

    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>🎓 UPA TIK Portal</h1>
          <p>Universitas – Unit Pelaksana Akademik Teknologi Informasi &amp; Komunikasi</p>
        </div>
        <div class="body">
          <p>Halo <strong>#{request.full_name}</strong>,</p>
          <p>Kami menerima pengajuan <strong>#{type_label}</strong> email kampus Anda. Berikut kode OTP (One-Time Password) untuk memverifikasi identitas Anda:</p>

          <div class="otp-box">
            <div class="otp-code">#{request.otp_code}</div>
            <div class="otp-note">Kode berlaku selama <strong>10 menit</strong>. Jangan bagikan kode ini kepada siapapun.</div>
          </div>

          <p><strong>Detail Pengajuan:</strong></p>
          <div class="info-row">
            <span class="info-label">NIM</span>
            <span class="info-value">#{request.nim}</span>
          </div>
          <div class="info-row">
            <span class="info-label">Email Kampus Diminta</span>
            <span class="info-value">#{request.email_requested}</span>
          </div>
          <div class="info-row">
            <span class="info-label">Jenis Pengajuan</span>
            <span class="info-value">#{type_label}</span>
          </div>

          <p style="margin-top:24px;">Jika Anda tidak merasa melakukan pengajuan ini, abaikan email ini.</p>
        </div>
        <div class="footer">
          <p>Email ini dikirim otomatis oleh sistem UPA TIK Portal. Tidak perlu membalas email ini.</p>
        </div>
      </div>
    </body>
    </html>
    """
  end

  defp otp_text(request) do
    type_label =
      if request.request_type == "aktivasi", do: "Aktivasi Akun", else: "Reset Password"

    """
    UPA TIK Portal – #{type_label}

    Halo #{request.full_name},

    Kode OTP Anda: #{request.otp_code}

    Detail:
    - NIM: #{request.nim}
    - Email Kampus: #{request.email_requested}
    - Jenis: #{type_label}

    Kode berlaku 10 menit. Jangan bagikan kepada siapapun.

    Jika tidak merasa mengajukan, abaikan email ini.
    -- UPA TIK Portal
    """
  end

  def internship_status_email(participation) do
    from_email = System.get_env("SMTP_USER") || "stokkgun7@gmail.com"
    user = participation.user

    subject = case participation.status do
      "applied" -> "[UPA TIK] Lamaran Magang Berhasil Dikirim"
      "interview" -> "[UPA TIK] Panggilan Wawancara Magang"
      "accepted" -> "[UPA TIK] Selamat! Anda Diterima Magang"
      "rejected" -> "[UPA TIK] Update Status Lamaran Magang"
      _ -> "[UPA TIK] Update Status Magang"
    end

    new()
    |> to({user.name, user.email})
    |> from({@from_name, from_email})
    |> subject(subject)
    |> html_body(status_html(participation))
    |> text_body(status_text(participation))
  end

  defp status_html(participation) do
    opening = participation.internship_opening
    user = participation.user

    {title, message} = get_status_message(participation.status, opening.title)

    """
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <style>
        body { font-family: 'Segoe UI', sans-serif; background: #f5f5f5; margin: 0; padding: 20px; }
        .container { max-width: 540px; margin: 0 auto; background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 24px rgba(0,0,0,0.08); }
        .header { background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%); padding: 32px 40px; text-align: center; }
        .header h1 { color: white; margin: 0; font-size: 22px; font-weight: 700; letter-spacing: 1px; }
        .header p { color: #bfdbfe; margin: 4px 0 0; font-size: 13px; }
        .body { padding: 36px 40px; }
        .body p { color: #374151; line-height: 1.7; margin: 0 0 16px; }
        .status-box { background: #eff6ff; border: 2px dashed #3b82f6; border-radius: 10px; text-align: center; padding: 24px; margin: 24px 0; }
        .status-title { font-size: 20px; font-weight: 800; color: #1d4ed8; margin-bottom: 8px; }
        .status-desc { font-size: 14px; color: #4b5563; }
        .footer { background: #f3f4f6; padding: 20px 40px; text-align: center; }
        .footer p { color: #9ca3af; font-size: 12px; margin: 0; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>🎓 UPA TIK Portal</h1>
          <p>Universitas – Unit Pelaksana Akademik Teknologi Informasi &amp; Komunikasi</p>
        </div>
        <div class="body">
          <p>Halo <strong>#{user.name}</strong>,</p>
          <p>Terima kasih telah berpartisipasi dalam program magang di UPA TIK. Berikut adalah pemberitahuan terkait status lamaran Anda untuk posisi <strong>#{opening.title}</strong>:</p>

          <div class="status-box">
            <div class="status-title">#{title}</div>
            <div class="status-desc">#{message}</div>
          </div>

          <p style="margin-top:24px;">Silakan cek secara berkala portal UPA TIK untuk melihat detail lebih lanjut.</p>
        </div>
        <div class="footer">
          <p>Email ini dikirim otomatis oleh sistem UPA TIK Portal. Tidak perlu membalas email ini.</p>
        </div>
      </div>
    </body>
    </html>
    """
  end

  defp status_text(participation) do
    opening = participation.internship_opening
    user = participation.user

    {title, message} = get_status_message(participation.status, opening.title)

    """
    UPA TIK Portal – Status Magang

    Halo #{user.name},

    Status lamaran magang Anda untuk posisi #{opening.title} telah diperbarui:

    [ #{title} ]
    #{message}

    Silakan cek portal UPA TIK untuk informasi lebih detail.
    -- UPA TIK Portal
    """
  end

  defp get_status_message("applied", _title) do
    {"Lamaran Diterima Sistem", "Lamaran Anda telah kami terima dan saat ini sedang menunggu antrean untuk direview oleh tim administrasi."}
  end

  defp get_status_message("interview", _title) do
    {"Tahap Wawancara", "Selamat! Profil Anda lolos seleksi awal. Tim kami akan segera menghubungi Anda untuk penjadwalan sesi wawancara."}
  end

  defp get_status_message("accepted", _title) do
    {"Diterima Magang", "Selamat! Anda secara resmi dinyatakan DITERIMA untuk program magang ini. Harap menunggu arahan selanjutnya dari mentor Anda atau silakan konfirmasi ke kantor UPA TIK."}
  end

  defp get_status_message("rejected", _title) do
    {"Lamaran Ditolak", "Mohon maaf, saat ini kami belum dapat memproses lamaran Anda ke tahap selanjutnya. Jangan patah semangat dan coba lagi di kesempatan berikutnya."}
  end

  defp get_status_message(status, _title) do
    {"Status Diperbarui", "Status Anda saat ini adalah: #{status}."}
  end
end
