defmodule UpaTikPortal.Repo.Migrations.AddDeletedAtToInternshipParticipations do
  use Ecto.Migration

  def change do
    alter table(:internship_participations) do
      add :deleted_at, :utc_datetime, null: true
    end
  end
end
