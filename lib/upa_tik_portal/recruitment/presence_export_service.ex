defmodule UpaTikPortal.Recruitment.PresenceExportService do
  alias UpaTikPortal.Recruitment.PresenceService

  @doc """
  Menghasilkan konten CSV dari daftar partisipasi dan presensinya.
  """
  def generate_csv do
    # Ambil semua data presensi untuk intern yang diterima
    interns = UpaTikPortal.Recruitment.InternshipParticipationService.list_active_interns()
    
    header = "NIM,Nama,Lowongan,Tanggal,Check In,Check Out,Status,Notes\n"
    
    rows = Enum.map(interns, fn intern ->
      presences = PresenceService.list_by_participation(intern.id)
      
      Enum.map(presences, fn p ->
        check_in_str = if p.check_in, do: Time.to_string(p.check_in), else: "-"
        check_out_str = if p.check_out, do: Time.to_string(p.check_out), else: "-"
        notes = if p.notes, do: String.replace(p.notes, "\n", " "), else: ""
        
        # Escape quotes di csv
        escaped_notes = "\"#{String.replace(notes, "\"", "\"\"")}\""
        
        "#{intern.user.nim},#{intern.user.name},#{intern.internship_opening.title},#{Date.to_string(p.date)},#{check_in_str},#{check_out_str},#{p.status},#{escaped_notes}"
      end)
      |> Enum.join("\n")
    end)
    |> Enum.reject(&(&1 == ""))
    |> Enum.join("\n")

    header <> if(rows == "", do: "", else: rows <> "\n")
  end
end
