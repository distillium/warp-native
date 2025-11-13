#!/bin/bash

SCRIPT_LANG=""


function select_language {
    if [ -z "$SCRIPT_LANG" ]; then
      echo -e "\n\e[1;35m╭─────────────────────────────────────╮"
      echo -e "│      \e[1;36m  W A R P - N A T I V E        \e[1;35m│"
      echo -e "│     \e[2;37m       by distillium            \e[1;35m│"
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
    fi

    clear
    echo -e "\n\e[1;35m╭─────────────────────────────────────╮"
    echo -e "│      \e[1;36m  W A R P - N A T I V E        \e[1;35m│"
    echo -e "│     \e[2;37m       by distillium            \e[1;35m│"
    echo -e "\e[1;35m╰─────────────────────────────────────╯\e[0m"
    sleep 1
}

function msg {
    local key="$1"
    case "$SCRIPT_LANG" in
        "ru")
            case "$key" in
                "root_required") echo "Этот скрипт должен быть запущен от имени root" ;;
                "start_install") echo "Начинаем установку и настройку Cloudflare WARP" ;;
                "install_wireguard") echo "1. Установка WireGuard..." ;;
                "update_failed") echo "Не удалось обновить список пакетов." ;;
                "wireguard_failed") echo "Не удалось установить WireGuard." ;;
                "wireguard_ok") echo "WireGuard установлен." ;;
                "temp_dns") echo "2. Назначение временных DNS (1.1.1.1 + 8.8.8.8), чтобы гарантировать установку и регистрацию wgcf..." ;;
                "dns_failed") echo "Не удалось настроить временные DNS-серверы." ;;
                "dns_ok") echo "Временные DNS-серверы установлены." ;;
                "download_wgcf") echo "3. Скачивание и установка wgcf..." ;;
                "wgcf_version_failed") echo "Не удалось получить последнюю версию wgcf" ;;
                "wgcf_download_failed") echo "Не удалось скачать wgcf." ;;
                "wgcf_chmod_failed") echo "Не удалось сделать wgcf исполняемым." ;;
                "wgcf_move_failed") echo "Не удалось переместить wgcf в /usr/local/bin." ;;
                "wgcf_installed") echo "установлен в /usr/local/bin/wgcf." ;;
                "arch_detected") echo "Определена архитектура:" ;;
                "register_wgcf") echo "4. Регистрация и генерация конфигурации wgcf..." ;;
                "account_exists") echo "Файл wgcf-account.toml уже существует. Пропускаем регистрацию." ;;
                "registering") echo "Выполняем регистрацию wgcf..." ;;
                "register_error") echo "wgcf register завершился с кодом" ;;
                "cf_error_500") echo "Возможна ошибка 500 от Cloudflare." ;;
                "known_behavior") echo "Это известное поведение: продолжаем попытку регистрации." ;;
                "registration_failed") echo "Регистрация не удалась: файл wgcf-account.toml не создан." ;;
                "account_created") echo "Файл wgcf-account.toml успешно создан. Продолжаем установку." ;;
                "wgcf_binary_check") echo "Проверяем бинарный файл wgcf..." ;;
                "wgcf_not_executable") echo "Бинарный файл wgcf не исполняется или имеет неправильную архитектуру." ;;
                "trying_alternative") echo "Пробуем альтернативный метод регистрации..." ;;
                "cf_500_detected") echo "Cloudflare вернул ошибку 500 Internal Server Error." ;;
                "cf_rate_limited") echo "Превышен лимит запросов к Cloudflare. Подождите и попробуйте позже." ;;
                "cf_forbidden") echo "Доступ запрещен Cloudflare." ;;
                "network_issue") echo "Проблемы с сетевым подключением." ;;
                "unknown_error") echo "Произошла неизвестная ошибка:" ;;
                "config_generated") echo "Конфигурация wgcf успешно сгенерирована." ;;
                "config_gen_failed") echo "Ошибка при генерации конфигурации wgcf." ;;
                "edit_config") echo "5. Редактирование конфигурации WARP..." ;;
                "config_not_found") echo "не найден." ;;
                "dns_removed") echo "Не удалось удалить строку DNS из конфигурации." ;;
                "table_off_failed") echo "Не удалось добавить Table = off." ;;
                "keepalive_failed") echo "Не удалось добавить PersistentKeepalive = 25." ;;
                "wireguard_dir_failed") echo "Не удалось создать директорию /etc/wireguard." ;;
                "config_move_failed") echo "Не удалось переместить конфигурацию." ;;
                "config_saved") echo "Конфигурация сохранена в /etc/wireguard/warp.conf." ;;
                "check_ipv6") echo "6. Проверка включён ли IPv6 и настройка конфигурации WARP..." ;;
                "ipv6_enabled") echo "IPv6 включён на сервере — оставляем IPv6-адрес в конфигурации WARP." ;;
                "ipv6_disabled") echo "IPv6 отключён или не настроен на сервере — удаляем IPv6-адрес из конфигурации WARP." ;;
                "ipv6_removed") echo "IPv6-адрес удалён из конфигурации." ;;
                "connect_warp") echo "7. Подключение интерфейса WARP..." ;;
                "connect_failed") echo "Не удалось подключить интерфейс." ;;
                "warp_connected") echo "Интерфейс WARP успешно подключен." ;;
                "check_status") echo "8. Проверка статуса подключения WARP..." ;;
                "warp_not_found") echo "Интерфейс WARP не найден — туннель не работает." ;;
                "handshake_received") echo "Получен handshake →" ;;
                "warp_active") echo "WARP подключён и активно обменивается трафиком." ;;
                "handshake_failed") echo "Не удалось получить handshake в течении 10 секунд. Возможны проблемы с подключением." ;;
                "cf_response") echo "Ответ от Cloudflare: warp=on" ;;
                "cf_not_confirmed") echo "Cloudflare не подтвердил warp=on, но интерфейс работает. Это нормально." ;;
                "enable_autostart") echo "9. Включение автозапуска WARP при старте..." ;;
                "autostart_failed") echo "Не удалось настроить автозапуск." ;;
                "autostart_enabled") echo "Автозапуск включен." ;;
                "installation_complete") echo "Установка и настройка Cloudflare WARP завершены!" ;;
                "check_service") echo "Проверить статус службы:" ;;
                "show_info") echo "Посмотреть информацию (WG):" ;;
                "stop_interface") echo "Остановить интерфейс:" ;;
                "start_interface") echo "Запустить интерфейс:" ;;
                "restart_interface") echo "Перезапустить интерфейс:" ;;
                "disable_autostart") echo "Отключить автозапуск:" ;;
                "enable_autostart_cmd") echo "Включить автозапуск:" ;;
                "dns_restored") echo "DNS возвращены к заводскому состоянию (восстановлены из резервной копии)" ;;
                *) echo "$key" ;;
            esac
            ;;
        *)
            case "$key" in
                "root_required") echo "This script must be run as root" ;;
                "start_install") echo "Starting Cloudflare WARP installation and configuration" ;;
                "install_wireguard") echo "1. Installing WireGuard..." ;;
                "update_failed") echo "Failed to update package list." ;;
                "wireguard_failed") echo "Failed to install WireGuard." ;;
                "wireguard_ok") echo "WireGuard installed." ;;
                "temp_dns") echo "2. Setting temporary DNS (1.1.1.1 + 8.8.8.8) to ensure wgcf installation and registration..." ;;
                "dns_failed") echo "Failed to configure temporary DNS servers." ;;
                "dns_ok") echo "Temporary DNS servers configured." ;;
                "download_wgcf") echo "3. Downloading and installing wgcf..." ;;
                "wgcf_version_failed") echo "Failed to get latest wgcf version" ;;
                "wgcf_download_failed") echo "Failed to download wgcf." ;;
                "wgcf_chmod_failed") echo "Failed to make wgcf executable." ;;
                "wgcf_move_failed") echo "Failed to move wgcf to /usr/local/bin." ;;
                "wgcf_installed") echo "installed to /usr/local/bin/wgcf." ;;
                "arch_detected") echo "Detected architecture:" ;;
                "register_wgcf") echo "4. Registering and generating wgcf configuration..." ;;
                "account_exists") echo "wgcf-account.toml file already exists. Skipping registration." ;;
                "registering") echo "Performing wgcf registration..." ;;
                "register_error") echo "wgcf register exited with code" ;;
                "cf_error_500") echo "Possible 500 error from Cloudflare." ;;
                "known_behavior") echo "This is known behavior: continuing registration attempt." ;;
                "registration_failed") echo "Registration failed: wgcf-account.toml file not created." ;;
                "account_created") echo "wgcf-account.toml file successfully created. Continuing installation." ;;
                "wgcf_binary_check") echo "Checking wgcf binary..." ;;
                "wgcf_not_executable") echo "wgcf binary is not executable or has wrong architecture." ;;
                "trying_alternative") echo "Trying alternative registration method..." ;;
                "cf_500_detected") echo "Cloudflare returned 500 Internal Server Error." ;;
                "cf_rate_limited") echo "Rate limited by Cloudflare. Please wait and try again later." ;;
                "cf_forbidden") echo "Access forbidden by Cloudflare." ;;
                "network_issue") echo "Network connection issue." ;;
                "unknown_error") echo "Unknown error occurred:" ;;
                "config_generated") echo "wgcf configuration successfully generated." ;;
                "config_gen_failed") echo "Error generating wgcf configuration." ;;
                "edit_config") echo "5. Editing WARP configuration..." ;;
                "config_not_found") echo "not found." ;;
                "dns_removed") echo "Failed to remove DNS line from configuration." ;;
                "table_off_failed") echo "Failed to add Table = off." ;;
                "keepalive_failed") echo "Failed to add PersistentKeepalive = 25." ;;
                "wireguard_dir_failed") echo "Failed to create /etc/wireguard directory." ;;
                "config_move_failed") echo "Failed to move configuration." ;;
                "config_saved") echo "Configuration saved to /etc/wireguard/warp.conf." ;;
                "check_ipv6") echo "6. Checking if IPv6 is enabled and configuring WARP..." ;;
                "ipv6_enabled") echo "IPv6 is enabled on server — keeping IPv6 address in WARP configuration." ;;
                "ipv6_disabled") echo "IPv6 is disabled or not configured on server — removing IPv6 address from WARP configuration." ;;
                "ipv6_removed") echo "IPv6 address removed from configuration." ;;
                "connect_warp") echo "7. Connecting WARP interface..." ;;
                "connect_failed") echo "Failed to connect interface." ;;
                "warp_connected") echo "WARP interface successfully connected." ;;
                "check_status") echo "8. Checking WARP connection status..." ;;
                "warp_not_found") echo "WARP interface not found — tunnel is not working." ;;
                "handshake_received") echo "Handshake received →" ;;
                "warp_active") echo "WARP is connected and actively exchanging traffic." ;;
                "handshake_failed") echo "Failed to get handshake within 10 seconds. Connection problems possible." ;;
                "cf_response") echo "Cloudflare response: warp=on" ;;
                "cf_not_confirmed") echo "Cloudflare did not confirm warp=on, but interface is working. This is normal." ;;
                "enable_autostart") echo "9. Enabling WARP autostart on boot..." ;;
                "autostart_failed") echo "Failed to configure autostart." ;;
                "autostart_enabled") echo "Autostart enabled." ;;
                "installation_complete") echo "Cloudflare WARP installation and configuration completed!" ;;
                "check_service") echo "Check service status:" ;;
                "show_info") echo "Show information (WG):" ;;
                "stop_interface") echo "Stop interface:" ;;
                "start_interface") echo "Start interface:" ;;
                "restart_interface") echo "Restart interface:" ;;
                "disable_autostart") echo "Disable autostart:" ;;
                "enable_autostart_cmd") echo "Enable autostart:" ;;
                "dns_restored") echo "DNS restored to factory state (restored from backup)" ;;
                *) echo "$key" ;;
            esac
            ;;
    esac
}

