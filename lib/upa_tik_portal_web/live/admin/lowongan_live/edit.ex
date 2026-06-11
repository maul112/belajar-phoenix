defmodule UpaTikPortalWeb.Admin.LowonganLive.Edit do
  use UpaTikPortalWeb, :live_view
  alias UpaTikPortal.Recruitment.InternshipOpeningService
  alias UpaTikPortal.Recruitment.DivisionService

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    opening = InternshipOpeningService.get_internship_opening!(id)
    changeset = InternshipOpeningService.change_internship_opening(opening)

    divisions = DivisionService.list_divisions() |> Enum.map(&{&1.name, &1.id})

    {:ok,
     socket
     |> assign(:page_title, "Edit Lowongan")
     |> assign(:opening, opening)
     |> assign(:divisions, divisions)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"internship_opening" => params}, socket) do
    changeset =
      socket.assigns.opening
      |> InternshipOpeningService.change_internship_opening(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"internship_opening" => params}, socket) do
    case InternshipOpeningService.update_internship_opening(socket.assigns.opening, params) do
      {:ok, _opening} ->
        {:noreply,
         socket
         |> put_flash(:info, "Lowongan berhasil diperbarui")
         |> push_navigate(to: ~p"/admin/lowongan")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
