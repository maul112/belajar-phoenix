defmodule UpaTikPortal.Recruitment.QrTokenStore do
  @moduledoc """
  GenServer untuk menyimpan mapping short token ke long JWT token.
  Menggunakan ETS (Erlang Term Storage) untuk penyimpanan in-memory yang cepat.
  """
  use GenServer
  require Logger

  @table_name :qr_token_store
  @ttl_seconds 60 # 1 menit valid

  # --- Client API ---

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Menyimpan JWT token ke ETS dan mengembalikan short token (6 karakter).
  """
  def put_token(jwt_token) do
    short_token = generate_short_token()
    expires_at = System.system_time(:second) + @ttl_seconds
    
    :ets.insert(@table_name, {short_token, jwt_token, expires_at})
    short_token
  end

  @doc """
  Mendapatkan JWT token berdasarkan short token.
  Jika expired atau tidak ditemukan, mengembalikan nil.
  """
  def get_token(short_token) do
    case :ets.lookup(@table_name, short_token) do
      [{^short_token, jwt_token, expires_at}] ->
        if System.system_time(:second) > expires_at do
          :ets.delete(@table_name, short_token)
          nil
        else
          jwt_token
        end
      [] -> nil
    end
  end

  @doc """
  Membersihkan token yang sudah expired.
  Bisa dipanggil periodik.
  """
  def cleanup do
    now = System.system_time(:second)
    # Hapus semua record yang expires_at < now
    match_spec = [{{:"$1", :_, :"$2"}, [{:<, :"$2", now}], [true]}]
    deleted = :ets.select_delete(@table_name, match_spec)
    if deleted > 0 do
      Logger.debug("Cleaned up #{deleted} expired QR tokens")
    end
  end

  # --- Server Callbacks ---

  @impl true
  def init(_) do
    :ets.new(@table_name, [:set, :public, :named_table, read_concurrency: true])
    # Schedule cleanup every 10 seconds
    :timer.send_interval(10_000, :cleanup)
    {:ok, %{}}
  end

  @impl true
  def handle_info(:cleanup, state) do
    cleanup()
    {:noreply, state}
  end

  defp generate_short_token do
    # Generate 6 random alphanumeric chars
    :crypto.strong_rand_bytes(4) |> Base.encode16() |> String.slice(0, 6)
  end
end