function ok {
    echo -e "\e[1;32m[OK]\e[0m $1"
}

function warn {
    echo -e "\e[1;33m[WARN]\e[0m $1"
}

function fail {
    echo -e "\e[1;31m[FAIL]\e[0m $1"
}

function info {
    echo -e "\e[1;34m[INFO]\e[0m $1"
}

function error_exit {
    fail "$1"
    exit 1
}

RESTORE_DNS_REQUIRED=false

function restore_dns {
    if [[ "$RESTORE_DNS_REQUIRED" == true && -f /etc/resolv.conf.backup ]]; then
        cp /etc/resolv.conf.backup /etc/resolv.conf
        ok "$(msg "dns_restored")"
        RESTORE_DNS_REQUIRED=false
    fi
}

trap restore_dns EXIT

if [[ $EUID -ne 0 ]]; then
    fail "This script must be run as root / Этот скрипт должен быть запущен от имени root"
    exit 1
fi

case $1 in
  ru)
    SCRIPT_LANG="ru";;
  en)
    SCRIPT_LANG="en";;
esac

select_language

cd $HOME
info "$(msg "start_install")"
echo ""

info "$(msg "install_wireguard")"
apt update -qq &>/dev/null || error_exit "$(msg "update_failed")"
apt install wireguard -y &>/dev/null || error_exit "$(msg "wireguard_failed")"
ok "$(msg "wireguard_ok")"
echo ""

