defmodule UpaTikPortal.MailerDebug do
  def deliver_test(email) do
    IO.puts(">>> [MailerDebug] MEMULAI TEST KONEKSI BARU...")
    
    # Ambil data environment
    user = System.get_env("SMTP_USER")
    pass = System.get_env("SMTP_PASSWORD")
    host = System.get_env("SMTP_HOST") || "smtp.gmail.com"
    port = String.to_integer(System.get_env("SMTP_PORT") || "465")

    # Load dan Decode sertifikat Laragon secara manual
    certs = 
      case File.read("C:/laragon/etc/ssl/cacert.pem") do
        {:ok, binary} ->
          :public_key.pem_decode(binary)
          |> Enum.filter(fn {type, _, _} -> type == :Certificate end)
          |> Enum.map(fn {_, der, _} -> der end)
        _ -> []
      end

    IO.puts(">>> [MailerDebug] Sertifikat dimuat: #{length(certs)} item.")

    # Gunakan verify_none saja untuk memastikan PASTI tembus
    tls_opts = [
      verify: :verify_none,
      versions: [:"tlsv1.2", :"tlsv1.3"]
    ]

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

    IO.puts(">>> [MailerDebug] Menghubungi Gmail: #{host}:#{port}...")
    Swoosh.Adapters.SMTP.deliver(email, config)
  end
end
