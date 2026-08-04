# 🚆 Deploy ke Railway — Panduan Lengkap

Panduan step-by-step untuk deploy **DevCulture Pro VPS (free-vpsxxx)** ke
[Railway](https://railway.app). Baca file ini sebelum deploy pertama.

---

## 📋 Ringkasan

| Item | Nilai |
|---|---|
| Builder | Dockerfile (otomatis terdeteksi / dikonfigurasi di `railway.json`) |
| Port internal web UI | `8080` (default, bisa diubah via var `PORT`) |
| Health check | `/health` (nginx) |
| Biaya | Free plan `$0/bln` (kredit `$1/bln`) · trial 30 hari `$5` tanpa kartu kredit |
| Notifikasi | ntfy → topic `NTFY_TOPIC` (default `vps-maill1`) |

---

## 1️⃣ Cara A — Deploy Satu-Klik (Template Button) ⭐

Tombol ini sudah pre-fill variabel default. Klik di bawah ini:

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.app/new?template=https%3A%2F%2Fgithub.com%2Fclickmamaheti-prog%2Ffree-vpsxxx&var-ROOT_PASS=&var-NTFY_TOPIC=vps-maill1&var-BORE_SERVER=bore.pub&var-TZ=Asia%2FJakarta&var-PORT=8080)

```
https://railway.app/new?template=https%3A%2F%2Fgithub.com%2Fclickmamaheti-prog%2Ffree-vpsxxx&var-ROOT_PASS=&var-NTFY_TOPIC=vps-maill1&var-BORE_SERVER=bore.pub&var-TZ=Asia%2FJakarta&var-PORT=8080
```

Setelah diklik:
1. Login / daftar Railway (email atau GitHub — **trial $5, tanpa kartu kredit**)
2. Railway otomatis membuat project dari repo ini
3. **Isi `ROOT_PASS`** (wajib!) lalu **Deploy** → build Dockerfile berjalan (~5–10 menit)

## 1️⃣ Cara B — Manual via Dashboard

