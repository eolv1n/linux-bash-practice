#!/usr/bin/env bash
set -euo pipefail

echo "== grep basics =="
grep -nE '^(root|daemon)' /etc/passwd || true
echo

echo "== find basics =="
find /etc -maxdepth 1 -type f -name "*.conf" | head -n 20 || true
echo

echo "== errors last 200 (journalctl) =="
journalctl -p err -n 200 2>/dev/null | wc -l || true
echo

echo "== ssh failed attempts (journald or files) =="
mkdir -p day2
: > day2/failed_ssh.log
(journalctl -u ssh --since "14 days ago" 2>/dev/null || true) | grep -E "Failed password|Invalid user" >> day2/failed_ssh.log || true
(journalctl -u sshd --since "14 days ago" 2>/dev/null || true) | grep -E "Failed password|Invalid user" >> day2/failed_ssh.log || true
journalctl --since "14 days ago" -t sshd 2>/dev/null | grep -E "Failed password|Invalid user" >> day2/failed_ssh.log || true
grep -hE "Failed password|Invalid user" /var/log/auth.log* 2>/dev/null >> day2/failed_ssh.log || true
echo "lines: $(wc -l < day2/failed_ssh.log || echo 0)"
echo

echo "== top IPs from failed_ssh.log =="
if [ -s day2/failed_ssh.log ]; then
  awk '{for(i=1;i<=NF;i++) if ($i ~ /([0-9]{1,3}\.){3}[0-9]{1,3}/) print $i }' day2/failed_ssh.log \
    | sort | uniq -c | sort -nr | head -n 10
else
  echo "no data"
fi
echo

echo "== text processing =="
cut -d: -f1,7 /etc/passwd | column -t -s: | head
echo
sed -E '/^\s*#/d; /^\s*$/d' /etc/hosts | head -n 10 || true
echo
echo "hello world" | tr '[:lower:]' '[:upper:]'
echo

echo "== sizes in /var/log (bytes sum) =="
find /var/log -type f -printf "%s\n" 2>/dev/null | awk '{s+=$1} END{print s+0}'
echo "done."
