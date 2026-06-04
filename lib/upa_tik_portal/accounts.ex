defmodule UpaTikPortal.Accounts do
  @moduledoc """
  Context untuk manajemen akun pengguna.
  """
  import Ecto.Query, warn: false
  alias UpaTikPortal.Repo
  alias UpaTikPortal.Accounts.User

  @admin_emails ["yoelflemming8@gmail.com", "kingkapol10@gmail.com", ]

  @doc """
  Mendapatkan atau membuat user dari data Google OAuth.
  Digunakan saat callback dari Ueberauth.
  """
  def get_or_create_user_from_google(%{info: info, uid: uid}) do
        role = if info.email in @admin_emails, do: "admin", else: "mahasiswa"

    case Repo.get_by(User, google_uid: uid) do
      nil ->
        # Cek apakah email sudah ada (user registrasi manual sebelumnya)                                                                                       
        case Repo.get_by(User, email: info.email) do
          nil ->
            %User{}
            |> User.changeset(%{
             name: info.name,
              email: info.email,
              google_uid: uid,
              role: role
            })
            |>  Repo.insert() 

          existing_user ->
            existing_user
            |> User.changeset(%{google_uid: uid, name: info.name, role: role})
            |> Repo.update()
        end

      existing_user ->
        # Pastikan role diupdate jika email masuk daftar admin belakangan
        existing_user
        |> User.changeset(%{role: role})
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