info "$(msg "temp_dns")"
cp /etc/resolv.conf /etc/resolv.conf.backup
RESTORE_DNS_REQUIRED=true
echo -e "nameserver 1.1.1.1\nnameserver 8.8.8.8" > /etc/resolv.conf || error_exit "$(msg "dns_failed")"
ok "$(msg "dns_ok")"
echo ""

info "$(msg "download_wgcf")"
WGCF_RELEASE_URL="https://api.github.com/repos/ViRb3/wgcf/releases/latest"
WGCF_VERSION=$(curl -s "$WGCF_RELEASE_URL" | grep tag_name | cut -d '"' -f 4)

if [ -z "$WGCF_VERSION" ]; then
    error_exit "$(msg "wgcf_version_failed")"
fi

ARCH=$(uname -m)
case $ARCH in
    x86_64) WGCF_ARCH="amd64" ;;
    aarch64|arm64) WGCF_ARCH="arm64" ;;
    armv7l) WGCF_ARCH="armv7" ;;
    *) WGCF_ARCH="amd64" ;;
esac

info "$(msg "arch_detected") $ARCH -> $WGCF_ARCH"

WGCF_DOWNLOAD_URL="https://github.com/ViRb3/wgcf/releases/download/${WGCF_VERSION}/wgcf_${WGCF_VERSION#v}_linux_${WGCF_ARCH}"
WGCF_BINARY_NAME="wgcf_${WGCF_VERSION#v}_linux_${WGCF_ARCH}"

