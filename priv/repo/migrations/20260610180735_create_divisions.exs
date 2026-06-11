defmodule UpaTikPortal.Repo.Migrations.CreateDivisions do
  use Ecto.Migration

  def change do
    create table(:divisions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text

      timestamps(type: :utc_datetime)
    end
    
    create unique_index(:divisions, [:name])
  end
end
