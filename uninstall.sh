#!/bin/bash

set -e

SCRIPT_LANG=""

function select_language {
    echo -e "\n\e[1;35m╭─────────────────────────────────────╮"
    echo -e "│      \e[1;36m  W A R P - N A T I V E        \e[1;35m│"
    echo -e "│      \e[1;31mUNINSTALLER\e[2;37m by distillium      \e[1;35m│"
    echo -e "\e[1;35m╰─────────────────────────────────────╯\e[0m"
    echo ""
    echo -e "\e[1;34mSelect language / Выберите язык:\e[0m"
    echo -e "\e[1;32m1)\e[0m English"
    echo -e "\e[1;32m2)\e[0m Русский"
    echo ""
    
    while true; do
        read -p "Choice / Выбор [1-2]: " choice
        case $choice in
            1) SCRIPT_LANG="en"; break ;;
            2) SCRIPT_LANG="ru"; break ;;
            *) echo -e "\e[1;31mInvalid choice / Неверный выбор\e[0m" ;;
        esac
    done
    
    clear
    echo -e "\n\e[1;35m╭─────────────────────────────────────╮"
    echo -e "│      \e[1;36m  W A R P - N A T I V E        \e[1;35m│"
    echo -e "│      \e[1;31mUNINSTALLER\e[2;37m by distillium      \e[1;35m│"
    echo -e "\e[1;35m╰─────────────────────────────────────╯\e[0m"
    sleep 1
}

function msg {
    local key="$1"
    case "$SCRIPT_LANG" in
        "ru")
            case "$key" in
                "root_required") echo "Скрипт должен быть запущен от root." ;;
                "stopping_warp") echo "Отключаем интерфейс warp..." ;;
                "removing_watchdog") echo "Удаляем watchdog, kill-switch и cron задачу..." ;;
                "removing_packages") echo "Удаляем пакеты wireguard..." ;;
                "wg_kept") echo "Найдены другие конфигурации WireGuard — пакеты wireguard не удаляются." ;;
                "uninstall_complete") echo "Удаление завершено." ;;
                *) echo "$key" ;;
            esac
            ;;
        *)
            case "$key" in
                "root_required") echo "Script must be run as root." ;;
                "stopping_warp") echo "Stopping warp interface..." ;;
                "removing_watchdog") echo "Removing watchdog, kill-switch and cron job..." ;;
                "removing_packages") echo "Removing wireguard packages..." ;;
                "wg_kept") echo "Other WireGuard configurations found — wireguard packages are kept." ;;
                "uninstall_complete") echo "Uninstallation completed." ;;
                *) echo "$key" ;;
            esac
            ;;
    esac
}

function info {
    echo -e "\e[1;33m[INFO]\e[0m $1"
}

function warn {
    echo -e "\e[1;31m[WARN]\e[0m $1"
}

function completed {
    echo -e "\e[1;32m[COMPLETED]\e[0m $1"
}

if [[ $EUID -ne 0 ]]; then
    warn "This script must be run as root / Скрипт должен быть запущен от root."
    exit 1
fi

select_language
cd "$HOME"

### Останавливаем через systemd, иначе юнит зависнет в active (exited)
info "$(msg "stopping_warp")"
systemctl disable --now wg-quick@warp &>/dev/null || true
if ip link show warp &>/dev/null; then
    wg-quick down warp &>/dev/null || ip link delete warp &>/dev/null || true
fi

### kill-switch останавливаем ДО удаления /opt/warp-native - его ExecStop вызывает скрипт оттуда
info "$(msg "removing_watchdog")"
rm -f /etc/cron.d/warp-native
systemctl disable --now warp-native-killswitch.service &>/dev/null || true
nft delete table inet warp_native &>/dev/null || true

rm -f /etc/systemd/system/warp-native-killswitch.service
rm -f /etc/systemd/system/wg-quick@warp.service.d/warp-native-killswitch.conf
rm -f /etc/systemd/system/nftables.service.d/warp-native-killswitch.conf
rmdir /etc/systemd/system/wg-quick@warp.service.d /etc/systemd/system/nftables.service.d &>/dev/null || true

systemctl daemon-reload &>/dev/null || true
systemctl reset-failed wg-quick@warp warp-native-killswitch.service &>/dev/null || true

rm -rf /opt/warp-native
rm -f /usr/local/bin/warp /usr/local/bin/wgcf

### Только конфиг WARP - остальные конфигурации WireGuard не трогаем
rm -f /etc/wireguard/warp.conf
rmdir /etc/wireguard &>/dev/null || true

### Остатки wgcf от старых версий в $HOME (новые уже удалены вместе с /opt/warp-native)
rm -f "$HOME/wgcf-account.toml" "$HOME/wgcf-profile.conf"

### Пакеты удаляем только если других WireGuard-конфигов нет
info "$(msg "removing_packages")"
if [[ -d /etc/wireguard ]] || [[ -n "$(wg show interfaces 2>/dev/null)" ]]; then
    info "$(msg "wg_kept")"
else
    DEBIAN_FRONTEND=noninteractive apt remove --purge -y wireguard wireguard-tools &>/dev/null || true
fi

completed "$(msg "uninstall_complete")"
