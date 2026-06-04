defmodule UpaTikPortal.Repo.Migrations.CreateWeeklyLogs do
  use Ecto.Migration

  def change do
    create table(:weekly_logs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :participation_id, references(:internship_participations, on_delete: :delete_all, type: :binary_id), null: false
      add :week_number, :integer, null: false
      add :week_start_date, :date, null: false
      add :week_end_date, :date, null: false
      add :activity_title, :string, null: false
      add :activity_description, :text
      add :feedback, :text

      timestamps(type: :utc_datetime)
    end

    create index(:weekly_logs, [:participation_id])
    create unique_index(:weekly_logs, [:participation_id, :week_number], name: :weekly_logs_participation_week_unique)
  end
end
