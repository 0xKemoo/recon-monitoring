#!/bin/bash

set -eo pipefail

trap 'echo "[!] Error on line $LINENO"' ERR

LOCKFILE="/tmp/recon.lock"

if [ -f "$LOCKFILE" ]; then
    echo "[!] Script already running"
    exit 1
fi

trap "rm -f $LOCKFILE" EXIT
touch "$LOCKFILE"

# -----------------------------
# Config
# -----------------------------

BIN="/usr/local/bin"
WORK="$(pwd)/data"

TARGETS="$WORK/targets.txt"
OLD_SUBS="$WORK/old_subs.txt"

TOKEN=""
CHAT_ID=""

mkdir -p "$WORK"

echo "[+] Recon Started $(date)"

# -----------------------------
# Check targets file
# -----------------------------

if [ ! -f "$TARGETS" ]; then
    echo "example.com" > "$TARGETS"
    echo "[!] targets.txt created"
    exit 0
fi

# -----------------------------
# Update nuclei templates
# -----------------------------

$BIN/nuclei -update-templates -silent || true

# -----------------------------
# Subdomain discovery
# -----------------------------

echo "[+] Discovering subdomains"

$BIN/subfinder -dL "$TARGETS" -silent > "$WORK/subs1.txt"

while read domain
do
    $BIN/assetfinder --subs-only "$domain"
done < "$TARGETS" >> "$WORK/subs1.txt"

sort -u "$WORK/subs1.txt" > "$WORK/current_subs.txt"
rm "$WORK/subs1.txt"

touch "$OLD_SUBS"
sort -u "$OLD_SUBS" -o "$OLD_SUBS"
grep -vxf "$OLD_SUBS" "$WORK/current_subs.txt" > "$WORK/new_subs.txt" || :
sort -u "$WORK/new_subs.txt" -o "$WORK/new_subs.txt"
if [ ! -s "$WORK/new_subs.txt" ]; then
    echo "[!] No new subdomains"
    echo "[+] Recon Finished $(date)"
    exit 0
fi

echo "[+] New subdomains found"

# -----------------------------
# Live hosts
# -----------------------------

echo "[+] Checking live hosts"

$BIN/httpx \
-l "$WORK/new_subs.txt" \
-silent \
-t 80 \
-rl 100 \
-o "$WORK/live_subs.txt"

# -----------------------------
# Nuclei scan
# -----------------------------
echo "[+] Running nuclei"
touch "$WORK/nuclei.txt"
$BIN/nuclei \
-l "$WORK/live_subs.txt" \
-severity critical,high,medium \
-silent \
-rl 50 \
-o "$WORK/nuclei.txt" || true

# -----------------------------
# Telegram notification
# -----------------------------

MESSAGE="🚨 Recon Alert

New Subdomains: $(wc -l < $WORK/new_subs.txt)
Live Hosts: $(wc -l < $WORK/live_subs.txt)
Nuclei Findings: $(wc -l < $WORK/nuclei.txt)
"

curl -s \
-X POST \
"https://api.telegram.org/bot$TOKEN/sendMessage" \
-d chat_id="$CHAT_ID" \
-d text="$MESSAGE" > /dev/null

# -----------------------------
# Send files
# -----------------------------

send_file () {

FILE=$1
NAME=$(basename "$FILE")

if [ -s "$FILE" ]; then
curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendDocument" \
-F chat_id="$CHAT_ID" \
-F document=@"$FILE" \
> /dev/null
fi

}

send_file "$WORK/new_subs.txt"
send_file "$WORK/live_subs.txt"
send_file "$WORK/nuclei.txt"
# -----------------------------
# Update database
# -----------------------------

cat "$WORK/new_subs.txt" >> "$OLD_SUBS"

# -----------------------------
# Cleanup
# -----------------------------

rm -f "$WORK/current_subs.txt"
rm -f "$WORK/new_subs.txt"
rm -f "$WORK/live_subs.txt"
rm -f "$WORK/nuclei.txt"

echo "[+] Recon Finished $(date)"
