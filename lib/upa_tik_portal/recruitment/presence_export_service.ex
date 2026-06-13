defmodule UpaTikPortal.Recruitment.PresenceExportService do
  alias UpaTikPortal.Recruitment.PresenceService

  @doc """
  Menghasilkan binary ZIP yang berisi CSV terpisah per divisi.
  """
  def generate_zip_by_division do
    # Ambil semua data presensi untuk intern yang diterima
    interns = UpaTikPortal.Recruitment.InternshipParticipationService.list_active_interns()
    
    header = "Universitas,Jurusan,Nama,Lowongan,Tanggal,Check In,Check Out,Status,Notes\n"
    
    # Kelompokkan intern berdasarkan nama divisi
    grouped_interns = Enum.group_by(interns, fn intern ->
      if intern.internship_opening && intern.internship_opening.division do
        intern.internship_opening.division.name
      else
        "Lain_lain"
      end
    end)
    
    files = Enum.map(grouped_interns, fn {division_name, division_interns} ->
      rows = Enum.map(division_interns, fn intern ->
        presences = PresenceService.list_by_participation(intern.id)
        
        Enum.map(presences, fn p ->
          check_in_str = if p.check_in, do: Time.to_string(p.check_in), else: "-"
          check_out_str = if p.check_out, do: Time.to_string(p.check_out), else: "-"
          notes = if p.notes, do: String.replace(p.notes, "\n", " "), else: ""
          
          # Escape quotes di csv
          escaped_notes = "\"#{String.replace(notes, "\"", "\"\"")}\""
          
          lowongan_title = if intern.internship_opening, do: intern.internship_opening.title, else: "-"
          
          "\"-\",\"#{intern.major}\",\"#{intern.user.name}\",\"#{lowongan_title}\",#{Date.to_string(p.date)},#{check_in_str},#{check_out_str},#{p.status},#{escaped_notes}"
        end)
        |> Enum.join("\n")
      end)
      |> Enum.reject(&(&1 == ""))
      |> Enum.join("\n")
      
      csv_content = header <> if(rows == "", do: "", else: rows <> "\n")
      
      # Nama file dibuat aman dari karakter aneh
      safe_filename = String.replace(division_name, ~r/[^A-Za-z0-9_]/, "_") <> ".csv"
      
      {to_charlist(safe_filename), csv_content}
    end)
    
    # Jika kosong, tetap buat zip dengan file kosong
    files = if files == [], do: [{~c"kosong.csv", "Tidak ada data aktif"}], else: files

    {:ok, {_filename, zip_binary}} = :zip.create(~c"rekap_presensi.zip", files, [:memory])
    zip_binary
  end
end
