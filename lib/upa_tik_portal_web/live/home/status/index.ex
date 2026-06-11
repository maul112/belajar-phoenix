defmodule UpaTikPortalWeb.Home.Status.Index do
  use UpaTikPortalWeb, :live_view

  alias UpaTikPortal.Requests
  alias UpaTikPortal.Keluhans

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    user = UpaTikPortal.Accounts.get_user!(user_id)
    requests = Requests.list_requests_by_user(user_id)
    keluhans = Keluhans.list_keluhans_by_user(user_id)

    {:ok,
     assign(socket,
       page_title: "Status Pengajuan – UPA TIK Portal",
       current_user: user,
       requests: requests,
       keluhans: keluhans,
       keluhan_subject: "",
       keluhan_description: "",
       keluhan_errors: %{},
       keluhan_submitted: false
     )}
  end

  defp status_class("pending"), do: "bg-amber-50 text-amber-600 border border-amber-100"
  defp status_class("disetujui"), do: "bg-emerald-50 text-emerald-600 border border-emerald-100"
  defp status_class("ditolak"), do: "bg-rose-50 text-rose-600 border border-rose-100"
  defp status_class(_), do: "bg-slate-50 text-slate-400 border border-slate-100"

  defp status_label("pending"), do: "⏳ Menunggu"
  defp status_label("disetujui"), do: "✅ Disetujui"
  defp status_label("ditolak"), do: "❌ Ditolak"
  defp status_label(s), do: s

  defp format_type("aktivasi"), do: "Aktivasi Akun"
  defp format_type("reset"), do: "Reset Password"
  defp format_type(t), do: t

  defp keluhan_badge("baru"), do: {"bg-indigo-50 text-indigo-600 border border-indigo-100", "🆕 Baru"}
  defp keluhan_badge("diproses"), do: {"bg-amber-50 text-amber-600 border border-amber-100", "⏳ Diproses"}
  defp keluhan_badge("selesai"), do: {"bg-emerald-50 text-emerald-600 border border-emerald-100", "✅ Selesai"}
  defp keluhan_badge(_), do: {"bg-slate-100 text-slate-700", "?"}
end
