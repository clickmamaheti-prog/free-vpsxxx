<div align="center">

``` 
  ╔══════════════════════════════════════════════════════╗
  ║  ┌──────────────────────────────────────────────┐   ║
  ║  │  ██████╗ ███████╗██╗   ██╗ ██████╗           │   ║
  ║  │  ██╔══██╗██╔════╝██║   ██║██╔════╝           │   ║
  ║  │  ██║  ██║█████╗  ██║   ██║██║                │   ║
  ║  │  ██║  ██║██╔══╝  ╚██╗ ██╔╝██║                │   ║
  ║  │  ██████╔╝███████╗ ╚████╔╝ ╚██████╗  PRO ✦   │   ║
  ║  │  ╚═════╝ ╚══════╝  ╚═══╝   ╚═════╝           │   ║
  ║  │       C U L T U R E  —  P R E M I U M  V P S │   ║
  ║  └──────────────────────────────────────────────┘   ║
  ╚══════════════════════════════════════════════════════╝
```

# DevCulture Pro — Premium SSH VPS via bore Tunnel

**Ubuntu 24.04 · bore Tunnel · Multi-Port · Railway · ntfy (opsional)**

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.app/new)
[![Deploy on Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)

![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04_LTS-E95420?logo=ubuntu&logoColor=white)
![bore](https://img.shields.io/badge/bore-Tunnel-00e5ff?logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)
![GHCR](https://img.shields.io/badge/GHCR-Image-2496ED?logo=github&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-00e5ff)

</div>

---

## ✨ Fitur Premium

| Fitur | Keterangan |
|-------|-----------|
| 🖥 **Ubuntu 24.04 LTS** | OS terbaru, stabil, production-ready |
| 🚇 **bore Tunnel** | TCP tunnel publik — tanpa registrasi, tanpa token |
| 🌐 **Multi-Port** | Tunnel otomatis untuk port 22 (SSH), APP, dan 3000 |
| 🔐 **Supervisord** | Auto-restart semua service — tidak pernah mati |
| 📲 **ntfy Notifikasi (opsional)** | Kirim alamat SSH + auto-restart ke HP — aktifkan dengan `NTFY_TOPIC` |
| 🔄 **Watchdog** | Deteksi tunnel mati → restart otomatis → notifikasi ulang |
| 🌐 **Web UI** | Dashboard built-in via Nginx |
| 🤖 **Freebuff CLI** | AI coding agent gratis (tanpa API key) sudah terpasang di dalam VPS |
| 🐳 **Docker / GHCR Ready** | Deploy ke Railway, Render, Fly.io, Koyeb, atau VPS — atau jalankan langsung dari image `ghcr.io` |
| 🆓 **100% Gratis** | Railway free credit — tidak perlu kartu kredit |

---

## 🚀 Quickstart

### Opsi A — Deploy via CLI (Railway) ⭐

Dengan satu perintah (menggunakan `deploy.sh` dari repo ini):

```bash
# Mode CLI wajib dijalankan dari checkout repo ini (railway up meng-upload isi folder):
git clone https://github.com/clickmamaheti-prog/free-vpsxxx.git
cd free-vpsxxx
./deploy.sh cli MyStrongPass2026!     # ganti dengan password root Anda
```

> ℹ️ Satu-liner `bash <(curl -fsSL …/deploy.sh)` **hanya untuk mode `ghcr`**
> (mode `cli` butuh folder repo yang di-clone).

Script akan:
1. Mengecek/install Railway CLI
2. Memastikan Anda login (`railway login`) atau sudah set `RAILWAY_API_TOKEN`
3. Deploy repo ini ke Railway (`railway up` — buat project + service otomatis)
4. Set variabel `ROOT_PASS` (wajib) dan `NTFY_TOPIC` (opsional, dari env)

> Tidak ada password? `deploy.sh cli` akan **membuatkan password acak yang kuat** dan menampilkannya.

### Opsi B — Deploy via image GHCR (Docker) 🐳

Image sudah otomatis di-build & di-push ke **GitHub Container Registry** setiap push ke `main`:

```bash
# Satu-liner — jalankan VPS di Docker host / VPS mana pun:
curl -fsSL https://raw.githubusercontent.com/clickmamaheti-prog/free-vpsxxx/main/deploy.sh | bash -s -- ghcr

# atau manual:
docker run -d --name free-vpsxxx --restart unless-stopped \
  -e ROOT_PASS='MyStrongPass2026!' \
  -e NTFY_TOPIC='topic-unik-anda' \
  -p 8080:8080 \
  ghcr.io/clickmamaheti-prog/free-vpsxxx:latest
```

Image: **`ghcr.io/clickmamaheti-prog/free-vpsxxx:latest`** (public, tanpa login)

### Opsi C — Deploy satu-klik (template Railway)

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.app/new?template=https%3A%2F%2Fgithub.com%2Fclickmamaheti-prog%2Ffree-vpsxxx&var-ROOT_PASS=&var-NTFY_TOPIC=&var-BORE_SERVER=bore.pub&var-TZ=Asia%2FJakarta&var-PORT=8080)

> 📘 **Panduan lengkap deploy Railway** (env vars, networking, verifikasi, troubleshooting): baca [`DEPLOY_RAILWAY.md`](./DEPLOY_RAILWAY.md)

---

## 🔧 Environment Variables

| Variable | Wajib? | Default | Deskripsi |
|----------|--------|---------|-----------|
| `ROOT_PASS` | **⚠️ Wajib** | — | Password SSH root. **VPS tidak akan start jika kosong.** |
| `NTFY_TOPIC` | Opsional | *(kosong)* | Topic ntfy untuk notifikasi alamat SSH. Kosong = notifikasi mati. **Pakai topic unik milik Anda sendiri.** |
| `BORE_SERVER` | Opsional | `bore.pub` | Server bore tunnel |
| `TZ` | Opsional | `Asia/Jakarta` | Timezone |
| `PORT` | Opsional | `8080` | Port internal web UI (nginx) |

> ⚠️ **Jangan pakai topic ntfy publik/bersama** — alamat SSH Anda akan terlihat oleh siapa pun yang subscribe topic itu. Set `NTFY_TOPIC` ke nilai unik Anda sendiri.

---

## 🔐 Cara Akses SSH

Jika `NTFY_TOPIC` diset, notifikasi masuk ke ntfy dengan alamat:

```bash
ssh root@bore.pub -p <PORT_DARI_NOTIFIKASI>
# Password: nilai ROOT_PASS yang Anda set
```

Cara melihat alamat tanpa ntfy — dari dalam container:

```bash
docker logs -f free-vpsxxx        # (Docker) cari baris "✅ SSH → bore.pub:xxxxx"
# atau
railway logs --lines 200          # (Railway)
```

> Port bore bersifat **dinamis** — berubah setiap container restart. Selalu cek log/notifikasi terbaru.

---

## 📲 Notifikasi ntfy (opsional)

Aktifkan dengan set `NTFY_TOPIC` (nilai unik milik Anda, contoh `vps-saya-123abc`). Sistem mengirim notifikasi pada kondisi:

| Event | Kapan |
|-------|-------|
| ⚡ **VPS Online** | Pertama kali container start |
| 🔄 **Auto Restart** | Watchdog restart tunnel yang mati |
| 📊 **Status Update** | Setiap 5 menit — uptime, RAM, tunnel aktif |

```bash
# Di HP: install app ntfy → subscribe https://ntfy.sh/<NTFY_TOPIC-anda>
```

---

## 🌐 Port yang Ditunnel

| Port | Service | Akses |
|------|---------|-------|
| `22` | 🔐 SSH | `ssh root@bore.pub -p <PORT>` |
| `$PORT` | 🌐 Web UI (Nginx) | `http://bore.pub:<PORT>` |
| `3000` | 📡 App Port | `http://bore.pub:<PORT>` |

---

## ⚙️ Arsitektur Sistem

```
┌──────────────────────────────────────┐
│         supervisord                  │
│  (auto-restart semua service)        │
├──────────────────────────────────────┤
│  ┌──────┐  ┌───────┐  ┌───────────┐  │
│  │ sshd │  │ nginx │  │   bore    │  │
│  │ :22  │  │ :PORT │  │  manager  │  │
│  └──────┘  └───────┘  └───────────┘  │
│  ┌──────────────────────────────────┐ │
│  │ watchdog  (monitor bore PIDs)    │ │
│  └──────────────────────────────────┘ │
└──────────────┬───────────────────────┘
               │ bore tunnel (outbound)
         ┌─────┴──────┐
         │  bore.pub  │  ← public TCP relay
         └────────────┘
          SSH / HTTP access
```

---

## 🐳 Image GHCR

Setiap push ke `main`, GitHub Actions otomatis build & push image:

- **Image**: `ghcr.io/clickmamaheti-prog/free-vpsxxx:latest`
- **Tag SHA**: `ghcr.io/clickmamaheti-prog/free-vpsxxx:<sha>`
- **Public** — bisa `docker pull` tanpa login
- Deploy image ke Railway: dashboard → **New Project → Deploy from Image** → `ghcr.io/clickmamaheti-prog/free-vpsxxx:latest`
- **Fly.io / Render / Koyeb**: deploy dari Dockerfile repo ini, lalu **wajib set `ROOT_PASS`** (mis. `fly secrets set ROOT_PASS='…'` sebelum `fly deploy`) — tanpa itu container langsung exit (`ROOT_PASS` kosong).

---

## 🛠️ Script Lain

| File | Fungsi |
|------|--------|
| `deploy.sh` | Deploy helper — mode `cli` (Railway CLI) & `ghcr` (Docker) |
| `bore-setup.sh` | Tunnel manager + watchdog + notifikasi (dijalankan supervisord) |
| `entrypoint.sh` | Entry point container — set password, konfig nginx, start supervisord |
| `watchdog.sh` | Restart sshd/nginx bila mati |
| `devculture-banner.sh` | Banner SSH premium |

---

## ⚠️ Catatan Penting & Keamanan

- **`ROOT_PASS` wajib kuat** — tunnel SSH ini publik; siapa pun yang tahu alamat `bore.pub:<port>` bisa mencoba brute-force. Gunakan password ≥ 12 karakter (huruf+angka+simbol). SSH sudah di-hardening: `MaxAuthTries 4`, `LoginGraceTime 30`, `PermitEmptyPasswords no`.
- **bore port dinamis** — berubah setiap restart; selalu cek log/notifikasi terbaru.
- **Railway free tier** — container sleep setelah ±10 menit idle (SSH tidak selalu 24/7 di free plan). Upgrade plan berbayar untuk uptime penuh.
- **Gunakan sesuai ToS** platform (Railway/Render/bore). Jangan untuk aktivitas ilegal/abusive.
- Semua service diawasi supervisord → auto-restart.

---

<div align="center">

**Dibuat dengan ❤️ oleh [DevCulture](https://github.com/clickmamaheti-prog)**

*Premium VPS · Ubuntu 24.04 · bore Tunnel · supervisord Powered*

⭐ **Star repo ini jika membantu!** ⭐

```
  powered by: DevCulture Pro ©2026
```

</div>
