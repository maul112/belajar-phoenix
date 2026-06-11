defmodule UpaTikPortalWeb.Home.Magang.Index do
  use UpaTikPortalWeb, :live_view

  on_mount {UpaTikPortalWeb.UserAuth, :mount_current_user}

  alias UpaTikPortal.Recruitment.InternshipParticipationService

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    participations = InternshipParticipationService.get_participation_by_user(user.id)
                     |> sort_participations()

    {:ok,
     socket
     |> assign(:page_title, "Magang Saya")
     |> assign(:participations, participations)
     |> assign(:search, "")
     |> assign(:status, "")}
  end

  @impl true
  def handle_event("filter", params, socket) do
    user = socket.assigns.current_user
    search = params["search"] || ""
    status = params["status"] || ""
    
    opts = [search: search, status: status]
    participations = InternshipParticipationService.get_participation_by_user(user.id, opts)
                     |> sort_participations()

    {:noreply,
     socket
     |> assign(:participations, participations)
     |> assign(:search, search)
     |> assign(:status, status)}
  end

  defp status_badge(status) do
    case status do
      "applied" -> "bg-yellow-100 text-yellow-800 border-yellow-200"
      "interview" -> "bg-blue-100 text-blue-800 border-blue-200"
      "accepted" -> "bg-green-100 text-green-800 border-green-200"
      "rejected" -> "bg-red-100 text-red-800 border-red-200"
      _ -> "bg-slate-100 text-slate-800 border-slate-200"
    end
  end

  defp status_label(status) do
    case status do
      "applied" -> "Menunggu"
      "interview" -> "Wawancara"
      "accepted" -> "Diterima"
      "rejected" -> "Ditolak"
      _ -> "Tidak Diketahui"
    end
  end

  defp sort_participations(participations) do
    Enum.sort_by(participations, fn p ->
      {if(p.status == "accepted", do: 1, else: 0), NaiveDateTime.to_erl(p.inserted_at)}
    end, :desc)
  end

end
