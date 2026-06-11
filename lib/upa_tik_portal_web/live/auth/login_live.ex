defmodule UpaTikPortalWeb.Auth.LoginLive do
  use UpaTikPortalWeb, :live_view

  def mount(_params, session, socket) do
    current_user = get_user_from_session(session)

    if current_user do
      {:ok, push_navigate(socket, to: redirect_path(current_user))}
    else
      {:ok, assign(socket, :page_title, "Login - UPA TIK Portal")}
    end
  end

  defp get_user_from_session(%{"user_id" => id}) when not is_nil(id) do
    UpaTikPortal.Accounts.get_user(id)
  end

  defp get_user_from_session(_), do: nil

  defp redirect_path(%{role: "admin"}), do: ~p"/admin"
  defp redirect_path(%{role: "mentor"}), do: ~p"/mentor"
  defp redirect_path(_), do: ~p"/portal"
end