wget -q "$WGCF_DOWNLOAD_URL" -O "$WGCF_BINARY_NAME" || error_exit "$(msg "wgcf_download_failed")"

chmod +x "$WGCF_BINARY_NAME" || error_exit "$(msg "wgcf_chmod_failed")"
mv "$WGCF_BINARY_NAME" /usr/local/bin/wgcf || error_exit "$(msg "wgcf_move_failed")"
ok "wgcf $WGCF_VERSION $(msg "wgcf_installed")"
echo ""

info "$(msg "register_wgcf")"

if [[ -f wgcf-account.toml ]]; then
    info "$(msg "account_exists")"
else
    info "$(msg "registering")"
    
    info "$(msg "wgcf_binary_check")"
    if ! wgcf --help &>/dev/null; then
        warn "$(msg "wgcf_not_executable")"
        chmod +x /usr/local/bin/wgcf
        if ! wgcf --help &>/dev/null; then
            error_exit "$(msg "wgcf_not_executable")"
        fi
    fi
    
    output=$(timeout 60 bash -c 'yes | wgcf register' 2>&1)
    ret=$?

    if [[ $ret -ne 0 ]]; then
        warn "$(msg "register_error") $ret."
        
        if [[ $ret -eq 126 ]]; then
            warn "$(msg "wgcf_not_executable")"
        elif [[ $ret -eq 124 ]]; then
            warn "Registration timed out after 60 seconds."
        elif [[ "$output" == *"500 Internal Server Error"* ]]; then
            warn "$(msg "cf_500_detected")"
            info "$(msg "known_behavior")"
        elif [[ "$output" == *"429"* || "$output" == *"Too Many Requests"* ]]; then
            warn "$(msg "cf_rate_limited")"
        elif [[ "$output" == *"403"* || "$output" == *"Forbidden"* ]]; then
            warn "$(msg "cf_forbidden")"
        elif [[ "$output" == *"network"* || "$output" == *"connection"* ]]; then
            warn "$(msg "network_issue")"
        else
            warn "$(msg "unknown_error")"
            echo "$output"
        fi
        
        info "$(msg "trying_alternative")"
        echo | wgcf register &>/dev/null || true
        
        sleep 2
    fi

    if [[ ! -f wgcf-account.toml ]]; then
        error_exit "$(msg "registration_failed")"
    fi

    info "$(msg "account_created")"
fi

wgcf generate &>/dev/null || error_exit "$(msg "config_gen_failed")"
ok "$(msg "config_generated")"
echo ""

