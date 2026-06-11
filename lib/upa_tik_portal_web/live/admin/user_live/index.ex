defmodule UpaTikPortalWeb.Admin.UserLive.Index do
  use UpaTikPortalWeb, :live_view

  alias UpaTikPortal.Accounts

  def mount(_params, _session, socket) do
    users = Accounts.list_users()
    {:ok, assign(socket, users: users, page_title: "Daftar Pengguna – UPA TIK Admin")}
  end

  def handle_event("change_role", %{"id" => id, "role" => role}, socket) do
    user = Accounts.get_user!(id)
    
    case Accounts.update_user_role(user, role) do
      {:ok, _updated_user} ->
        users = Accounts.list_users()
        {:noreply, 
         socket 
         |> assign(users: users)
         |> put_flash(:info, "Role pengguna berhasil diubah menjadi #{String.capitalize(role)}.")}
      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Gagal mengubah role pengguna.")}
    end
  end

  defp role_class("admin"), do: "bg-slate-900 text-white border border-slate-800"
  defp role_class("mentor"), do: "bg-emerald-50 text-emerald-600 border border-emerald-100"
  defp role_class(_), do: "bg-indigo-50 text-indigo-600 border border-indigo-100"
end
