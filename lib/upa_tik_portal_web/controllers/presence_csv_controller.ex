defmodule UpaTikPortalWeb.PresenceCsvController do
  use UpaTikPortalWeb, :controller
  alias UpaTikPortal.Recruitment.PresenceExportService

  def export(conn, _params) do
    csv_content = PresenceExportService.generate_csv()
    filename = "rekap_presensi_magang_#{Date.to_string(Date.utc_today())}.csv"

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"#{filename}\"")
    |> send_resp(200, csv_content)
  end
end
