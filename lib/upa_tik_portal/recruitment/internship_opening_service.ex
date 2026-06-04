defmodule UpaTikPortal.Recruitment.InternshipOpeningService do
  import Ecto.Query, warn: false
  alias UpaTikPortal.Repo
  alias UpaTikPortal.Recruitment.InternshipOpening

  def list_internship_openings (opts \\ []) do
    InternshipOpening
    |> filter_active(opts[:is_active])
    |> search_query(opts[:search])
    |> order_by(asc: :closing_date)
    |> Repo.all()
  end

  defp filter_active(query, nil), do: query
  defp filter_active(query, true), do: where(query, is_active: true)

  defp search_query(query, nil), do: query
  defp search_query(query, search_term) do
    # Mencari di judul atau departemen
    from o in query,
      where: ilike(o.title, ^"%#{search_term}%") or ilike(o.department, ^"%#{search_term}%")
  end

  def list_top_urgent_openings(limit \\ 3) do
    InternshipOpening
    |> where([o], o.is_active == true and o.quota > 0)
    |> order_by([o], asc: o.quota)
    |> limit(^limit)
    |> Repo.all()
  end

  def get_internship_opening!(id), do: Repo.get!(InternshipOpening, id)

  def create_internship_opening(attrs) do
    %InternshipOpening{}
    |> InternshipOpening.changeset(attrs)
    |> Repo.insert()
  end

  def update_internship_opening(%InternshipOpening{} = internship_opening, attrs) do
    internship_opening
    |> InternshipOpening.changeset(attrs)
    |> Repo.update()
  end

  def delete_internship_opening(%InternshipOpening{} = internship_opening) do
    Repo.delete(internship_opening)
  end

  def change_internship_opening(%InternshipOpening{} = internship_opening, attrs \\ %{}) do
    InternshipOpening.changeset(internship_opening, attrs)
  end
end
