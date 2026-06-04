defmodule UpaTikPortal.Keluhans.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "keluhan_messages" do
    field :content, :string
    field :is_admin, :boolean, default: false

    belongs_to :keluhan, UpaTikPortal.Keluhans.Keluhan
    belongs_to :user, UpaTikPortal.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :is_admin, :keluhan_id, :user_id])
    |> validate_required([:content, :keluhan_id])
    |> validate_length(:content, min: 1)
  end
end
