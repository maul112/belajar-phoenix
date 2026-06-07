defmodule UpaTikPortal.Mailer do
  use Swoosh.Mailer, otp_app: :upa_tik_portal

  @doc """
  Mengirim email dengan SSL options yang di-load saat runtime.
  Ini mengatasi masalah 'cacerts: :undefined' di lingkungan WSL/Windows.
  """
  def deliver_email(email) do
    IO.puts(">>> [Mailer] MEMULAI PENGIRIMAN EMAIL (GIGA-ULTIMATE FIX)...")

    # Ambil data environment
    user = System.get_env("SMTP_USER")
    pass = System.get_env("SMTP_PASSWORD")
    host = System.get_env("SMTP_HOST") || "smtp.gmail.com"
    port = String.to_integer(System.get_env("SMTP_PORT") || "465")

    # Load dan Decode sertifikat Laragon secara manual
    # Ini memastikan data sertifikat benar-benar ada di memori
    paths = [
      "/etc/ssl/certs/ca-certificates.crt",
      "C:/laragon/etc/ssl/cacert.pem"
    ]

    cert_binary = Enum.find_value(paths, fn path ->
      case File.read(path) do
        {:ok, binary} -> binary
        _ -> nil
      end
    end)

    certs =
      if cert_binary do
        :public_key.pem_decode(cert_binary)
        |> Enum.filter(fn {type, _, _} -> type == :Certificate end)
        |> Enum.map(fn {_, der, _} -> der end)
      else
        IO.puts(">>> [Mailer] WARNING: Gagal membaca file sertifikat!")
        []
      end

    IO.puts(">>> [Mailer] Berhasil me-load #{length(certs)} sertifikat ke memori.")

    # Konfigurasi SSL dengan data sertifikat mentah (cacerts)
    tls_opts =
      if certs != [] do
        [verify: :verify_peer, cacerts: certs, depth: 3, versions: [:"tlsv1.2", :"tlsv1.3"]]
      else
        [verify: :verify_none, versions: [:"tlsv1.2", :"tlsv1.3"]]
      end

    config = [
      relay: host,
      username: user,
      password: pass,
      port: port,
      ssl: port == 465,
      tls: :if_available,
      auth: :always,
      retries: 2,
      no_mx_lookups: true,
      tls_options: tls_opts,
      ssl_options: tls_opts,
      timeout: 15_000
    ]

    IO.puts(">>> [Mailer] Menghubungi Gmail...")
    result = Swoosh.Adapters.SMTP.deliver(email, config)

    case result do
      {:ok, _} -> IO.puts(">>> [Mailer] BERHASIL!")
      {:error, reason} ->
        IO.puts(">>> [Mailer] GAGAL!")
        IO.inspect(reason, label: ">>> [Mailer] ERROR DETAIL")
    end

    result
  end
end
