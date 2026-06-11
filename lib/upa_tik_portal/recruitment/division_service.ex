defmodule UpaTikPortal.Recruitment.DivisionService do
  import Ecto.Query
  alias UpaTikPortal.Repo
  alias UpaTikPortal.Recruitment.Division

  def list_divisions do
    Repo.all(from d in Division, order_by: [asc: d.name])
  end

  def get_division!(id), do: Repo.get!(Division, id)

  def create_division(attrs \\ %{}) do
    %Division{}
    |> Division.changeset(attrs)
    |> Repo.insert()
  end

  def update_division(%Division{} = division, attrs) do
    division
    |> Division.changeset(attrs)
    |> Repo.update()
  end

  def delete_division(%Division{} = division) do
    Repo.delete(division)
  end

  def change_division(%Division{} = division, attrs \\ %{}) do
    Division.changeset(division, attrs)
  end
end
