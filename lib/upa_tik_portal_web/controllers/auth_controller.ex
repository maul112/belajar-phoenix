defmodule UpaTikPortalWeb.AuthController do
  use UpaTikPortalWeb, :controller

  plug Ueberauth

  alias UpaTikPortal.Accounts

  @doc "Redirect ke halaman Google untuk login"
  def request(conn, _params), do: conn

  @doc "Callback setelah Google OAuth selesai"
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case Accounts.get_or_create_user_from_google(auth) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "Selamat datang, #{user.name}!")
        |> redirect(to: redirect_after_login(user))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Gagal login. Silakan coba lagi.")
        |> redirect(to: ~p"/")
    end
  end

  def callback(%{assigns: %{ueberauth_failure: failure}} = conn, _params) do
    reason = failure.errors |> Enum.map(& &1.message) |> Enum.join(", ")

    conn
    |> put_flash(:error, "Login Google gagal: #{reason}")
    |> redirect(to: ~p"/")
  end

  @doc "Logout - hapus session"
  def delete(conn, _params) do
    conn
    |> clear_session()
    |> put_flash(:info, "Berhasil logout.")
    |> redirect(to: ~p"/")
  end

  def redirect_to_logout(conn, _params) do
    redirect(conn, to: ~p"/auth/logout")
  end

  defp redirect_after_login(user) do
    case user.role do
      "admin" -> ~p"/admin"
      "mentor" -> ~p"/mentor"
      _ -> ~p"/portal/"
    end
  end
end
