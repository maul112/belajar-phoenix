defmodule UpaTikPortal.Recruitment.InternshipOpeningService do
  import Ecto.Query, warn: false
  alias UpaTikPortal.Repo
  alias UpaTikPortal.Recruitment.InternshipOpening

  def list_internship_openings(opts \\ []) do
    InternshipOpening
    |> preload(:division)
    |> filter_active(opts[:is_active])
    |> filter_division(opts[:division_id])
    |> search_query(opts[:search])
    |> apply_sort(opts[:sort_by])
    |> Repo.all()
  end

  def count_internship_openings(opts \\ []) do
    InternshipOpening
    |> filter_active(opts[:is_active])
    |> filter_division(opts[:division_id])
    |> search_query(opts[:search])
    |> Repo.aggregate(:count, :id)
  end

  def list_internship_openings_paginated(page, per_page, opts \\ []) do
    offset = (page - 1) * per_page

    InternshipOpening
    |> preload(:division)
    |> filter_active(opts[:is_active])
    |> filter_division(opts[:division_id])
    |> search_query(opts[:search])
    |> apply_sort(opts[:sort_by] || [desc: :inserted_at])
    |> limit(^per_page)
    |> offset(^offset)
    |> Repo.all()
  end

  defp filter_division(query, nil), do: query
  defp filter_division(query, division_id) when division_id == "", do: query
  defp filter_division(query, division_id), do: where(query, division_id: ^division_id)

  defp apply_sort(query, nil), do: order_by(query, asc: :closing_date)
  defp apply_sort(query, sort_opts), do: order_by(query, ^sort_opts)

  defp filter_active(query, nil), do: query
  defp filter_active(query, true), do: where(query, is_active: true)

  defp search_query(query, nil), do: query
  defp search_query(query, search_term) do
    from o in query,
      left_join: d in assoc(o, :division),
      where: ilike(o.title, ^"%#{search_term}%") or ilike(d.name, ^"%#{search_term}%")
  end

  def list_top_urgent_openings(limit \\ 3) do
    InternshipOpening
    |> preload(:division)
    |> where([o], o.is_active == true and o.quota > 0)
    |> order_by([o], asc: o.quota)
    |> limit(^limit)
    |> Repo.all()
  end

  def get_internship_opening!(id), do: Repo.get!(InternshipOpening, id) |> Repo.preload(:division)

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
