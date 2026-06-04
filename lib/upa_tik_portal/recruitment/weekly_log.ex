defmodule UpaTikPortal.Recruitment.WeeklyLog do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "weekly_logs" do
    field :week_number, :integer
    field :week_start_date, :date
    field :week_end_date, :date
    field :activity_title, :string
    field :activity_description, :string
    field :feedback, :string
    field :pdf_url, :string

    belongs_to :participation, UpaTikPortal.Recruitment.InternshipParticipation,
      foreign_key: :participation_id,
      type: :binary_id

    timestamps(type: :utc_datetime)
  end

  def changeset(weekly_log, attrs) do
    weekly_log
    |> cast(attrs, [
      :week_number,
      :week_start_date,
      :week_end_date,
      :activity_title,
      :activity_description,
      :pdf_url,
      :participation_id
    ])
    |> validate_required([:week_number, :week_start_date, :week_end_date, :activity_title, :participation_id])
    |> validate_number(:week_number, greater_than: 0)
    |> validate_week_dates()
  end

  def feedback_changeset(weekly_log, attrs) do
    weekly_log
    |> cast(attrs, [:feedback])
  end

  defp validate_week_dates(changeset) do
    start_date = get_field(changeset, :week_start_date)
    end_date = get_field(changeset, :week_end_date)

    cond do
      is_nil(start_date) || is_nil(end_date) ->
        changeset

      Date.compare(end_date, start_date) != :gt ->
        add_error(changeset, :week_end_date, "tanggal akhir harus setelah tanggal mulai")

      true ->
        changeset
    end
  end
end
