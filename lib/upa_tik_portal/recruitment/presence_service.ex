defmodule UpaTikPortal.Recruitment.PresenceService do
  @moduledoc """
  Context untuk manajemen presensi harian peserta magang.
  """
  import Ecto.Query, warn: false
  alias UpaTikPortal.Repo
  alias UpaTikPortal.Recruitment.Presence

  @doc "Daftar semua presensi milik satu partisipasi, diurutkan by tanggal terbaru"
  def list_by_participation(participation_id) do
    Presence
    |> where([p], p.participation_id == ^participation_id)
    |> order_by([p], desc: p.date)
    |> Repo.all()
  end

  @doc "Daftar semua presensi semua intern pada tanggal tertentu (untuk admin/mentor)"
  def list_by_date(date, opts \\ []) do
    query = Presence
    |> where([p], p.date == ^date)
    |> join(:inner, [p], part in assoc(p, :participation))
    |> join(:inner, [p, part], u in assoc(part, :user))
    |> join(:inner, [p, part, u], o in assoc(part, :internship_opening))
    |> preload([p, part, u, o], participation: {part, user: u, internship_opening: o})
    |> order_by([p], asc: p.inserted_at)

    query = if opts[:search] && opts[:search] != "" do
      search_term = "%#{opts[:search]}%"
      where(query, [p, part, u, o], ilike(u.name, ^search_term))
    else
      query
    end

    query = if opts[:opening] && opts[:opening] != "" do
      where(query, [p, part, u, o], o.title == ^opts[:opening])
    else
      query
    end

    Repo.all(query)
  end

  @doc "Ambil presensi hari ini untuk satu partisipasi, jika ada"
  def get_today(participation_id) do
    today = UpaTikPortalWeb.Helpers.TimeHelper.today_wib()

    Presence
    |> where([p], p.participation_id == ^participation_id and p.date == ^today)
    |> Repo.one()
  end

  @doc "Ambil presensi by id"
  def get_presence!(id), do: Repo.get!(Presence, id)

  @doc "Catat check-in: buat record baru hari ini"
  def check_in(participation_id) do
    now = UpaTikPortalWeb.Helpers.TimeHelper.now_wib() |> NaiveDateTime.to_time() |> Time.truncate(:second)
    today = UpaTikPortalWeb.Helpers.TimeHelper.today_wib()

    case get_today(participation_id) do
      nil ->
        %Presence{}
        |> Presence.changeset(%{
          participation_id: participation_id,
          date: today,
          check_in: now,
          status: "present"
        })
        |> Repo.insert()

      existing ->
        {:error, :already_checked_in, existing}
    end
  end

  @doc "Catat check-out: update record hari ini"
  def check_out(participation_id) do
    now = UpaTikPortalWeb.Helpers.TimeHelper.now_wib() |> NaiveDateTime.to_time() |> Time.truncate(:second)

    case get_today(participation_id) do
      nil ->
        {:error, :not_checked_in}

      presence ->
        presence
        |> Presence.check_out_changeset(%{check_out: now})
        |> Repo.update()
    end
  end

  @doc "Rekap statistik kehadiran untuk satu partisipasi"
  def stats(participation_id) do
    presences = list_by_participation(participation_id)

    total = length(presences)
    present = Enum.count(presences, &(&1.status == "present"))
    sick = Enum.count(presences, &(&1.status == "sick"))
    permit = Enum.count(presences, &(&1.status == "permit"))
    absent = Enum.count(presences, &(&1.status == "absent"))

    %{total: total, present: present, sick: sick, permit: permit, absent: absent}
  end

  @doc "Catat presensi manual (hadir, sakit, izin, alpha) beserta jamnya jika ada"
  def set_manual_presence(participation_id, date, status, notes \\ nil, check_in \\ nil, check_out \\ nil) do
    # Jika check_in/check_out kosong dari form, jadikan nil
    check_in = if check_in == "", do: nil, else: check_in
    check_out = if check_out == "", do: nil, else: check_out

    query = from p in Presence, where: p.participation_id == ^participation_id and p.date == ^date
    
    attrs = %{
      status: status,
      notes: notes,
      check_in: check_in,
      check_out: check_out
    }
    
    case Repo.one(query) do
      nil ->
        %Presence{}
        |> Presence.changeset(Map.merge(%{participation_id: participation_id, date: date}, attrs))
        |> Repo.insert()
      existing ->
        existing
        |> Presence.changeset(attrs)
        |> Repo.update()
    end
  end

  @doc "Changeset kosong untuk form"
  def change_presence(%Presence{} = presence \\ %Presence{}, attrs \\ %{}) do
    Presence.changeset(presence, attrs)
  end

  def delete_presence(%Presence{} = presence) do
    Repo.delete(presence)
  end
end
