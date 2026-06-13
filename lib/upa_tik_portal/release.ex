defmodule UpaTikPortal.Release do
  @moduledoc """
  Modul untuk menjalankan migrasi database dari dalam release binary (tanpa Mix).
  Digunakan saat deployment via Docker container.

  Contoh penggunaan:
    bin/upa_tik_portal eval "UpaTikPortal.Release.migrate"
  """
  @app :upa_tik_portal

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
