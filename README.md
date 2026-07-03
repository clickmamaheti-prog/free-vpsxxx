<div align="center">

```
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║    ██████╗  █████╗ ██╗██████╗ ██╗   ██╗   ██╗  ██╗██╗   ██╗███╗   ██╗ ║
║    ██╔══██╗██╔══██╗██║██╔══██╗██║   ██║   ██║ ██╔╝██║   ██║████╗  ██║ ║
║    ██████╔╝███████║██║██║  ██║██║   ██║   █████╔╝ ██║   ██║██╔██╗ ██║ ║
║    ██╔══██╗██╔══██║██║██║  ██║██║   ██║   ██╔═██╗ ██║   ██║██║╚██╗██║ ║
║    ██║  ██║██║  ██║██║██████╔╝╚██████╔╝██╗██║  ██╗╚██████╔╝██║ ╚████║ ║
║    ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═════╝  ╚═════╝ ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ ║
║                                                              ║
║              ★  RAIRU-KUN2 PREMIUM VPS  ★                   ║
╚═══════════════════════════════════════════════════════════════╝
              powered by: DevCulture ©2026 linux
```

# Rairu-Kun2 — Premium SSH VPS via zrok Tunnel

**Ubuntu 20.04 · zrok Zero-Trust Tunnel · Multi-Port · Railway · ntfy Premium**

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.app/new)
[![Deploy on Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)

![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04_LTS-E95420?logo=ubuntu&logoColor=white)
![zrok](https://img.shields.io/badge/zrok-Tunnel-00e5ff?logo=ziti&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-00e5ff)

</div>

---

## ✨ Fitur Premium

| Fitur | Keterangan |
|-------|-----------|
| 🖥 **Ubuntu 20.04 LTS** | OS premium, stabil dan ringan |
| 🔑 **SSH via zrok** | Zero-trust tunnel — lebih aman dari bore/ngrok |
| 🔐 **Supervisord** | Systemd alternative — auto-restart semua service |
| 🌐 **Web UI Premium** | Dashboard dengan tema gelap DevCulture |
| 📲 **ntfy Premium** | Notifikasi SSH URL + status periodik (topic: `zrokIP22`) |
| 🔄 **zrok Tunnel** | Auto-restart jika tunnel mati |
| 🐳 **Docker Ready** | Deploy ke Railway, Render, Fly.io, atau VPS |
| 🆓 **100% Gratis** | Railway $5/bulan credit, semua tools gratis |

---

## 🚀 Deploy ke Railway

### 1. Fork repo ini
### 2. Buat project di [railway.app](https://railway.app)
New Project → Deploy from GitHub → pilih repo ini

### 3. Set Environment Variables

| Variable | Wajib? | Default | Deskripsi |
|----------|--------|---------|-----------|
| `ZROK_TOKEN` | **⚠️ Wajib** | - | Token dari [myzrok.io](https://myzrok.io) |
| `ROOT_PASS` | Opsional | `DevCulture2026` | Password SSH root |
| `NTFY_TOPIC` | Opsional | `zrokIP22` | Topic ntfy untuk notifikasi |
| `TZ` | Opsional | `Asia/Jakarta` | Timezone |
| `PORT` | Opsional | `8080` | Port web UI |

### 4. Daftar zrok
1. Buka https://myzrok.io
2. Register (gratis)
3. Dapatkan token → set sebagai `ZROK_TOKEN`

### 5. Subscribe ntfy di HP (untuk notifikasi)
```
ntfy.sh/zrokIP22
```

---

## 🔐 Cara Akses SSH

Karena zrok menggunakan **private tunnel** untuk SSH, kamu perlu:

### Install zrok client (sekali saja)
```bash
# Linux
curl -fsSL https://github.com/openziti/zrok/releases/latest/download/zrok_0.4.30_linux_amd64.tar.gz \
  | tar -xz -C /usr/local/bin/ zrok

# macOS
brew install zrok
```

### Akses SSH tunnel
```bash
# Buka tunnel ke localhost:2222
zrok access private <TOKEN> --bind 127.0.0.1:2222

# SSH dari terminal lain
ssh root@127.0.0.1 -p 2222
```

> **TOKEN** dapat dilihat di notifikasi ntfy (`zrokIP22`) atau di log container.

---

## 🌐 Akses Web

zrok juga membuka **public tunnel** ke port 80 (Web UI) dan port 8080 (App):
```
https://xxxxx.zrok.io
```
URL akan muncul di notifikasi ntfy.

---

## 📲 Notifikasi ntfy

Semua notifikasi dikirim ke topic **`zrokIP22`**:

| Event | Notifikasi |
|-------|-----------|
| ⚡ VPS Online | SSH token + Web URL + password |
| 📊 Status (5 menit) | Uptime, RAM, Disk, Token SSH |
| 🚨 Tunnel Restart | Alert jika tunnel mati |

Subscribe: [ntfy.sh/zrokIP22](https://ntfy.sh/zrokIP22)

---

## 🏗 Struktur Proyek

```
rairu-kun2/
├── Dockerfile                 # Ubuntu 20.04 + zrok + supervisord
├── entrypoint.sh              # Startup config + supervisord
├── supervisord.conf           # Process manager (systemd alternative)
├── zrok-setup.sh              # zrok enable + tunnel manager + ntfy
├── watchdog.sh                # Service watchdog (SSH, Nginx)
├── nginx-web.conf              # Nginx config web UI
├── index.html                 # DevCulture Web UI
├── devculture-banner.sh       # SSH login banner
├── render.yaml                # Render deploy config
├── railway.json               # Railway deploy config
├── fly.toml                   # Fly.io deploy config
└── .github/workflows/
    └── railway-deploy.yml     # Auto-deploy CI/CD
```

---

## ⚙️ System Architecture

```
┌──────────────────────────────────┐
│         Supervisord              │
│  (systemd alternative)           │
├──────────────────────────────────┤
│  ┌──────┐ ┌──────┐ ┌──────────┐  │
│  │ SSH  │ │Nginx │ │ zrok     │  │
│  │sshd -D│ │:PORT│ │ Tunnel   │  │
│  └──────┘ └──────┘ │ Manager  │  │
│                    └──────────┘  │
│  ┌────────────────────────────┐  │
│  │ Watchdog                    │  │
│  │ (auto-restart dead services)│  │
│  └────────────────────────────┘  │
└──────────────────────────────────┘
         │
    ┌────┴────┐
    │  zrok   │ ← Zero-trust tunnel
    │  Cloud  │
    └─────────┘
    SSH / HTTPS
```

---

## ⚠️ Catatan Penting

- **zrok WAJIB** didaftarkan dulu di https://myzrok.io
- Satu akun zrok free bisa bikin banyak token
- **Tunnel murni** — VPS + SSH + tunnel, clean tanpa AI
- Semua service auto-restart via supervisord & watchdog
- Notifikasi dikirim ke ntfy.sh/zrokIP22

---

<div align="center">

**Dibuat dengan ❤️ oleh [DevCulture](https://github.com/clickmamaheti-prog)**

*Premium VPS via zrok · Supervisord Powered*

⭐ **Star repo ini jika membantu!** ⭐

```
powered by: DevCulture ©2026 linux
```

</div>
