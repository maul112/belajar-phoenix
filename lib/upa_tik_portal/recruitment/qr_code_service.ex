defmodule UpaTikPortal.Recruitment.QrCodeService do
  @moduledoc """
  Fungsi untuk generate QR Code presensi.
  """

  @secret_salt Application.compile_env(:upa_tik_portal, :qr_secret_salt, "presensi_utm_magang_2026")

  @doc """
  Generate token aman yang berisi ID partisipasi dan timestamp saat ini
  agar token memiliki kedaluwarsa.
  """
  def generate_token(participation_id) do
    # Buat token berisi: id_partisipasi|timestamp|signature
    timestamp = System.system_time(:second)
    data = "#{participation_id}|#{timestamp}"
    signature = sign_data(data)

    jwt_token = Base.url_encode64("#{data}|#{signature}")
    UpaTikPortal.Recruitment.QrTokenStore.put_token(jwt_token)
  end

  @doc """
  Decode dan verifikasi token.
  Validasi:
  1. Signature harus cocok
  2. Timestamp tidak boleh lebih dari X jam (misal 1 jam)
  """
  def verify_token(short_token, max_age_seconds \\ 3600) do
    with jwt_token when not is_nil(jwt_token) <- UpaTikPortal.Recruitment.QrTokenStore.get_token(short_token),
         {:ok, decoded} <- Base.url_decode64(jwt_token),
         [participation_id, ts_str, signature] <- String.split(decoded, "|"),
         {timestamp, _} <- Integer.parse(ts_str),
         true <- signature == sign_data("#{participation_id}|#{timestamp}"),
         true <- System.system_time(:second) - timestamp <= max_age_seconds do
      {:ok, participation_id}
    else
      _ -> {:error, :invalid_or_expired_token}
    end
  end

  @doc """
  Generate SVG QR Code dari sebuah text/token.
  """
  def generate_svg(text) do
    text
    |> QRCode.create(:high)
    |> case do
      {:ok, qr} ->
        case QRCode.render({:ok, qr}, :svg) do
          {:ok, svg} ->
            # Inject viewBox attribute so the SVG scales automatically without cropping
            Regex.replace(~r/<svg ([^>]*)width="(\d+)" height="(\d+)"/, svg, "<svg \\1width=\"100%\" height=\"100%\" viewBox=\"0 0 \\2 \\3\"")
          _ -> ""
        end
      _ -> ""
    end
  end

  defp sign_data(data) do
    :crypto.mac(:hmac, :sha256, @secret_salt, data)
    |> Base.encode16()
  end
end
