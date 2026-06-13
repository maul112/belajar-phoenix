defmodule UpaTikPortal.Accounts do
  @moduledoc """
  Context untuk manajemen akun pengguna.
  """
  import Ecto.Query, warn: false
  alias UpaTikPortal.Repo
  alias UpaTikPortal.Accounts.User

  @doc """
  Mendapatkan atau membuat user dari data Google OAuth.
  Digunakan saat callback dari Ueberauth.
  """
  def get_or_create_user_from_google(%{info: info, uid: uid}) do
    admin_emails =
      (System.get_env("ADMIN_EMAILS") || "")
      |> String.split(",", trim: true)
      |> Enum.map(&String.trim/1)
    IO.inspect(admin_emails)

    base_role = if info.email in admin_emails, do: "admin", else: "mahasiswa"

    case Repo.get_by(User, google_uid: uid) || Repo.get_by(User, email: info.email) do
      nil ->
        %User{}
        |> User.changeset(%{
          name: info.name,
          email: info.email,
          google_uid: uid,
          avatar_url: Map.get(info, :image),
          role: base_role
        })
        |> Repo.insert()

      existing_user ->
        # Jangan downgrade role jika user sudah menjadi mentor atau admin
        final_role =
          if base_role == "admin" do
            "admin"
          else
            if existing_user.role in ["admin", "mentor"], do: existing_user.role, else: base_role
          end

        existing_user
        |> User.changeset(%{
          google_uid: uid,
          name: info.name,
          avatar_url: Map.get(info, :image) || existing_user.avatar_url,
          role: final_role
        })
        |> Repo.update()
    end
  end


  def get_user!(id), do: Repo.get!(User, id)

  def get_user(id), do: Repo.get(User, id)

  def list_users, do: Repo.all(User)

  def update_user_role(%User{} = user, role) do
    user
    |> User.changeset(%{role: role})
    |> Repo.update()
  end

  @doc "Daftar semua user dengan role mentor (untuk select assign mentor)"
  def list_mentors do
    Repo.all(from u in User, where: u.role == "mentor", order_by: u.name)
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc "Menampilkan daftar user yang terdaftar ke terminal secara rapi"
  def print_all_users do
    users = list_users()
    IO.puts("\n=== DAFTAR USER TERDAFTAR ===")

    Enum.each(users, fn user ->
      status = if user.role == "admin", do: "⭐️ ADMIN", else: "👤 USER"
      IO.puts("#{status} | #{user.email} | #{user.name}")
    end)

    IO.puts("=============================\n")
    :ok
  end
end
