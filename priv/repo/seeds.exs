# Script untuk mengisi data awal database.
# Jalankan dengan: mix run priv/repo/seeds.exs

alias UpaTikPortal.Repo
alias UpaTikPortal.Accounts.User
alias UpaTikPortal.Recruitment.InternshipOpening
alias UpaTikPortal.Recruitment.Division

# Buat admin pertama jika belum ada
admin_email = System.get_env("ADMIN_EMAIL") || "admin@upa-tik.ac.id"

case Repo.get_by(User, email: admin_email) do
  nil ->
    %User{}
    |> User.changeset(%{
      name: "Administrator UPA TIK",
      email: admin_email,
      role: "admin"
    })
    |> Repo.insert!()

    IO.puts("✅ Admin user created: #{admin_email}")

  _existing ->
    IO.puts("ℹ️  Admin user already exists: #{admin_email}")
end

# Buat Divisions
divisions_data = [
  %{name: "Pusat Data dan Informasi", description: "Mengelola server dan aplikasi internal UPA TIK."},
  %{name: "Divisi Mobile Learning", description: "Pengembangan dan pemeliharaan aplikasi mobile di UPA TIK."},
  %{name: "Laboratorium Sains Data", description: "Eksplorasi dan analitik data cerdas."},
  %{name: "Infrastruktur Jaringan", description: "Manajemen dan maintenance jaringan kabel maupun nirkabel kampus."},
  %{name: "Creative Media Center", description: "Menghasilkan UI/UX desain, aset grafis, dan animasi."}
]

Enum.each(divisions_data, fn data ->
  case Repo.get_by(Division, name: data.name) do
    nil -> Repo.insert!(struct(Division, data))
    _ -> :ok
  end
end)

divisions = Repo.all(Division) |> Enum.into(%{}, fn d -> {d.name, d.id} end)

# Buat Internship Openings
today = Date.utc_today()

openings = [
  %{
    title: "Fullstack Web Developer",
    description: "Membangun sistem informasi internal menggunakan Laravel dan Livewire.",
    division_id: divisions["Pusat Data dan Informasi"],
    quota: 5,
    is_active: true,
    closing_date: Date.add(today, 10),
    start_date: Date.add(today, 20),
    end_date: Date.add(today, 110)
  },
  %{
    title: "Mobile App Developer (Flutter)",
    description: "Mengembangkan aplikasi presensi mahasiswa berbasis Android dan iOS.",
    division_id: divisions["Divisi Mobile Learning"],
    quota: 3,
    is_active: true,
    closing_date: Date.add(today, 15),
    start_date: Date.add(today, 30),
    end_date: Date.add(today, 120)
  },
  %{
    title: "Data Scientist Intern",
    description: "Melakukan analisis data akademik dan pembuatan model prediksi kelulusan.",
    division_id: divisions["Laboratorium Sains Data"],
    quota: 2,
    is_active: true,
    closing_date: Date.add(today, 10),
    start_date: Date.add(today, 25),
    end_date: Date.add(today, 115)
  },
  %{
    title: "Network & Security Support",
    description: "Membantu maintenance jaringan fiber optic dan pengamanan server kampus.",
    division_id: divisions["Infrastruktur Jaringan"],
    quota: 4,
    is_active: true,
    closing_date: Date.add(today, 20),
    start_date: Date.add(today, 40),
    end_date: Date.add(today, 130)
  },
  %{
    title: "UI/UX Designer",
    description: "Merancang antarmuka untuk portal layanan mahasiswa baru.",
    division_id: divisions["Creative Media Center"],
    quota: 2,
    is_active: true,
    closing_date: Date.add(today, 15),
    start_date: Date.add(today, 25),
    end_date: Date.add(today, 115)
  }
]

Enum.each(openings, fn data ->
  case Repo.get_by(InternshipOpening, title: data.title) do
    nil ->
      Repo.insert!(struct(InternshipOpening, data))
    existing ->
      existing
      |> InternshipOpening.changeset(data)
      |> Repo.update!()
      IO.puts "Opening '#{data.title}' berhasil diupdate."
  end
end)

IO.puts "✅ Seeding Divisions dan Internship Openings selesai!"
