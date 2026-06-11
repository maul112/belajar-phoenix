defmodule UpaTikPortal.Recruitment.Division do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "divisions" do
    field :name, :string
    field :description, :string

    has_many :internship_openings, UpaTikPortal.Recruitment.InternshipOpening, foreign_key: :division_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(division, attrs) do
    division
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
