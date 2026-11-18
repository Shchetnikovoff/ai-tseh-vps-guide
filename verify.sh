#!/usr/bin/env bash
# Проверка схемы Claude Code на VPS. Запускать на сервере от пользователя dev.
# Ничего не меняет, только читает и печатает.
set -u

ok=0
warn=0

line() { printf '%s\n' "$*"; }
check() {
  local name="$1" got="$2" want="$3"
  if [ "$got" = "$want" ]; then
    line "ok   $name: $got"
    ok=$((ok+1))
  else
    line "warn $name: $got (ожидалось: $want)"
    warn=$((warn+1))
  fi
}

line "== Кто я"
line "user: $(whoami)"
line "host: $(hostname)"
line ""

line "== Версии"
line "claude: $(command -v claude >/dev/null 2>&1 && claude --version 2>/dev/null || echo 'не найден')"
line "tmux: $(tmux -V 2>/dev/null || echo 'не найден')"
line ""

line "== Сеть"
ip="$(curl -fsS --max-time 10 https://ifconfig.me 2>/dev/null || echo 'не ответил')"
line "внешний IP: $ip"
line ""

line "== Порты"
if command -v ss >/dev/null 2>&1; then
  ss -tlnp 2>/dev/null | sed -n '1,40p'
else
  line "ss не найден"
fi
line ""

line "== Firewall"
if command -v ufw >/dev/null 2>&1; then
  ufw status 2>/dev/null || line "ufw status требует root"
else
  line "ufw не найден"
fi
line ""

line "== fail2ban"
if command -v fail2ban-client >/dev/null 2>&1; then
  fail2ban-client status sshd 2>/dev/null || line "jail sshd не найден или нужен root"
else
  line "fail2ban не найден"
fi
line ""

line "== tmux"
tmux ls 2>/dev/null || line "сессий нет"
line ""

line "== Итог"
line "проверок ok: $ok, предупреждений: $warn"
line "Если user не dev, ufw не active или в портах есть 3389, вернись к шагам 01-03."
