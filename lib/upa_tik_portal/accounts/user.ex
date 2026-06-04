defmodule UpaTikPortal.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :name, :string
    field :email, :string
    field :role, :string, default: "mahasiswa"
    field :google_uid, :string
    field :avatar_url, :string

    has_many :email_requests, UpaTikPortal.Requests.EmailRequest
    has_many :participations, UpaTikPortal.Recruitment.InternshipParticipation, foreign_key: :user_id
    has_many :mentored_participations, UpaTikPortal.Recruitment.InternshipParticipation, foreign_key: :mentor_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :role, :google_uid, :avatar_url])
    |> validate_required([:name, :email])
    |> validate_inclusion(:role, ["mahasiswa", "admin", "mentor"])
    |> unique_constraint(:email)
    |> unique_constraint(:google_uid)
  end
end
