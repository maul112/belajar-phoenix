defmodule UpaTikPortal.Recruitment.InternComplaintService do
  @moduledoc """
  Context untuk manajemen keluhan internal peserta magang.
  """
  import Ecto.Query, warn: false
  alias UpaTikPortal.Repo
  alias UpaTikPortal.Recruitment.InternComplaint

  @doc "Daftar keluhan milik satu partisipasi"
  def list_by_participation(participation_id) do
    InternComplaint
    |> where([c], c.participation_id == ^participation_id)
    |> order_by([c], desc: c.inserted_at)
    |> Repo.all()
  end

  @doc "Daftar semua keluhan intern (untuk admin), terbaru dulu"
  def list_all do
    InternComplaint
    |> order_by([c], desc: c.inserted_at)
    |> preload(participation: [:user])
    |> Repo.all()
  end

  @doc "Ambil satu complaint by id"
  def get_complaint!(id), do: Repo.get!(InternComplaint, id)

  @doc "Intern mengirim keluhan baru"
  def create_complaint(participation_id, attrs) do
    category = Map.get(attrs, "category") || Map.get(attrs, :category)

    existing =
      InternComplaint
      |> where([c], c.participation_id == ^participation_id and c.category == ^category)
      |> Repo.one()

    if existing do
      {:error, "Kamu sudah mengirim keluhan untuk kategori ini."}
    else
      %InternComplaint{}
      |> InternComplaint.changeset(Map.put(attrs, "participation_id", participation_id))
      |> Repo.insert()
    end
  end

  @doc "Admin menandai keluhan sebagai resolved/unresolved"
  def resolve_complaint(%InternComplaint{} = complaint, is_resolved) do
    complaint
    |> InternComplaint.resolve_changeset(%{is_resolved: is_resolved})
    |> Repo.update()
  end

  @doc "Changeset kosong untuk form"
  def change_complaint(%InternComplaint{} = complaint \\ %InternComplaint{}, attrs \\ %{}) do
    InternComplaint.changeset(complaint, attrs)
  end

  @doc "Statistik keluhan: total, resolved, pending"
  def stats(participation_id) do
    complaints = list_by_participation(participation_id)
    total = length(complaints)
    resolved = Enum.count(complaints, & &1.is_resolved)
    %{total: total, resolved: resolved, pending: total - resolved}
  end
end
