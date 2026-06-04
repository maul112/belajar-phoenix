defmodule UpaTikPortal.Repo.Migrations.CreateKeluhanMessages do
  use Ecto.Migration

  def change do
    create table(:keluhan_messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :content, :text, null: false
      add :is_admin, :boolean, default: false, null: false
      add :keluhan_id, references(:keluhans, on_delete: :delete_all, type: :binary_id), null: false
      add :user_id, references(:users, on_delete: :nilify_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:keluhan_messages, [:keluhan_id])
    create index(:keluhan_messages, [:user_id])
  end
end
