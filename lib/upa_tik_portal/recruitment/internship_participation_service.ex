defmodule UpaTikPortal.Recruitment.InternshipParticipationService do
  import Ecto.Query, warn: false
  alias UpaTikPortal.Repo
  alias Ecto.Multi
  alias UpaTikPortal.Recruitment.InternshipParticipation
  alias UpaTikPortal.Recruitment.InternshipOpening

  def list_internship_participations do
    Repo.all(
      from p in InternshipParticipation,
      where: is_nil(p.deleted_at),
      preload: [:user, :internship_opening, :mentor],
      order_by: [desc: p.inserted_at]
    )
  end

  def count_internship_participations(opts \\ []) do
    from(p in InternshipParticipation, where: is_nil(p.deleted_at))
    |> filter_status(opts[:status])
    |> search_query(opts[:search])
    |> Repo.aggregate(:count, :id)
  end

  def list_internship_participations_paginated(page, per_page, opts \\ []) do
    offset = (page - 1) * per_page
    from(p in InternshipParticipation,
      where: is_nil(p.deleted_at),
      preload: [:user, :internship_opening, :mentor],
      order_by: [desc: p.inserted_at],
      limit: ^per_page,
      offset: ^offset
    )
    |> filter_status(opts[:status])
    |> search_query(opts[:search])
    |> Repo.all()
  end

  @doc "Daftar semua intern dengan status 'accepted' (intern aktif)"
  def list_active_interns(opts \\ []) do
    from(p in InternshipParticipation,
      where: p.status == "accepted" and is_nil(p.deleted_at),
      preload: [:user, :internship_opening, :mentor],
      order_by: [desc: p.start_date]
    )
    |> search_query(opts[:search])
    |> Repo.all()
  end

  @doc "Daftar intern yang dibimbing oleh mentor tertentu"
  def list_by_mentor(mentor_id, opts \\ []) do
    from(p in InternshipParticipation,
      where: p.mentor_id == ^mentor_id and p.status == "accepted" and is_nil(p.deleted_at),
      preload: [:user, :internship_opening],
      order_by: [desc: p.start_date]
    )
    |> search_query(opts[:search])
    |> Repo.all()
  end

  def list_mentor_interns(mentor_id, opts \\ []), do: list_by_mentor(mentor_id, opts)

  @doc "Ambil partisipasi milik user tertentu (satu user bisa punya beberapa lamaran)"
  def get_participation_by_user(user_id, opts \\ []) do
    from(p in InternshipParticipation,
      where: p.user_id == ^user_id and is_nil(p.deleted_at),
      preload: [:internship_opening, :mentor],
      order_by: [desc: p.inserted_at]
    )
    |> filter_status(opts[:status])
    |> search_query(opts[:search])
    |> Repo.all()
  end

  @doc "Ambil partisipasi aktif (accepted) milik user tertentu"
  def get_active_participation_by_user(user_id) do
    Repo.one(
      from p in InternshipParticipation,
      where: p.user_id == ^user_id and p.status == "accepted" and is_nil(p.deleted_at),
      preload: [:internship_opening, :mentor],
      limit: 1
    )
  end

  defp filter_status(query, nil), do: query
  defp filter_status(query, ""), do: query
  defp filter_status(query, status), do: where(query, [p], p.status == ^status)

  defp search_query(query, nil), do: query
  defp search_query(query, ""), do: query
  defp search_query(query, search_term) do
    from p in query,
      join: u in assoc(p, :user),
      join: o in assoc(p, :internship_opening),
      where: ilike(u.name, ^"%#{search_term}%") or ilike(o.title, ^"%#{search_term}%") or ilike(p.university, ^"%#{search_term}%")
  end

  def get_internship_participation!(id) do
    Repo.one!(
      from p in InternshipParticipation,
      where: p.id == ^id and is_nil(p.deleted_at),
      preload: [:user, :internship_opening, :mentor]
    )
  end

  def create_internship_participation(attrs) do
    user_id = Map.get(attrs, "user_id") || Map.get(attrs, :user_id)
    opening_id = Map.get(attrs, "opening_id") || Map.get(attrs, :opening_id)
    start_date_val = Map.get(attrs, "start_date") || Map.get(attrs, :start_date)
    end_date_val = Map.get(attrs, "end_date") || Map.get(attrs, :end_date)

    start_date = if is_binary(start_date_val), do: Date.from_iso8601!(start_date_val), else: start_date_val
    end_date = if is_binary(end_date_val), do: Date.from_iso8601!(end_date_val), else: end_date_val

    existing =
      Repo.one(
        from p in InternshipParticipation,
        where: p.user_id == ^user_id and p.opening_id == ^opening_id and is_nil(p.deleted_at),
        limit: 1
      )

    overlap =
      if start_date && end_date do
        Repo.one(
          from p in InternshipParticipation,
          where: p.user_id == ^user_id and p.status == "accepted" and is_nil(p.deleted_at)
            and p.start_date <= ^end_date and p.end_date >= ^start_date,
          limit: 1
        )
      else
        nil
      end

    if existing do
      {:error, :already_applied}
    else
      if overlap do
        {:error, :overlap_active_internship}
      else
      Multi.new()
        # 1. Operasi Insert Lamaran
        |> Multi.insert(:participation, InternshipParticipation.changeset(%InternshipParticipation{}, attrs))
        # 2. Operasi Update Kuota (Mengurangi 1)
        |> Multi.update_all(:decrement_quota, fn %{participation: p} ->
          from(o in InternshipOpening,
            where: o.id == ^p.opening_id and o.quota > 0,
            update: [inc: [quota: -1]]
          )
        end, [])
        |> Repo.transaction()
        |> case do
          {:ok, %{participation: participation}} ->
            {:ok, participation}
          {:error, :participation, changeset, _steps} ->
            {:error, changeset}
          {:error, :decrement_quota, _reason, _steps} ->
            {:error, :quota_full}
        end
      end
    end
  end
  def update_status(participation, status, changed_by_id \\ nil)
  def update_status(%InternshipParticipation{} = participation, "accepted", changed_by_id) do
    overlap_query = from p in InternshipParticipation,
      where: p.user_id == ^participation.user_id and p.status == "accepted" and is_nil(p.deleted_at)
        and p.start_date <= ^participation.end_date and p.end_date >= ^participation.start_date
        and p.id != ^participation.id,
      limit: 1

    if Repo.one(overlap_query) do
      {:error, "Pelamar sudah memiliki magang aktif pada periode yang sama."}
    else
      old_status = participation.status
      case participation
           |> InternshipParticipation.status_changeset(%{status: "accepted"})
           |> Repo.update() do
        {:ok, updated_participation} ->
          if changed_by_id do
            UpaTikPortal.Recruitment.AuditLogService.log_status_change(updated_participation.id, changed_by_id, old_status, "accepted")
          end
          updated_participation = Repo.preload(updated_participation, [:user, :internship_opening])
          Task.start(fn -> UpaTikPortalWeb.Mailers.ParticipationMailer.send_status_update(updated_participation) end)
          {:ok, updated_participation}
        error -> error
      end
    end
  end

  def update_status(%InternshipParticipation{} = participation, "rejected", changed_by_id) do
    old_status = participation.status
    if old_status == "rejected" do
      {:ok, participation}
    else
      Multi.new()
      |> Multi.update(:participation, InternshipParticipation.status_changeset(participation, %{status: "rejected"}))
      |> Multi.update_all(:increment_quota, fn %{participation: p} ->
        from(o in UpaTikPortal.Recruitment.InternshipOpening,
          where: o.id == ^p.opening_id,
          update: [inc: [quota: 1]]
        )
      end, [])
      |> Repo.transaction()
      |> case do
        {:ok, %{participation: updated_participation}} ->
          if changed_by_id do
            UpaTikPortal.Recruitment.AuditLogService.log_status_change(updated_participation.id, changed_by_id, old_status, "rejected")
          end
          updated_participation = Repo.preload(updated_participation, [:user, :internship_opening])
          Task.start(fn -> UpaTikPortalWeb.Mailers.ParticipationMailer.send_status_update(updated_participation) end)
          {:ok, updated_participation}
        {:error, :participation, changeset, _} ->
          {:error, changeset}
      end
    end
  end

  def update_status(%InternshipParticipation{} = participation, status, changed_by_id) do
    old_status = participation.status
    case participation
         |> InternshipParticipation.status_changeset(%{status: status})
         |> Repo.update() do
      {:ok, updated_participation} ->
        if changed_by_id do
          UpaTikPortal.Recruitment.AuditLogService.log_status_change(updated_participation.id, changed_by_id, old_status, status)
        end
        updated_participation = Repo.preload(updated_participation, [:user, :internship_opening])
        Task.start(fn -> UpaTikPortalWeb.Mailers.ParticipationMailer.send_status_update(updated_participation) end)
        {:ok, updated_participation}
      error -> error
    end
  end

  @doc "Admin assign mentor ke intern"
  def assign_mentor(%InternshipParticipation{} = participation, mentor_id) do
    active = get_active_participation_by_user(participation.user_id)
    
    if active && active.id != participation.id do
      {:error, "Pelamar sudah memiliki magang aktif di lowongan lain."}
    else
      participation
      |> InternshipParticipation.mentor_changeset(%{mentor_id: mentor_id})
      |> Repo.update()
    end
  end

  def change_internship_participation(%InternshipParticipation{} = internship_participation, attrs \\ %{}) do
    InternshipParticipation.changeset(internship_participation, attrs)
  end

  @doc "Soft delete partisipasi"
  def soft_delete(%InternshipParticipation{} = participation) do
    participation
    |> Ecto.Changeset.change(%{deleted_at: DateTime.utc_now() |> DateTime.truncate(:second)})
    |> Repo.update()
  end
end
