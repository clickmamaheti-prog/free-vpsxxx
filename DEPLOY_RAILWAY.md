# 🚆 Deploy ke Railway — Panduan Lengkap

Panduan step-by-step untuk deploy **DevCulture Pro VPS (free-vpsxxx)** ke
[Railway](https://railway.app). Baca file ini sebelum deploy pertama.

---

## 📋 Ringkasan

| Item | Nilai |
|---|---|
| OS | **Ubuntu 24.04 LTS** |
| Builder | Dockerfile (otomatis terdeteksi / dikonfigurasi di `railway.json`) |
| Port internal web UI | `8080` (default, bisa diubah via var `PORT`) |
| Health check | `/health` (nginx) |
| Biaya | Free plan `$0/bln` (kredit `$1/bln`) · trial 30 hari `$5` tanpa kartu kredit |
| Notifikasi | ntfy → topic `NTFY_TOPIC` (**opsional** — kosong = mati) |
| Log tunnel bore | 📍 **Langsung terlihat di `railway logs`** (perbaikan logging v7.1) — tidak perlu SSH ke container |

---

## 0️⃣ Cara Tercepat — via CLI (`deploy.sh`) ⭐

Dari repo ini (atau satu-liner tanpa clone):

```bash
git clone https://github.com/clickmamaheti-prog/free-vpsxxx.git
cd free-vpsxxx
./deploy.sh cli MyStrongPass2026!
```

Script otomatis: cek/install Railway CLI → cek login → `railway up -y` (buat project + service) → set `ROOT_PASS` & `NTFY_TOPIC`.

Tanpa argumen password, script membuatkan password acak yang kuat.

## 1️⃣ Cara A — Deploy Satu-Klik (Template Button)

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.app/new?template=https%3A%2F%2Fgithub.com%2Fclickmamaheti-prog%2Ffree-vpsxxx&var-ROOT_PASS=&var-NTFY_TOPIC=&var-BORE_SERVER=bore.pub&var-TZ=Asia%2FJakarta&var-PORT=8080)

Setelah diklik:
1. Login / daftar Railway (email atau GitHub — **trial $5, tanpa kartu kredit**)
2. Railway otomatis membuat project dari repo ini
3. **Isi `ROOT_PASS`** (wajib!) lalu **Deploy** → build Dockerfile berjalan (~5–10 menit)

## 1️⃣ Cara B — Manual via Dashboard

