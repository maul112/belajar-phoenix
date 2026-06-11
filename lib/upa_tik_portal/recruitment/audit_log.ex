defmodule UpaTikPortal.Recruitment.AuditLog do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "participation_audit_logs" do
    field :from_status, :string
    field :to_status, :string
    field :notes, :string

    belongs_to :participation, UpaTikPortal.Recruitment.InternshipParticipation
    belongs_to :changed_by, UpaTikPortal.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(audit_log, attrs) do
    audit_log
    |> cast(attrs, [:participation_id, :changed_by_id, :from_status, :to_status, :notes])
    |> validate_required([:participation_id, :to_status])
  end
end