info "$(msg "edit_config")"
WGCF_CONF_FILE="wgcf-profile.conf"

if [ ! -f "$WGCF_CONF_FILE" ]; then
    error_exit "$(msg "config_not_found" | sed "s/не найден/Файл $WGCF_CONF_FILE не найден/" | sed "s/not found/File $WGCF_CONF_FILE not found/")"
fi

sed -i '/^DNS =/d' "$WGCF_CONF_FILE" || error_exit "$(msg "dns_removed")"

if ! grep -q "Table = off" "$WGCF_CONF_FILE"; then
    sed -i '/^MTU =/aTable = off' "$WGCF_CONF_FILE" || error_exit "$(msg "table_off_failed")"
fi

if ! grep -q "PersistentKeepalive = 25" "$WGCF_CONF_FILE"; then
    sed -i '/^Endpoint =/aPersistentKeepalive = 25' "$WGCF_CONF_FILE" || error_exit "$(msg "keepalive_failed")"
fi

mkdir -p /etc/wireguard || error_exit "$(msg "wireguard_dir_failed")"
mv "$WGCF_CONF_FILE" /etc/wireguard/warp.conf || error_exit "$(msg "config_move_failed")"
ok "$(msg "config_saved")"
echo ""

info "$(msg "check_ipv6")"

is_ipv6_enabled() {
    sysctl net.ipv6.conf.all.disable_ipv6 2>/dev/null | grep -q ' = 0' || return 1
    sysctl net.ipv6.conf.default.disable_ipv6 2>/dev/null | grep -q ' = 0' || return 1
    ip -6 addr show scope global | grep -qv 'inet6 .*fe80::' || return 1
    return 0
}

if is_ipv6_enabled; then
    ok "$(msg "ipv6_enabled")"
else
    warn "$(msg "ipv6_disabled")"
    sed -i 's/,\s*[0-9a-fA-F:]\+\/128//' /etc/wireguard/warp.conf
    sed -i '/Address = [0-9a-fA-F:]\+\/128/d' /etc/wireguard/warp.conf
    ok "$(msg "ipv6_removed")"
fi
echo ""

info "$(msg "connect_warp")"
systemctl start wg-quick@warp &>/dev/null || error_exit "$(msg "connect_failed")"
ok "$(msg "warp_connected")"
echo ""

info "$(msg "check_status")"

if ! wg show warp &>/dev/null; then
    fail "$(msg "warp_not_found")"
    exit 1
fi

for i in {1..10}; do
    handshake=$(wg show warp | grep "latest handshake" | awk -F': ' '{print $2}')
    if [[ "$handshake" == *"second"* || "$handshake" == *"minute"* ]]; then
        ok "$(msg "handshake_received") $handshake"
        ok "$(msg "warp_active")"
        break
    fi
    sleep 1
done

if [[ -z "$handshake" || "$handshake" == "0 seconds ago" ]]; then
    warn "$(msg "handshake_failed")"
fi

curl_result=$(curl -s --interface warp https://www.cloudflare.com/cdn-cgi/trace | grep "warp=" | cut -d= -f2)

if [[ "$curl_result" == "on" ]]; then
    ok "$(msg "cf_response")"
else
    warn "$(msg "cf_not_confirmed")"
fi
echo ""

info "$(msg "enable_autostart")"
systemctl enable wg-quick@warp &>/dev/null || error_exit "$(msg "autostart_failed")"
ok "$(msg "autostart_enabled")"
echo ""

restore_dns
ok "$(msg "installation_complete")"
echo ""
echo -e "\e[1;36m➤ $(msg "check_service"): \e[0msystemctl status wg-quick@warp"
echo -e "\e[1;36m➤ $(msg "show_info"): \e[0mwg show warp"
echo -e "\e[1;36m➤ $(msg "stop_interface"): \e[0msystemctl stop wg-quick@warp"
echo -e "\e[1;36m➤ $(msg "start_interface"): \e[0msystemctl start wg-quick@warp"
echo -e "\e[1;36m➤ $(msg "restart_interface"): \e[0msystemctl restart wg-quick@warp"
echo -e "\e[1;36m➤ $(msg "disable_autostart"): \e[0msystemctl disable wg-quick@warp"
echo -e "\e[1;36m➤ $(msg "enable_autostart_cmd"): \e[0msystemctl enable wg-quick@warp"
echo ""