1. Buka [railway.app](https://railway.app) → **New Project** → **Deploy from GitHub**
2. Pilih repo `free-vpsxxx`
3. Railway membaca `railway.json` → memakai **Dockerfile** sebagai builder
4. Masuk ke project → **Variables** → isi sesuai tabel di bawah
5. Klik **Deploy** → tunggu build selesai

## 1️⃣ Cara C — Deploy dari Image GHCR

1. **New Project → Deploy from Image**
2. Image: `ghcr.io/clickmamaheti-prog/free-vpsxxx:latest` (public, tanpa login)
3. Set variabel (tabel di bawah) → **Deploy**

---

## 2️⃣ Environment Variables (WAJIB dibaca)

| Variable | Wajib? | Default | Deskripsi |
|----------|--------|---------|-----------|
| `ROOT_PASS` | ⚠️ **WAJIB** | — | Password SSH root. **VPS tidak akan start jika kosong** (entrypoint `exit 1`). Minimal 12 karakter, campur huruf/angka/simbol. |
| `NTFY_TOPIC` | Opsional | *(kosong)* | Topic ntfy untuk notifikasi alamat SSH & status. **Pakai topic unik milik Anda** — jangan pakai topic publik bersama. |
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
4. Health check `/health` akan mengembalikan `OK` bila sehat

> Web UI hanya untuk dashboard. **SSH tetap lewat bore tunnel** (`bore.pub:<port>` dari log/notifikasi ntfy), bukan lewat domain Railway.

---

## 4️⃣ Notifikasi ntfy (opsional)

> ℹ️ **Sejak v7.1, alamat tunnel bore dicetak langsung ke log Railway**
> (`✅ SSH → bore.pub:xxxxx`). Jadi meski ntfy mati/opsional, port SSH tetap
> bisa dilihat via `railway logs` — tidak perlu SSH ke container.

1. Set `NTFY_TOPIC` ke nilai unik Anda (contoh: `vps-abc123`)
2. Install aplikasi **ntfy** (Android/iOS) atau buka `https://ntfy.sh/<NTFY_TOPIC-anda>`
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
   freebuff --version   # AI coding agent (sudah terpasang)
   cd /tmp && freebuff  # jalankan di folder project apa pun
   ```

Tanpa `NTFY_TOPIC`: cek alamat via log — `railway logs --lines 200` lalu cari baris `✅ SSH → bore.pub:xxxxx` (kini tercetak di log bila tunnel berhasil konek).

> ⚠️ **Notifikasi tidak masuk?** Cek log container:
> - `⚠️ ntfy gagal dikirim` → server `ntfy.sh` sedang tidak terjangkau saat itu
>   (koneksi timeout). Ini masalah jaringan/uptime ntfy.sh, **bukan** konfigurasi.
>   Container otomatis mencoba kirim ulang setiap 5 menit (status update) dan
>   saat restart. Selama ntfy.sh normal, notif akan masuk.
> - Tidak ada baris `📲 ntfy terkirim` dan tidak ada `⚠️` → cek apakah
>   `NTFY_TOPIC` benar-benar terset di Variables (kosong = notifikasi mati by design).

---

## 5️⃣ Verifikasi Deploy

- [ ] **Build** sukses di tab Deployments (log berakhir `Successfully built`)
- [ ] **Container online** (tidak restart-loop)
- [ ] **Health**: `curl https://<project>.up.railway.app/health` → `OK`
- [ ] **Log** berisi `✅ SSH → bore.pub:<port>` untuk SSH, APP, dan 3000 —
  cek langsung dengan `railway logs --service <nama> --lines 200`
  (perbaikan logging v7.1: baris ini kini tercetak di log bila tunnel berhasil konek,
  tanpa SSH ke container)
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
   - **Variables** `RAILWAY_SERVICE_ID` & `RAILWAY_ENVIRONMENT_ID` → isi dari URL/API project Railway Anda
3. Push berikutnya ke `main` otomatis deploy. Jika secret belum diset, workflow **skip dengan pesan jelas** (tidak gagal/merah).

> Workflow memanggil endpoint `backboard.railway.com` (GraphQL v2).

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
> - SSH tidak selalu tersedia 24/7 di free tier
> - Port bore berubah setiap kali container restart → **selalu cek log/notifikasi terbaru**
>
> Kalau butuh VPS yang benar-benar selalu online: upgrade ke plan berbayar.

---

## 🛠️ Troubleshooting

| Gejala | Penyebab & Solusi |
|---|---|
| Build gagal / `exit 137` | RAM container habis saat build (OOM). Heap Node sudah dibatasi `320MB` (`NODE_OPTIONS`). Coba trial plan (1GB RAM) atau kurangi beban. |
| Container restart-loop | `ROOT_PASS` kosong → entrypoint `exit 1`. Set `ROOT_PASS` di Variables. |
| Notifikasi ntfy tidak masuk | `NTFY_TOPIC` kosong = mati (by design). Atau log menunjukkan `⚠️ ntfy gagal dikirim` = `ntfy.sh` tidak terjangkau saat itu (retry otomatis tiap 5 menit & saat restart). Pastikan perangkat Anda subscribe ke `https://ntfy.sh/<TOPIC>` dan pakai topic unik (jangan `testing12345` publik). |
| Tidak ada port di log | Bore gagal konek ke `bore.pub` (outbound diblokir?) atau bore-setup belum selesai. Sejak v7.1 log bore dicetak ke `railway logs`; tunggu ±1 menit lalu `railway logs --lines 200`. Kalau tetap tidak ada baris `✅ SSH`, ganti `BORE_SERVER` atau cek `⚠️` di log. |
| Workflow Actions merah | `RAILWAY_TOKEN` belum diset → workflow otomatis skip (tidak merah). Set secret bila ingin auto-deploy. |
| `freebuff: command not found` | Build image lama. Redeploy (Deployments → Redeploy) untuk image terbaru. |

## 📝 Changelog

| Versi | Perubahan |
|---|---|
| **v7.1** | Perbaikan logging: `bore-setup.sh` menyalin semua log ke stdout container → alamat tunnel (`✅ SSH → bore.pub:<port>`) dan status ntfy (`📲 terkirim` / `⚠️ gagal`) kini terlihat langsung di `railway logs`, tanpa perlu SSH ke container. |
| v7.0 | Rilis awal panduan & image. |

---

<div align="center">

**Dibuat oleh Buffy (Freebuff AI)** · `DEPLOY_RAILWAY.md` · v7.1 · Ubuntu 24.04

</div>
