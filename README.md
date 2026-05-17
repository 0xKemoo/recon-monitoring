# Recon Monitoring

<p align="center">
  <img src="assets/banner.png" width="100%">
</p>

<p align="center">
Automated reconnaissance and attack surface monitoring pipeline.
</p>

---

# Features

* Continuous reconnaissance
* Subdomain discovery
* Live host detection
* Automated nuclei scanning
* Telegram notifications
* Auto deduplication
* Lockfile protection

---

# Tools

* subfinder
* assetfinder
* httpx
* nuclei
* curl

---

# Installation

```bash
git clone https://github.com/0xKemoo/recon-monitoring.git

cd recon-monitoring

chmod +x subs-notify.sh
```

---

# First Time Setup

## 1. Configure Telegram

Open:

```bash
nano subs-notify.sh
```

Add:

```bash
TOKEN="YOUR_BOT_TOKEN"
CHAT_ID="YOUR_CHAT_ID"
```

Example:

```bash
TOKEN="123456:ABCDEF"
CHAT_ID="123456789"
```

---

## 2. Add targets

Open:

```bash
nano recon/targets.txt
```

Example:

```text
example.com
target.com
```

---

# Usage

```bash
./subs-notify.sh
```

---

# Cron Example

Run every 6 hours:

```bash
0 */6 * * * /path/to/subs-notify.sh >> /tmp/recon.log 2>&1
```

---

# Output

* New subdomains
* Live hosts
* Nuclei findings
* Telegram alerts

---

# Repository Structure

```text
recon-monitoring/
├── assets/
├── recon/
│   ├── targets.txt
│   └── old_subs.txt
├── README.md
└── subs-notify.sh
```

---

# Disclaimer

This project is intended for authorized security testing and educational purposes only.
