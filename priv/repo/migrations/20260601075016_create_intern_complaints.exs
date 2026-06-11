defmodule UpaTikPortal.Repo.Migrations.CreateInternComplaints do
  use Ecto.Migration

  def change do
    create table(:intern_complaints, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :participation_id, references(:internship_participations, on_delete: :delete_all, type: :binary_id), null: false
      add :category, :string, null: false
      add :content, :text, null: false
      add :is_resolved, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:intern_complaints, [:participation_id])
  end
end
