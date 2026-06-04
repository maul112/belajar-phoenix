defmodule UpaTikPortal.Keluhans do
  @moduledoc """
  The Keluhans context - handles user complaints/feedback.
  """

  import Ecto.Query, warn: false
  alias UpaTikPortal.Repo
  alias UpaTikPortal.Keluhans.Keluhan
  alias UpaTikPortal.Keluhans.Message

  @pubsub UpaTikPortal.PubSub

  @doc "Create a new keluhan submitted by a user."
  def create_keluhan(user_id, attrs) do
    %Keluhan{}
    |> Keluhan.changeset(Map.put(attrs, "user_id", user_id))
    |> Repo.insert()
  end

  @doc "List all keluhans (for admin), ordered by newest first."
  def list_keluhans do
    Keluhan
    |> order_by([k], desc: k.inserted_at)
    |> preload(:user)
    |> Repo.all()
  end

  @doc "List keluhans submitted by a specific user."
  def list_keluhans_by_user(user_id) do
    Keluhan
    |> where([k], k.user_id == ^user_id)
    |> order_by([k], desc: k.inserted_at)
    |> preload(messages: [:user])
    |> Repo.all()
  end

  @doc "Get a single keluhan by id."
  def get_keluhan!(id), do: Repo.get!(Keluhan, id) |> Repo.preload(:user)

  @doc "Admin updates the status of a keluhan."
  def update_keluhan_status(keluhan, attrs) do    
    keluhan
    |> Keluhan.status_changeset(attrs)
    |> Repo.update()
  end

  @doc "Count keluhans grouped by status (for dashboard stats)."
  def stats do
    Keluhan
    |> group_by([k], k.status)
    |> select([k], {k.status, count(k.id)})
    |> Repo.all()
    |> Map.new()
  end

  def subscribe(keluhan_id) do
    Phoenix.PubSub.subscribe(@pubsub, "keluhan_#{keluhan_id}")
  end

  defp broadcast({:ok, message}, event) do
    Phoenix.PubSub.broadcast(@pubsub, "keluhan_#{message.keluhan_id}", {event, message})
    {:ok, message}
  end

  @doc "Get a single keluhan by id, preloaded with user and messages."
  def get_keluhan_with_messages!(id) do
    Keluhan
    |> Repo.get!(id)
    |> Repo.preload(:user)
    |> Repo.preload(messages: [:user])
  end

  @doc "Create a new message in a keluhan."
  def create_message(attrs) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, msg} ->
        # Preload user so the UI can display sender info
        msg = Repo.preload(msg, :user)
        broadcast({:ok, msg}, :new_message)
      error ->
        error
    end
  end
end
