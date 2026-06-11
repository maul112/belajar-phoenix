defmodule UpaTikPortal.Recruitment.InternshipParticipation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "internship_participations" do
    field :cv_url, :string
    field :portfolio_url, :string
    field :surat_pengantar_url, :string
    field :transkrip_nilai_url, :string
    field :major, :string
    field :status, :string, default: "applied"
    field :deleted_at, :utc_datetime

    belongs_to :user, UpaTikPortal.Accounts.User, foreign_key: :user_id, type: :binary_id
    belongs_to :internship_opening, UpaTikPortal.Recruitment.InternshipOpening, foreign_key: :opening_id, type: :binary_id
    belongs_to :mentor, UpaTikPortal.Accounts.User, foreign_key: :mentor_id, type: :binary_id

    has_many :weekly_logs, UpaTikPortal.Recruitment.WeeklyLog, foreign_key: :participation_id
    has_many :presences, UpaTikPortal.Recruitment.Presence, foreign_key: :participation_id
    has_many :intern_complaints, UpaTikPortal.Recruitment.InternComplaint, foreign_key: :participation_id

    timestamps(type: :utc_datetime)
  end

  def changeset(internship_participation, attrs) do
    internship_participation
    |> cast(attrs, [:cv_url, :portfolio_url, :surat_pengantar_url, :transkrip_nilai_url, :major, :status, :user_id, :opening_id])
    |> validate_required([:major, :user_id, :opening_id])
  end

  @valid_statuses ~w(applied interview accepted rejected)

  def status_changeset(internship_participation, attrs) do
    internship_participation
    |> cast(attrs, [:status])
    |> validate_required([:status])
    |> validate_inclusion(:status, @valid_statuses)
  end

  def mentor_changeset(internship_participation, attrs) do
    internship_participation
    |> cast(attrs, [:mentor_id])
  end
end
