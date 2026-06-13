defmodule UpaTikPortalWeb.PresenceCsvController do
  use UpaTikPortalWeb, :controller
  alias UpaTikPortal.Recruitment.PresenceExportService

  def export(conn, _params) do
    zip_binary = PresenceExportService.generate_zip_by_division()
    filename = "rekap_presensi_magang_#{Date.to_string(Date.utc_today())}.zip"

    conn
    |> put_resp_content_type("application/zip")
    |> put_resp_header("content-disposition", "attachment; filename=\"#{filename}\"")
    |> send_resp(200, zip_binary)
  end
end
