defmodule UpaTikPortalWeb.Admin.DivisionLive.Index do
  use UpaTikPortalWeb, :live_view
  alias UpaTikPortal.Recruitment.DivisionService
  alias UpaTikPortal.Recruitment.Division

  @impl true
  def mount(_params, _session, socket) do
    {:ok, 
     socket
     |> assign(:divisions, DivisionService.list_divisions())
     |> assign(:page_title, "Kelola Divisi")
     |> assign(:form, to_form(DivisionService.change_division(%Division{})))
     |> assign(:edit_id, nil)}
  end

  @impl true
  def handle_event("validate", %{"division" => params}, socket) do
    division = if socket.assigns.edit_id, do: DivisionService.get_division!(socket.assigns.edit_id), else: %Division{}
    changeset = DivisionService.change_division(division, params) |> Map.put(:action, :validate)
    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"division" => params}, socket) do
    if socket.assigns.edit_id do
      division = DivisionService.get_division!(socket.assigns.edit_id)
      case DivisionService.update_division(division, params) do
        {:ok, _} ->
          {:noreply, 
           socket
           |> put_flash(:info, "Divisi berhasil diubah.")
           |> assign(:divisions, DivisionService.list_divisions())
           |> assign(:form, to_form(DivisionService.change_division(%Division{})))
           |> assign(:edit_id, nil)}
        {:error, changeset} ->
          {:noreply, assign(socket, :form, to_form(changeset))}
      end
    else
      case DivisionService.create_division(params) do
        {:ok, _} ->
          {:noreply, 
           socket
           |> put_flash(:info, "Divisi berhasil ditambahkan.")
           |> assign(:divisions, DivisionService.list_divisions())
           |> assign(:form, to_form(DivisionService.change_division(%Division{})))}
        {:error, changeset} ->
          {:noreply, assign(socket, :form, to_form(changeset))}
      end
    end
  end

  @impl true
  def handle_event("edit", %{"id" => id}, socket) do
    division = DivisionService.get_division!(id)
    {:noreply, 
     socket 
     |> assign(:edit_id, id)
     |> assign(:form, to_form(DivisionService.change_division(division)))}
  end

  @impl true
  def handle_event("cancel_edit", _, socket) do
    {:noreply, 
     socket 
     |> assign(:edit_id, nil)
     |> assign(:form, to_form(DivisionService.change_division(%Division{})))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    division = DivisionService.get_division!(id)
    case DivisionService.delete_division(division) do
      {:ok, _} ->
        {:noreply, 
         socket 
         |> put_flash(:info, "Divisi dihapus.") 
         |> assign(:divisions, DivisionService.list_divisions())}
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Gagal menghapus divisi.")}
    end
  end
end
