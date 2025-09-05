#!/usr/bin/env bash
set -euo pipefail

# ===== Day 2: grep/find/pipes =====

echo "1) grep: строки root/daemon из /etc/passwd"
grep -nE '^(root|daemon)' /etc/passwd || true
echo

echo "2) grep - рекурсивно по /etc для PermitRootLogin"
grep -R --line-number --color=never "PermitRootLogin" /etc 2>/dev/null | head -n 20 || true
echo

echo "3) find: .conf в /etc (верхний уровень)"
find /etc -maxdepth 1 -type f -name "*.conf" 2>/dev/null | head -n 20 || true
echo

echo "4) find: изменённые за сутки лог-файлы"
find /var/log -type f -mtime -1 2>/dev/null | head -n 20 || true
echo

echo "5) топ-10 самых длинных лог-файлов"
find /var/log -type f 2>/dev/null \
 | xargs wc -l 2>/dev/null \
 | sort -n | tail -n 10 || true
echo

mkdir -p day2
echo "6) собираем неуспешные входы SSH -> day2/failed_ssh.log"
grep -h "Failed password" /var/log/auth.log* 2>/dev/null > day2/failed_ssh.log || true
grep -h "Invalid user"   /var/log/auth.log* 2>/dev/null >> day2/failed_ssh.log || true
echo "   записано: $(wc -l < day2/failed_ssh.log 2>/dev/null || echo 0) строк"
echo

echo "7) частотный анализ IP из failed_ssh.log"
awk '{for(i=1;i<=NF;i++) if ($i ~ /([0-9]{1,3}\.){3}[0-9]{1,3}/) print $i }' day2/failed_ssh.log 2>/dev/null \
 | sort | uniq -c | sort -nr | head || true
echo

echo
echo "8) примеры перенаправления stdout/stderr"
journalctl -p err -n 50 2>/dev/null | wc -l || true
dmesg | tail -n 30 > day2/dmesg_tail.txt 2>/dev/null || true
echo "   сохранено: day2/dmesg_tail.txt"
echo

echo "9) частотность слов (uniq -c + sort)"
grep -h 'Failed password' /var/log/auth.log* 2>/dev/null \
 | awk '{print $(NF-3)}' \
 | sort | uniq -c | sort -nr | head -n 10 || true
echo

echo "10) xargs: строки во всех .conf из /etc"
find /etc -type f -name '*.conf' 2>/dev/null \
 | xargs -r cat 2>/dev/null | wc -l || true
echo

echo "11) awk: имя пользователя и shell из /etc/passwd"
awk -F: '{print $1, $7}' /etc/passwd | head || true
echo

echo "Done."
