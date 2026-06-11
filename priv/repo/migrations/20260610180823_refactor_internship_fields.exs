defmodule UpaTikPortal.Repo.Migrations.RefactorInternshipFields do
  use Ecto.Migration

  def change do
    alter table(:internship_openings) do
      remove :department
      add :division_id, references(:divisions, on_delete: :nilify_all, type: :binary_id)
      add :start_date, :date
      add :end_date, :date
    end

    alter table(:internship_participations) do
      remove :start_date
      remove :end_date
      remove :university
    end
  end
end
