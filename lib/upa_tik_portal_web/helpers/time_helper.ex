defmodule UpaTikPortalWeb.Helpers.TimeHelper do
  @moduledoc """
  Helper untuk mendapatkan waktu dalam format WIB (Waktu Indonesia Barat) / Asia/Jakarta (UTC+7).
  Digunakan karena kita tidak menggunakan dependency `tzdata` atau `tz` secara spesifik,
  dan kebutuhan utamanya adalah men-shift UTC ke UTC+7.
  """

  @doc "Mendapatkan NaiveDateTime saat ini dalam WIB (UTC+7)"
  def now_wib do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.add(7, :hour)
  end

  @doc "Mendapatkan Date (hari ini) dalam WIB (UTC+7)"
  def today_wib do
    now_wib()
    |> NaiveDateTime.to_date()
  end
end
