# Panduan Deploy Phoenix & Setup MinIO (Gratis & Berbayar)

Dokumen ini berisi panduan lengkap untuk melakukan deploy aplikasi **Upa TIK Portal** ke production (baik menggunakan layanan gratis maupun berbayar) serta konfigurasi **MinIO Object Storage** (atau alternatif S3-compatible yang gratis/murah).

---

## Bagian 1: Pilihan Platform Deployment (Elixir/Phoenix)

Berikut adalah beberapa opsi deployment yang populer untuk aplikasi Phoenix, dari yang gratis hingga berbayar:

### 1. Gigalixir (Rekomendasi untuk Gratis & Mudah)
Gigalixir adalah PaaS (Platform as a Service) yang dibuat khusus untuk aplikasi Elixir/Phoenix.
*   **Gratis (Free Tier)**:
    *   1 instance aplikasi gratis (kapasitas RAM 0.2 GB).
    *   1 database PostgreSQL gratis (maksimal 10.000 baris data).
    *   **Kelebihan**: Tidak memerlukan kartu kredit untuk mendaftar. Deploy cukup via Git.
*   **Berbayar**: Mulai dari sekitar $10–$15/bulan untuk naik ke resource yang lebih tinggi (RAM lebih besar, database tanpa batas baris).
*   **Cara Deploy**:
    1.  Install CLI Gigalixir di komputer Anda.
    2.  Daftar akun dan login via CLI: `gigalixir signup` dan `gigalixir login`.
    3.  Buat aplikasi: `gigalixir create -n nama-aplikasi-anda`.
    4.  Tambahkan database gratis: `gigalixir pg:create --free`.
    5.  Set environment variables (.env equivalents) di Gigalixir:
        ```bash
        gigalixir config:set GOOGLE_CLIENT_ID=your_id GOOGLE_CLIENT_SECRET=your_secret SECRET_KEY_BASE=$(mix phx.gen.secret)
        ```
    6.  Deploy aplikasi menggunakan Git: `git push gigalixir main`.

### 2. Fly.io (Rekomendasi untuk Skala Kecil & Performa Tinggi)
Fly.io menjalankan aplikasi Anda dekat dengan pengguna menggunakan mikro-VM.
*   **Gratis (Free Tier)**:
    *   Hingga 3 VM ukuran terkecil (`shared-cpu-1x` dengan 256MB RAM) secara gratis.
    *   Database PostgreSQL gratis (kapasitas volume hingga 3GB).
    *   **Catatan**: Membutuhkan kartu kredit saat pendaftaran untuk verifikasi (mencegah bot/abuse), tetapi Anda tidak akan dicharge selama penggunaan di bawah limit gratis.
*   **Berbayar**: Bayar sesuai penggunaan (Pay-as-you-go). Jika aplikasi butuh RAM lebih besar (misal 512MB atau 1GB), biayanya sangat terjangkau (sekitar $2–$5/bulan).
*   **Cara Deploy**:
    1.  Install `flyctl` (CLI Fly.io).
    2.  Jalankan `fly auth login`.
    3.  Di folder project, jalankan:
        ```bash
        fly launch
        ```
    4.  Jawab pertanyaan konfigurasi (buat database PostgreSQL ketika ditanya). Fly.io akan mendeteksi project Phoenix secara otomatis dan membuat file `fly.toml` serta `Dockerfile`.
    5.  Set environment variables menggunakan secrets:
        ```bash
        fly secrets set GOOGLE_CLIENT_ID=your_id GOOGLE_CLIENT_SECRET=your_secret
        ```
    6.  Deploy dengan perintah: `fly deploy`.

### 3. Self-Hosted VPS (DigitalOcean, Hetzner, AWS) - Berbayar (Mulai $4/bulan)
Jika Anda ingin kontrol penuh dengan harga termurah untuk production serius.
*   **Biaya**: Mulai dari $4/bulan di VPS murah.
*   **Kelebihan**: Anda bisa menjalankan Phoenix app, database PostgreSQL, dan server MinIO secara bersamaan di dalam satu VPS menggunakan **Docker Compose**, tanpa biaya tambahan untuk platform lain.
*   **Cara Deploy**:
    1.  Gunakan `mix release` untuk mengkompilasi aplikasi Phoenix menjadi binary mandiri.
    2.  Atau bungkus aplikasi ke dalam Docker image, lalu jalankan di VPS menggunakan Docker.

---

## Bagian 2: Konfigurasi MinIO / S3 Object Storage

Aplikasi ini menggunakan library `ex_aws` dan `waffle` untuk menangani upload file. Di file `config/runtime.exs`, konfigurasi storage telah diatur untuk membaca dari environment variables.

