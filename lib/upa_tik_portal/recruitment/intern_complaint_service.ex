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
  def list_all(opts \\ []) do
    query =
      InternComplaint
      |> filter_category(opts[:category])
      |> order_by([c], desc: c.inserted_at)
      |> preload(participation: [:user])

    paginate_query(query, opts)
  end

  @doc "Daftar keluhan intern yang dibimbing mentor tertentu"
  def list_by_mentor(mentor_id, opts \\ []) do
    query =
      InternComplaint
      |> join(:inner, [c], p in assoc(c, :participation))
      |> where([c, p], p.mentor_id == ^mentor_id)
      |> filter_category(opts[:category])
      |> order_by([c, p], desc: c.inserted_at)
      |> preload([c, p], participation: [:user])

    paginate_query(query, opts)
  end

  defp filter_category(query, nil), do: query
  defp filter_category(query, ""), do: query
  defp filter_category(query, category), do: where(query, [c], c.category == ^category)

  defp paginate_query(query, opts) do
    page = Keyword.get(opts, :page)
    per_page = Keyword.get(opts, :per_page, 10)

    if page do
      page = max(1, if(is_binary(page), do: String.to_integer(page), else: page))
      offset = (page - 1) * per_page
      
      count_query = query |> exclude(:order_by) |> exclude(:preload) |> exclude(:select) |> select([c], count(c.id))
      total_entries = Repo.one(count_query) || 0
      total_pages = max(1, ceil(total_entries / per_page))

      entries =
        query
        |> limit(^per_page)
        |> offset(^offset)
        |> Repo.all()

      %{entries: entries, total_pages: total_pages, current_page: page}
    else
      Repo.all(query)
    end
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
    result =
      complaint
      |> InternComplaint.resolve_changeset(%{is_resolved: is_resolved})
      |> Repo.update()

    require Logger
    Logger.error("RESOLVE COMPLAINT RESULT: #{inspect(result)}")

    result
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
