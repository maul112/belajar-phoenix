defmodule UpaTikPortal.Recruitment.WeeklyLogService do
  @moduledoc """
  Context untuk manajemen weekly log (logbook mingguan) peserta magang.
  """
  import Ecto.Query, warn: false
  alias UpaTikPortal.Repo
  alias UpaTikPortal.Recruitment.WeeklyLog

  @doc "Daftar semua weekly log milik satu partisipasi, diurutkan berdasarkan minggu"
  def list_by_participation(participation_id) do
    WeeklyLog
    |> where([w], w.participation_id == ^participation_id)
    |> order_by([w], asc: w.week_number)
    |> Repo.all()
  end

  @doc "Ambil satu weekly log by id (404 jika tidak ada)"
  def get_weekly_log!(id), do: Repo.get!(WeeklyLog, id)

  @doc "Buat weekly log baru"
  def create_weekly_log(participation_id, attrs) do
    participation = UpaTikPortal.Recruitment.InternshipParticipationService.get_internship_participation!(participation_id)
    today = UpaTikPortalWeb.Helpers.TimeHelper.today_wib()

    if participation.internship_opening.end_date && Date.compare(today, participation.internship_opening.end_date) == :gt do
      {:error, "Periode magang telah berakhir. Batas waktu pengunggahan logbook sudah lewat."}
    else
      %WeeklyLog{}
      |> WeeklyLog.changeset(Map.put(attrs, "participation_id", participation_id))
      |> Repo.insert()
    end
  end

  @doc "Update isi weekly log (oleh intern)"
  def update_weekly_log(%WeeklyLog{} = log, attrs) do
    log
    |> WeeklyLog.changeset(attrs)
    |> Repo.update()
  end

  @doc "Hapus weekly log"
  def delete_weekly_log(%WeeklyLog{} = log) do
    Repo.delete(log)
  end

  @doc "Mentor memberikan feedback pada weekly log"
  def give_feedback(%WeeklyLog{} = log, feedback) do
    log
    |> WeeklyLog.feedback_changeset(%{feedback: feedback})
    |> Repo.update()
  end

  @doc "Changeset kosong untuk form baru"
  def change_weekly_log(%WeeklyLog{} = log \\ %WeeklyLog{}, attrs \\ %{}) do
    WeeklyLog.changeset(log, attrs)
  end

  @doc "Nomor minggu berikutnya yang harus disubmit oleh partisipasi tertentu"
  def next_week_number(participation_id) do
    last_week =
      WeeklyLog
      |> where([w], w.participation_id == ^participation_id)
      |> select([w], max(w.week_number))
      |> Repo.one()

    (last_week || 0) + 1
  end

  @doc "Rekap statistik logbook: total, dengan feedback, tanpa feedback"
  def stats(participation_id) do
    logs = list_by_participation(participation_id)
    total = length(logs)
    with_feedback = Enum.count(logs, &(&1.feedback != nil))
    %{total: total, with_feedback: with_feedback, pending_feedback: total - with_feedback}
  end
end
