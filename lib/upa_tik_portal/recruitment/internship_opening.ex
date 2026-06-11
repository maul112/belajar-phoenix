defmodule UpaTikPortal.Recruitment.InternshipOpening do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "internship_openings" do
    field :title, :string
    field :description, :string
    field :quota, :integer
    field :is_active, :boolean, default: true
    field :closing_date, :date
    field :start_date, :date
    field :end_date, :date

    belongs_to :division, UpaTikPortal.Recruitment.Division, foreign_key: :division_id, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(internship_opening, attrs) do
    internship_opening
    |> cast(attrs, [:title, :description, :division_id, :quota, :is_active, :closing_date, :start_date, :end_date])
    |> validate_required([:title, :description, :division_id, :quota, :closing_date, :start_date, :end_date])
    |> validate_dates()
  end

  defp validate_dates(changeset) do
    closing_date = get_field(changeset, :closing_date)
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)

    changeset = 
      if closing_date && start_date && Date.compare(Date.add(closing_date, 7), start_date) == :gt do
        add_error(changeset, :closing_date, "harus minimal 7 hari sebelum tanggal mulai")
      else
        changeset
      end

    if start_date && end_date do
      if Date.compare(start_date, end_date) != :lt do
        add_error(changeset, :end_date, "harus setelah tanggal mulai")
      else
        if Date.diff(end_date, start_date) < 120 do
          add_error(changeset, :end_date, "harus berjarak minimal 120 hari (4 bulan) dari tanggal mulai")
        else
          changeset
        end
      end
    else
      changeset
    end
  end
end
