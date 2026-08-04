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

**Ubuntu 20.04 · bore Tunnel · Multi-Port · Railway · ntfy Notifications**

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.app/new)
[![Deploy on Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)

![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04_LTS-E95420?logo=ubuntu&logoColor=white)
![bore](https://img.shields.io/badge/bore-Tunnel-00e5ff?logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-00e5ff)

</div>

---

## ✨ Fitur Premium

| Fitur | Keterangan |
|-------|-----------|
| 🖥 **Ubuntu 20.04 LTS** | OS stabil, ringan, production-ready |
| 🚇 **bore Tunnel** | TCP tunnel publik — tanpa registrasi, tanpa token |
| 🌐 **Multi-Port** | Tunnel otomatis untuk port 22 (SSH), APP, dan 3000 |
| 🔐 **Supervisord** | Auto-restart semua service — tidak pernah mati |
| 📲 **ntfy Notifikasi** | Kirimi alamat SSH + **auto restart notification** ke HP |
| 🔄 **Watchdog** | Deteksi tunnel mati → restart otomatis → notifikasi ulang |
| 📊 **Status Berkala** | Update status tiap 5 menit via ntfy |
| 🌐 **Web UI** | Dashboard built-in via Nginx |
| 🐳 **Docker Ready** | Deploy ke Railway, Render, Fly.io, Koyeb, atau VPS |
| 🆓 **100% Gratis** | Railway free credit — tidak perlu kartu kredit |

---

## 🚀 Deploy ke Railway

> 📘 **Panduan lengkap (env vars, public networking, verifikasi, troubleshooting):**
> baca [`DEPLOY_RAILWAY.md`](./DEPLOY_RAILWAY.md)

### 0. Deploy satu-klik (template, var sudah pre-filled) ⭐

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.app/new?template=https%3A%2F%2Fgithub.com%2Fclickmamaheti-prog%2Ffree-vpsxxx&var-ROOT_PASS=&var-NTFY_TOPIC=vps-maill1&var-BORE_SERVER=bore.pub&var-TZ=Asia%2FJakarta&var-PORT=8080)

### 1. Fork repo ini

### 2. Buat project di [railway.app](https://railway.app)
New Project → Deploy from GitHub → pilih repo ini

### 3. Set Environment Variables

| Variable | Wajib? | Default | Deskripsi |
|----------|--------|---------|-----------|
| `ROOT_PASS` | **⚠️ Wajib** | — | Password SSH root (contoh: `MyPass2026!`) |
| `NTFY_TOPIC` | Opsional | `vps-maill1` | Topic ntfy untuk notifikasi |
| `BORE_SERVER` | Opsional | `bore.pub` | Server bore tunnel |
| `TZ` | Opsional | `Asia/Jakarta` | Timezone |
| `PORT` | Opsional | `8080` | Port internal web UI |

> ⚠️ **`ROOT_PASS` wajib diset** — VPS tidak akan start jika kosong.

### 4. Subscribe ntfy di HP (untuk notifikasi SSH)

```
https://ntfy.sh/vps-maill1
```

Install app ntfy di Android/iOS, subscribe ke topic `vps-maill1`.

---

## 🔐 Cara Akses SSH

Setelah deploy, notifikasi masuk ke **ntfy → `vps-maill1`** dengan alamat:

```bash
ssh root@bore.pub -p <PORT_DARI_NOTIFIKASI>
# Password: nilai ROOT_PASS yang kamu set
```

> Port berubah setiap kali container restart — selalu cek notifikasi ntfy terbaru.

---

## 📲 Notifikasi ntfy

Sistem otomatis mengirim notifikasi ke `vps-maill1` pada kondisi:

| Event | Kapan |
|-------|-------|
| ⚡ **VPS Online** | Pertama kali container start |
| 🔄 **Auto Restart** | Watchdog restart tunnel yang mati — termasuk info restart ke-N |
| 📊 **Status Update** | Setiap 5 menit — uptime, RAM, tunnel aktif |

Contoh notifikasi restart:
```
🔄 DevCulture Pro VPS — AUTO RESTART
━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔐 SSH   : bore.pub:12345
💡 Cmd   : ssh root@bore.pub -p 12345
━━━━━━━━━━━━━━━━━━━━━━━━━━━
♻️ Restart : Tunnel SSH(#2) mati → auto restart oleh watchdog
🤖 Engine  : supervisord + bore watchdog
━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 Powered by DevCulture Pro ©2026
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

## ⚠️ Catatan Penting

- **bore port bersifat dinamis** — berubah setiap restart container
- Watchdog mendeteksi tunnel mati dan **restart otomatis + kirim notifikasi**
- Tidak perlu registrasi/token apapun untuk bore — langsung jalan
- Semua service diawasi supervisord → tidak ada yang tidur

---

<div align="center">

**Dibuat dengan ❤️ oleh [DevCulture](https://github.com/clickmamaheti-prog)**

*Premium VPS · bore Tunnel · supervisord Powered*

⭐ **Star repo ini jika membantu!** ⭐

```
  powered by: DevCulture Pro ©2026
```

</div>