### 1. Menjalankan MinIO secara Lokal (Development)
Untuk menjalankan MinIO di komputer lokal Anda menggunakan Docker:
```bash
docker run -d -p 9000:9000 -p 9001:9001 --name minio \
  -e "MINIO_ROOT_USER=minioadmin" \
  -e "MINIO_ROOT_PASSWORD=minioadmin" \
  -v minio_data:/data \
  minio/minio server /data --console-address ":9001"
```
Setelah itu, Anda bisa mengakses dashboard MinIO di `http://localhost:9001` (username/password: `minioadmin`), buat bucket bernama `upa-tik-uploads`, dan atur access policy bucket tersebut menjadi **public** agar file bisa diakses publik.

### 2. Konfigurasi MinIO / S3 di Production
Ketika aplikasi di-deploy ke production (misalnya ke Gigalixir atau Fly.io), Anda memiliki dua pilihan utama untuk Object Storage:

#### Opsi A: Menggunakan Cloudflare R2 (SANGAT DIREKOMENDASIKAN & GRATIS)
Karena memelihara server MinIO sendiri di VPS berbayar membutuhkan biaya dan manajemen, cara terbaik adalah menggunakan **Cloudflare R2** yang kompatibel dengan protokol S3 (dan MinIO).
*   **Gratis**: Kuota penyimpanan hingga **10 GB gratis** per bulan, dan **gratis biaya download (no egress fee)**.
*   **Cara Setup**:
    1.  Daftar/login ke Cloudflare, masuk ke menu **R2 Object Storage**.
    2.  Buat bucket baru (misalnya `upa-tik-uploads`).
    3.  Dapatkan API Credentials (Access Key ID dan Secret Access Key).
    4.  Dapatkan S3 Endpoint URL dari dashboard R2 Anda (formatnya biasanya: `https://<account_id>.r2.cloudflarestorage.com`).
    5.  Masukkan credentials tersebut ke environment variables aplikasi Anda di production.

#### Opsi B: Self-Hosted MinIO di VPS Berbayar
Jika Anda bersikeras ingin menggunakan server MinIO sendiri di production:
1.  Beli VPS (misal dari DigitalOcean, Hetzner, atau Linode).
2.  Install Docker dan jalankan kontainer MinIO seperti langkah lokal, namun pastikan port `9000` dan `9001` dibuka di firewall VPS Anda dan dipetakan ke domain/IP publik Anda.
3.  Gunakan domain/IP VPS tersebut sebagai host/endpoint di konfigurasi Phoenix Anda.

---

## Bagian 3: Environment Variables yang Dibutuhkan di Production

Pastikan Anda memasukkan variabel-variabel berikut ke dalam dashboard platform tempat Anda men-deploy aplikasi (Gigalixir, Fly.io, atau `.env` di VPS):

```bash
# Database URL (biasanya diset otomatis oleh platform)
DATABASE_URL=ecto://username:password@hostname:port/database_name

# Phoenix Endpoint Secret (buat dengan perintah: mix phx.gen.secret)
SECRET_KEY_BASE=nilai_random_yang_sangat_panjang

# Domain aplikasi Anda di production (misal: upa-portal.fly.dev)
PHX_HOST=domain-anda.com

# Google OAuth Credentials
GOOGLE_CLIENT_ID=client_id_google_anda
GOOGLE_CLIENT_SECRET=client_secret_google_anda

# Konfigurasi Storage (Contoh menggunakan Cloudflare R2)
MINIO_ACCESS_KEY=access_key_r2_atau_minio
MINIO_SECRET_KEY=secret_key_r2_atau_minio
MINIO_BUCKET=nama-bucket-anda
MINIO_ENDPOINT=https://<account_id>.r2.cloudflarestorage.com

# Konfigurasi SMTP Email (Gmail)
SMTP_USER=email_anda@gmail.com
SMTP_PASSWORD=app_password_dari_gmail
SMTP_HOST=smtp.gmail.com
SMTP_PORT=465
```

---

## Ringkasan Alur Deployment Cepat (Contoh: Fly.io + Cloudflare R2)

1.  Daftar akun di **Fly.io** dan **Cloudflare**.
2.  Buat Bucket di Cloudflare R2, salin Access Key, Secret Key, dan Endpoint URL-nya.
3.  Buka terminal project Anda, jalankan `fly launch` untuk membuat konfigurasi deploy.
4.  Masukkan semua environment variables di atas menggunakan command `fly secrets set KEY=VALUE`.
5.  Jalankan `fly deploy`. Aplikasi Anda akan langsung online dan bisa diakses di internet secara gratis/sangat murah!