1. Buka [railway.app](https://railway.app) → **New Project** → **Deploy from GitHub**
2. Pilih repo `free-vpsxxx` (pastikan GitHub sudah terhubung; install Railway app di GitHub bila diminta)
3. Railway membaca `railway.json` → memakai **Dockerfile** sebagai builder
4. Masuk ke project → **Variables** → isi sesuai tabel di bawah
5. Klik **Deploy** → tunggu build selesai

---

## 2️⃣ Environment Variables (WAJIB dibaca)

| Variable | Wajib? | Default | Deskripsi |
|----------|--------|---------|-----------|
| `ROOT_PASS` | ⚠️ **WAJIB** | — | Password SSH root. **VPS tidak akan start jika kosong** (entrypoint `exit 1`). Minimal 12 karakter, campur huruf/angka/simbol. |
| `NTFY_TOPIC` | Opsional | `vps-maill1` | Topic ntfy untuk notifikasi alamat SSH & status |
| `BORE_SERVER` | Opsional | `bore.pub` | Server bore tunnel publik |
| `TZ` | Opsional | `Asia/Jakarta` | Timezone container |
| `PORT` | Opsional | `8080` | Port internal web UI (nginx) — **harus sama dengan port yang dipilih saat setup Public Networking** |

> ⚠️ **Jangan** set `ROOT_PASS` sama dengan password yang dipakai di tempat lain.
> Siapa pun yang tahu alamat `bore.pub:<port>` bisa mencoba brute-force SSH.

---

## 3️⃣ Setup Public Networking (sekali saja)

1. Buka service → **Settings** (atau tab **Networking**)
2. **Generate Domain** → pilih port yang di-expose: **pilih `8080`** (sama dengan `PORT` var)
3. Simpan — web UI dashboard bisa diakses di `https://<project>.up.railway.app`
4. Health check `/health` akan mengembalikan `DevCulture VPS OK` bila sehat

> Web UI hanya untuk dashboard. **SSH tetap lewat bore tunnel** (`bore.pub:<port>` dari notifikasi ntfy), bukan lewat domain Railway (port 22 tidak di-expose ke internet oleh Railway).

---

## 4️⃣ Subscribe Notifikasi ntfy (di HP)

1. Install aplikasi **ntfy** (Android/iOS) atau buka `https://ntfy.sh`
2. Subscribe ke topic: `https://ntfy.sh/vps-maill1` (sesuai `NTFY_TOPIC` Anda)
3. Setelah container pertama kali start, akan masuk notifikasi **⚡ VPS ONLINE** berisi:
   ```
   🔐 SSH   : bore.pub:12345
   💡 Cmd   : ssh root@bore.pub -p 12345
   ```
4. Login SSH:
   ```bash
   ssh root@bore.pub -p <PORT_DARI_NOTIFIKASI>
   # password = ROOT_PASS yang Anda set
   ```
5. Coba coding agent gratis di dalam VPS:
   ```bash
   freebuff --version   # → 0.0.138 (sudah terpasang)
   cd /tmp && freebuff  # jalankan di folder project apa pun
   ```

---

## 5️⃣ Verifikasi Deploy

- [ ] **Build** sukses di tab Deployments (log berakhir `Successfully built`)
- [ ] **Container online** (tidak restart-loop)
- [ ] **Health**: `curl https://<project>.up.railway.app/health` → `DevCulture VPS OK`
- [ ] **Notifikasi ntfy masuk** berisi `bore.pub:<port>` untuk SSH, APP, dan 3000
- [ ] **SSH masuk** dengan `ssh root@bore.pub -p <port>`
- [ ] **`freebuff --version`** jalan di dalam SSH

---

## 6️⃣ Auto-Deploy via GitHub Actions (opsional)

Repo ini punya workflow `.github/workflows/railway-deploy.yml` yang trigger
deployment otomatis setiap push ke `main`. Agar berfungsi:

1. Buat token Railway: **Account Settings → Tokens → Generate** (scope `Deploy`),
   atau Project Token dari project Anda
2. Di GitHub repo: **Settings → Secrets and variables → Actions**:
   - **Secret** `RAILWAY_TOKEN` → tempel token
   - **Variables** `RAILWAY_SERVICE_ID` & `RAILWAY_ENVIRONMENT_ID` → isi dari URL/API project Railway Anda (opsional; jika kosong memakai ID bawaan repo)
3. Push berikutnya ke `main` otomatis deploy. Jika secret belum diset, workflow **skip dengan pesan jelas** (tidak gagal/merah).

---

## 💰 Biaya & Batasan Free Tier (perlu diketahui!)

| Fakta | Detail |
|---|---|
| Free plan | `$0/bln` + **kredit `$1/bln`** · max **0.5 GB RAM** + 1 vCPU per service |
| Trial 30 hari | **`$5` kredit sekali** · tanpa kartu kredit · max **1 GB RAM** + 2 vCPU |
| Hobby plan | `$5/bln` (termasuk `$5` usage credit) |
| Billing | **Per detik**: RAM `$10/GB/bln`, CPU `$20/vCPU/bln`, egress `$0.05/GB` |
| Sleep otomatis | Service idle ±10 menit → **sleep** (nol biaya compute), bangun otomatis saat ada request |

> ⚠️ **Penting untuk VPS ini**: fitur sleep otomatis Railway membuat container
> (dan tunnel bore) mati setelah ±10 menit tidak ada trafik. Akibatnya:
> - SSH tidak selalu tersedia 24/7 di free tier — bangun kembali saat ada request
> - Port bore berubah setiap kali container restart → **selalu cek notifikasi ntfy terbaru**
>
> Kalau butuh VPS yang benar-benar selalu online: upgrade ke plan berbayar,
> atau pantau container tetap bangun dengan ping berkala.

---

## 🛠️ Troubleshooting

| Gejala | Penyebab & Solusi |
|---|---|
| Build gagal / `exit 137` | RAM container habis saat build (OOM). Heap Node sudah dibatasi `320MB` (`NODE_OPTIONS`). Coba trial plan (1GB RAM) atau kurangi beban. |
| Container restart-loop `EADDRINUSE` | Dua instance jalan bersamaan. Pastikan `numReplicas: 1` dan restart policy `ON_FAILURE`. |
| Notifikasi ntfy tidak masuk | Cek `NTFY_TOPIC` benar & subscribe di HP; cek log `bore` di tab Deployments. |
| Tidak ada port di notifikasi | bore gagal konek ke `bore.pub` (outbound diblokir?). Ganti `BORE_SERVER`. |
| Workflow Actions merah | `RAILWAY_TOKEN` belum diset → workflow otomatis skip (tidak merah lagi setelah fix ini). Set secret bila ingin auto-deploy. |
| `freebuff: command not found` | Build image lama. Redeploy (Deployments → Redeploy) untuk image terbaru yang sudah berisi Node 22 + Freebuff. |

---

<div align="center">

**Dibuat oleh Buffy (Freebuff AI)** · `DEPLOY_RAILWAY.md` · v1.0

</div>
