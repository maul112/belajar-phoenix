defmodule UpaTikPortalWeb.Home.Magang.Complaint.Index do
  use UpaTikPortalWeb, :live_view

  on_mount {UpaTikPortalWeb.UserAuth, :mount_current_user}

  alias UpaTikPortal.Recruitment.InternshipParticipationService
  alias UpaTikPortal.Recruitment.InternComplaintService
  alias UpaTikPortal.Recruitment.InternComplaint

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    participation = InternshipParticipationService.get_latest_accepted_participation(user.id)

    if is_nil(participation) do
      {:ok,
       socket
       |> put_flash(:error, "Kamu tidak memiliki magang aktif atau riwayat magang.")
       |> push_navigate(to: ~p"/portal/magang")}
    else
      is_completed = participation.internship_opening.end_date && Date.compare(UpaTikPortalWeb.Helpers.TimeHelper.today_wib(), participation.internship_opening.end_date) == :gt
      complaints = InternComplaintService.list_by_participation(participation.id)

      form = InternComplaintService.change_complaint() |> to_form()

      {:ok,
       socket
       |> assign(:page_title, "Keluhan Magang")
       |> assign(:participation, participation)
       |> assign(:is_completed, is_completed)
       |> assign(:form, form)
       |> assign(:show_form, false)
       |> stream(:complaints, complaints)}
    end
  end

  @impl true
  def handle_event("toggle_form", _params, socket) do
    {:noreply, assign(socket, :show_form, !socket.assigns.show_form)}
  end

  @impl true
  def handle_event("validate", %{"intern_complaint" => params}, socket) do
    form =
      %InternComplaint{}
      |> InternComplaint.changeset(params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, :form, form)}
  end

  @impl true
  def handle_event("submit", %{"intern_complaint" => params}, socket) do
    participation = socket.assigns.participation

    case InternComplaintService.create_complaint(participation.id, params) do
      {:ok, complaint} ->
        form = InternComplaintService.change_complaint() |> to_form()

        {:noreply,
         socket
         |> put_flash(:info, "Keluhan berhasil dikirim.")
         |> stream_insert(:complaints, complaint, at: 0)
         |> assign(:form, form)
         |> assign(:show_form, false)}

      {:error, reason} when is_binary(reason) ->
        {:noreply, put_flash(socket, :error, reason)}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp category_color("Fasilitas"), do: "bg-purple-100 text-purple-700"
  defp category_color("Teknis"), do: "bg-blue-100 text-blue-700"
  defp category_color("Lingkungan"), do: "bg-green-100 text-green-700"
  defp category_color("Lainnya"), do: "bg-slate-100 text-slate-700"
  defp category_color(_), do: "bg-slate-100 text-slate-700"
end
