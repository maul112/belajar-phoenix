defmodule UpaTikPortal.Repo.Migrations.AddPdfUrlToWeeklyLogs do
  use Ecto.Migration

  def change do
    alter table(:weekly_logs) do
      add :pdf_url, :string
    end
  end
end
