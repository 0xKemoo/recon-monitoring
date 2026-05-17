# Recon Monitoring

Automated reconnaissance and attack surface monitoring pipeline.

## Features

- Subdomain discovery
- Live host checking
- Nuclei scanning
- Telegram alerts
- Auto deduplication

## Tools

- subfinder
- assetfinder
- httpx
- nuclei

---

# First Time Setup

## 1. Make script executable

```bash
chmod +x subsnotify.sh
. Edit Telegram configuration

Open:

nano subsnotify.sh

Add your Telegram bot token and chat ID:

TOKEN="YOUR_BOT_TOKEN"
CHAT_ID="YOUR_CHAT_ID"

Example:

TOKEN="123456:ABCDEF"
CHAT_ID="123456789"

Save and exit.

3. Add targets

Open the file:

nano recon/targets.txt

Add your targets:

example.com
target.com

Save the file.

4. Run reconnaissance
./subsnotify.sh
Cron Example

Run every 6 hours:

0 */6 * * * /path/to/subsnotify.sh >> /tmp/recon.log 2>&1
