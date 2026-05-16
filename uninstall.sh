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
                "removing_watchdog") echo "Удаляем watchdog и cron задачу..." ;;
                "removing_packages") echo "Удаляем пакеты wireguard..." ;;
                "uninstall_complete") echo "Удаление завершено." ;;
                *) echo "$key" ;;
            esac
            ;;
        *)
            case "$key" in
                "root_required") echo "Script must be run as root." ;;
                "stopping_warp") echo "Stopping warp interface..." ;;
                "removing_watchdog") echo "Removing watchdog and cron job..." ;;
                "removing_packages") echo "Removing wireguard packages..." ;;
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

if ip link show warp &>/dev/null; then
    info "$(msg "stopping_warp")"
    wg-quick down warp &>/dev/null || true
fi

systemctl disable wg-quick@warp &>/dev/null || true

rm -f /etc/wireguard/warp.conf &>/dev/null
rm -rf /etc/wireguard &>/dev/null
rm -f /usr/local/bin/wgcf &>/dev/null
rm -f wgcf-account.toml wgcf-profile.conf &>/dev/null

info "$(msg "removing_watchdog")"
rm -f /etc/cron.d/warp-native &>/dev/null
rm -rf /opt/warp-native &>/dev/null

info "$(msg "removing_packages")"
DEBIAN_FRONTEND=noninteractive apt remove --purge -y wireguard &>/dev/null || true
DEBIAN_FRONTEND=noninteractive apt autoremove -y &>/dev/null || true

completed "$(msg "uninstall_complete")"
