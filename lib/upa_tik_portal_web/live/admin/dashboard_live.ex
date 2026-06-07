defmodule UpaTikPortalWeb.Admin.DashboardLive do
  use UpaTikPortalWeb, :live_view

  import Ecto.Query, warn: false
  alias UpaTikPortal.Repo
  alias UpaTikPortal.Accounts.User
  alias UpaTikPortal.Recruitment.InternshipOpening
  alias UpaTikPortal.Recruitment.InternshipParticipation
  alias UpaTikPortal.Recruitment.Presence
  alias UpaTikPortal.Requests

  def mount(_params, _session, socket) do
    stats = Requests.stats()
    keluhan_stats = UpaTikPortal.Keluhans.stats()

    # Aggregate New Stats
    total_users = Repo.aggregate(User, :count, :id)
    
    total_openings = 
      InternshipOpening
      |> where(is_active: true)
      |> Repo.aggregate(:count, :id)

    pending_participants = 
      InternshipParticipation
      |> where(status: "pending")
      |> Repo.aggregate(:count, :id)

    active_interns = 
      InternshipParticipation
      |> where(status: "accepted")
      |> Repo.aggregate(:count, :id)

    today = Date.utc_today()
    start_of_day = DateTime.new!(today, ~T[00:00:00], "Etc/UTC")
    end_of_day = DateTime.new!(today, ~T[23:59:59], "Etc/UTC")

    presensi_hari_ini = 
      Presence
      |> where([p], p.inserted_at >= ^start_of_day and p.inserted_at <= ^end_of_day)
      |> Repo.aggregate(:count, :id)

    {:ok,
     assign(socket,
       page_title: "Dashboard Admin – UPA TIK Portal",
       pending: Map.get(stats, "pending", 0),
       disetujui: Map.get(stats, "disetujui", 0),
       ditolak: Map.get(stats, "ditolak", 0),
       total: Enum.sum(Map.values(stats)),
       keluhan_baru: Map.get(keluhan_stats, "baru", 0),
       total_users: total_users || 0,
       total_openings: total_openings || 0,
       pending_participants: pending_participants || 0,
       active_interns: active_interns || 0,
       presensi_hari_ini: presensi_hari_ini || 0
     )}
  end
end
