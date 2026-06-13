alias UpaTikPortal.Repo
alias UpaTikPortal.Recruitment.InternshipParticipation
alias UpaTikPortal.Recruitment.Presence

user_id = "b9f71aa2-ab67-4cfc-a0eb-d84b9ab887dc"

participation = Repo.get_by(InternshipParticipation, user_id: user_id, status: "accepted")

if participation do
  start_date = ~D[2026-06-12]
  end_date = ~D[2026-06-24]

  dates = Date.range(start_date, end_date)

  Enum.each(dates, fn date ->
    # Hanya generate untuk hari kerja (Senin-Jumat)
    if Date.day_of_week(date) <= 5 do
      # check_in antara 07:00 dan 08:00
      check_in = Time.new!(Enum.random(7..8), Enum.random(0..59), Enum.random(0..59))
      # check_out antara 16:00 dan 17:00
      check_out = Time.new!(Enum.random(16..17), Enum.random(0..59), Enum.random(0..59))
      
      # 80% hadir, sisanya sakit atau izin
      status = Enum.random(["present", "present", "present", "present", "sick", "permit"])
      
      check_in_time = if status == "present", do: check_in, else: nil
      check_out_time = if status == "present", do: check_out, else: nil

      notes = case status do
        "sick" -> "Sakit tipes, surat dokter menyusul"
        "permit" -> "Izin ada acara keluarga mendadak"
        _ -> nil
      end

      # Hapus jika sudah ada (agar bisa di-run berulang)
      existing = Repo.get_by(Presence, participation_id: participation.id, date: date)
      if existing, do: Repo.delete!(existing)

      %Presence{}
      |> Presence.changeset(%{
        participation_id: participation.id,
        date: date,
        check_in: check_in_time,
        check_out: check_out_time,
        status: status,
        notes: notes
      })
      |> Repo.insert!()
    end
  end)

  IO.puts("Successfully seeded presence data for user #{user_id} from 12 June to 24 June 2026.")
else
  IO.puts("Error: Internship participation not found or user is not 'accepted'.")
end
