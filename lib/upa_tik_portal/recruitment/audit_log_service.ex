defmodule UpaTikPortal.Recruitment.AuditLogService do
  import Ecto.Query, warn: false
  alias UpaTikPortal.Repo
  alias UpaTikPortal.Recruitment.AuditLog

  @doc """
  Mencatat perubahan status partisipasi ke dalam audit log.
  """
  def log_status_change(participation_id, changed_by_id, from_status, to_status, notes \\ nil) do
    %AuditLog{}
    |> AuditLog.changeset(%{
      "participation_id" => participation_id,
      "changed_by_id" => changed_by_id,
      "from_status" => from_status,
      "to_status" => to_status,
      "notes" => notes
    })
    |> Repo.insert()
  end

  @doc """
  Mengambil history audit log untuk suatu partisipasi.
  """
  def list_by_participation(participation_id) do
    Repo.all(
      from a in AuditLog,
      where: a.participation_id == ^participation_id,
      preload: [:changed_by],
      order_by: [desc: a.inserted_at]
    )
  end
end
