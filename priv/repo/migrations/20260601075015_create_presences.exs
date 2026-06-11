defmodule UpaTikPortal.Repo.Migrations.CreatePresences do
  use Ecto.Migration

  def change do
    create table(:presences, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :participation_id, references(:internship_participations, on_delete: :delete_all, type: :binary_id), null: false
      add :date, :date, null: false
      add :check_in, :time
      add :check_out, :time
      add :status, :string, default: "present", null: false
      add :notes, :text

      timestamps(type: :utc_datetime)
    end

    create index(:presences, [:participation_id])
    create unique_index(:presences, [:participation_id, :date], name: :presences_participation_date_unique)
  end
end
