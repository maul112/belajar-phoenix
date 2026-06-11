defmodule UpaTikPortalWeb.Home.Setting.Index do
  use UpaTikPortalWeb, :live_view
  on_mount {UpaTikPortalWeb.UserAuth, :mount_current_user}

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    {:ok, assign(socket, :user, user)}
  end
end
