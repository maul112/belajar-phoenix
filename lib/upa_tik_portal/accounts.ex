defmodule UpaTikPortal.Accounts do
  @moduledoc """
  Context untuk manajemen akun pengguna.
  """
  import Ecto.Query, warn: false
  alias UpaTikPortal.Repo
  alias UpaTikPortal.Accounts.User

<<<<<<< HEAD
  @admin_emails ["yoelflemming8@gmail.com", "kingkapol10@gmail.com", ]

=======
  @admin_emails ["stokkgun7@gmail.com", "yoelflemming0@gmail.com", "230411100159@student.trunojoyo.ac.id"]
  # "tsukiaka313@gmail.com"
>>>>>>> 8eea5d7 (project 1 malam)
  @doc """
  Mendapatkan atau membuat user dari data Google OAuth.
  Digunakan saat callback dari Ueberauth.
  """
  def get_or_create_user_from_google(%{info: info, uid: uid}) do
<<<<<<< HEAD
        role = if info.email in @admin_emails, do: "admin", else: "mahasiswa"
=======
    base_role = if info.email in @admin_emails, do: "admin", else: "mahasiswa"
>>>>>>> 8eea5d7 (project 1 malam)

    case Repo.get_by(User, google_uid: uid) || Repo.get_by(User, email: info.email) do
      nil ->
<<<<<<< HEAD
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
=======
        %User{}
        |> User.changeset(%{
          name: info.name,
          email: info.email,
          google_uid: uid,
          avatar_url: Map.get(info, :image),
          role: base_role
        })
        |> Repo.insert()
>>>>>>> 8eea5d7 (project 1 malam)

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

<<<<<<< HEAD
=======
  @doc "Daftar semua user dengan role mentor (untuk select assign mentor)"
  def list_mentors do
    Repo.all(from u in User, where: u.role == "mentor", order_by: u.name)
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

>>>>>>> 8eea5d7 (project 1 malam)
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
