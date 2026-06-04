defmodule UpaTikPortalWeb.PortalController do
  use UpaTikPortalWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: ~p"/portal/ajukan")
  end
end
