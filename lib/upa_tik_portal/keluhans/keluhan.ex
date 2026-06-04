defmodule UpaTikPortal.Keluhans.Keluhan do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "keluhans" do
    field :subject, :string
    field :description, :string
    field :status, :string, default: "baru"
    field :admin_notes, :string

    belongs_to :user, UpaTikPortal.Accounts.User
    has_many :messages, UpaTikPortal.Keluhans.Message

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(keluhan, attrs) do
    keluhan
    |> cast(attrs, [:subject, :description, :user_id])
    |> validate_required([:subject, :description, :user_id])
    |> validate_length(:subject, min: 5, max: 200, message: "harus antara 5-200 karakter")
    |> validate_length(:description, min: 10, message: "minimal 10 karakter")
  end

  def status_changeset(keluhan, attrs) do
    keluhan
    |> cast(attrs, [:status, :admin_notes])
    |> validate_required([:status])
    |> validate_inclusion(:status, ["baru", "diproses", "selesai"])
  end
end
