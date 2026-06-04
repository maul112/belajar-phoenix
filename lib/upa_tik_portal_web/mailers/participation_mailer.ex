defmodule UpaTikPortalWeb.Mailers.ParticipationMailer do
  import Swoosh.Email
  require Logger

  def send_status_update(participation) do
    user = participation.user
    opening = participation.internship_opening
    
    # Hanya kirim email jika statusnya accepted atau rejected
    if participation.status in ["accepted", "rejected"] do
      status_text =
        case participation.status do
          "accepted" -> "DITERIMA"
          "rejected" -> "DITOLAK"
          _ -> participation.status
        end
  
      email =
        new()
        |> to({user.name, user.email})
        |> from({"UPA TIK UTM", System.get_env("SMTP_USER") || "noreply@tik.trunojoyo.ac.id"})
        |> subject("Update Status Lamaran Magang - UPA TIK")
        |> html_body("""
          <div style="font-family: sans-serif; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 8px;">
            <h2 style="color: #2563eb;">Halo #{user.name},</h2>
            <p>Pengumuman mengenai lamaran magang Anda di UPA TIK Universitas Trunojoyo Madura.</p>
            <p>Status lamaran untuk posisi <strong>#{opening.title}</strong> saat ini adalah:</p>
            <h3 style="background: #f1f5f9; padding: 10px; border-radius: 4px; display: inline-block;">#{status_text}</h3>
            <p>Silakan login ke portal magang untuk melihat informasi lebih detail, termasuk mentor pembimbing Anda jika lamaran diterima.</p>
            <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;" />
            <p style="font-size: 12px; color: #666;">Pesan ini dihasilkan secara otomatis. Mohon jangan membalas email ini.</p>
          </div>
        """)
  
      # Gunakan fungsi custom yang sudah menangani cacerts Laragon
      Task.start(fn -> 
        try do
          UpaTikPortal.Mailer.deliver_email(email)
        rescue
          e -> Logger.error("Gagal mengirim email status: #{inspect(e)}")
        end
      end)
    end
  end
end
