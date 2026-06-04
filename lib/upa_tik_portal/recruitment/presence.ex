defmodule UpaTikPortal.Recruitment.Presence do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @valid_statuses ~w(present sick permit absent)

  schema "presences" do
    field :date, :date
    field :check_in, :time
    field :check_out, :time
    field :status, :string, default: "present"
    field :notes, :string

    belongs_to :participation, UpaTikPortal.Recruitment.InternshipParticipation,
      foreign_key: :participation_id,
      type: :binary_id

    timestamps(type: :utc_datetime)
  end

  def changeset(presence, attrs) do
    presence
    |> cast(attrs, [:date, :check_in, :check_out, :status, :notes, :participation_id])
    |> validate_required([:date, :status, :participation_id])
    |> validate_inclusion(:status, @valid_statuses)
  end

  def check_in_changeset(presence, attrs) do
    presence
    |> cast(attrs, [:check_in, :status])
    |> validate_required([:check_in])
  end

  def check_out_changeset(presence, attrs) do
    presence
    |> cast(attrs, [:check_out])
    |> validate_required([:check_out])
  end
end
