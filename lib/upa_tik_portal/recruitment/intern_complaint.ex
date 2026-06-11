defmodule UpaTikPortal.Recruitment.InternComplaint do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @valid_categories ~w(Fasilitas Teknis Lingkungan Lainnya)

  schema "intern_complaints" do
    field :category, :string
    field :content, :string
    field :is_resolved, :boolean, default: false

    belongs_to :participation, UpaTikPortal.Recruitment.InternshipParticipation,
      foreign_key: :participation_id,
      type: :binary_id

    timestamps(type: :utc_datetime)
  end

  def changeset(intern_complaint, attrs) do
    intern_complaint
    |> cast(attrs, [:category, :content, :participation_id])
    |> validate_required([:category, :content, :participation_id])
    |> validate_inclusion(:category, @valid_categories)
    |> validate_length(:content, min: 10, message: "minimal 10 karakter")
  end

  def resolve_changeset(intern_complaint, attrs) do
    intern_complaint
    |> cast(attrs, [:is_resolved])
    |> validate_required([:is_resolved])
  end
end
