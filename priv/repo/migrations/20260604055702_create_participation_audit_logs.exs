defmodule UpaTikPortal.Repo.Migrations.CreateParticipationAuditLogs do
  use Ecto.Migration

  def change do
    create table(:participation_audit_logs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :participation_id, references(:internship_participations, on_delete: :delete_all, type: :binary_id), null: false
      add :changed_by_id, references(:users, on_delete: :nilify_all, type: :binary_id)
      add :from_status, :string
      add :to_status, :string, null: false
      add :notes, :text

      timestamps(type: :utc_datetime)
    end

    create index(:participation_audit_logs, [:participation_id])
    create index(:participation_audit_logs, [:changed_by_id])
  end
end
