# lib/upa_tik_portal_web/live/admin/lowongan_live/new.ex
defmodule UpaTikPortalWeb.Admin.LowonganLive.New do
  use UpaTikPortalWeb, :live_view
  alias UpaTikPortal.Recruitment.InternshipOpeningService
  alias UpaTikPortal.Recruitment.InternshipOpening
  alias UpaTikPortal.Recruitment.DivisionService

  @impl true
  def mount(_params, _session, socket) do
    # Siapkan changeset kosong
    changeset = InternshipOpeningService.change_internship_opening(%InternshipOpening{})

    # Ambil list divisi untuk dropdown, format menjadi list tuple {nama, id}
    divisions = DivisionService.list_divisions() |> Enum.map(&{&1.name, &1.id})

    {:ok,
     socket
     |> assign(:page_title, "Tambah Lowongan Baru")
     |> assign(:divisions, divisions)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"internship_opening" => params}, socket) do
    changeset =
      %InternshipOpening{}
      |> InternshipOpeningService.change_internship_opening(params)
      |> Map.put(:action, :validate)
    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"internship_opening" => params}, socket) do
    case InternshipOpeningService.create_internship_opening(params) do
      {:ok, _opening} ->
        {:noreply,
         socket
         |> put_flash(:info, "Lowongan berhasil diterbitkan!")
         |> push_navigate(to: ~p"/admin/lowongan")} # Kembali ke daftar

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
