# Day 2 examples
# Day 2 — grep/find/pipes

## Что делает `queries.sh`
1. Ищет строки `root|daemon` в `/etc/passwd`.
2. Находит `PermitRootLogin` рекурсивно в `/etc`.
3. Список `.conf` в `/etc` (уровень 1).
4. Логи, изменённые за сутки.
5. Топ-10 самых длинных логов.
6. Собирает неуспешные входы SSH в `day2/failed_ssh.log`.
7. Частотный анализ IP из `failed_ssh.log`.

## Как запустить
```bash
./day2/queries.sh
