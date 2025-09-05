#!/usr/bin/env bash
set -euo pipefail

# ===== Day 2: grep/find/pipes =====

echo "1) grep: строки root/daemon из /etc/passwd"
grep -nE '^(root|daemon)' /etc/passwd || true
echo

echo "2) поиск PermitRootLogin по системе (если ssh установлен)"
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

# --- 6) собираем неуспешные входы SSH (journald или файлы)
mkdir -p day2
: > day2/failed_ssh.log

# Вариант A: через journald (если есть sshd/ssh.service)
if command -v journalctl >/dev/null; then
  echo "6A) journalctl: неуспешные SSH попытки за 14 дней -> day2/failed_ssh.log"
  # пробуем по unit, по идентификатору и по сообщению
  (journalctl -u ssh --since "14 days ago" 2>/dev/null || true) | grep -E "Failed password|Invalid user" >> day2/failed_ssh.log || true
  (journalctl -u sshd --since "14 days ago" 2>/dev/null || true) | grep -E "Failed password|Invalid user" >> day2/failed_ssh.log || true
  journalctl --since "14 days ago" -t sshd 2>/dev/null | grep -E "Failed password|Invalid user" >> day2/failed_ssh.log || true
fi

# Вариант B: через файлы (Debian/Ubuntu)
grep -hE "Failed password|Invalid user" /var/log/auth.log* 2>/dev/null >> day2/failed_ssh.log || true

echo "   записано: $(wc -l < day2/failed_ssh.log 2>/dev/null || echo 0) строк"
echo

# --- 7) частотный анализ IP (если есть данные)
if [ -s day2/failed_ssh.log ]; then
  echo "7) частотный анализ IP из failed_ssh.log (топ-10)"
  awk '{for(i=1;i<=NF;i++) if ($i ~ /([0-9]{1,3}\.){3}[0-9]{1,3}/) print $i }' day2/failed_ssh.log \
    | sort | uniq -c | sort -nr | head || true
else
  echo "7) данных нет (failed_ssh.log пуст) — на хосте либо нет sshd, либо не было неуспешных попыток."
fi
echo

# --- 8) перенаправления: счётчик ошибок journald
echo "8) сколько последних записей уровня error (journalctl -p err -n 200)"
journalctl -p err -n 200 2>/dev/null | wc -l || true
echo

# --- 9) dmesg: безопасно через sudo (если разрешено)
echo "9) dmesg (последние 30 строк) -> day2/dmesg_tail.txt"
if sudo -n true 2>/dev/null; then
  sudo dmesg | tail -n 30 > day2/dmesg_tail.txt 2>/dev/null || true
else
  echo "   (нет sudo без пароля: попробую dmesg без sudo)"
  dmesg | tail -n 30 > day2/dmesg_tail.txt 2>/dev/null || true
fi
[ -s day2/dmesg_tail.txt ] && echo "   сохранено: day2/dmesg_tail.txt" || echo "   не удалось прочитать dmesg"
echo


echo "10) xargs: строки во всех .conf из /etc"find /etc -type f -name '*.conf' 2>/dev/null \
 | xargs -r cat 2>/dev/null | wc -l || true
echo

echo "11) awk: имя пользователя и shell из /etc/passwd"
awk -F: '{print $1, $7}' /etc/passwd | head || true
echo

echo "Done."
