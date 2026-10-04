#!/bin/bash

SCRIPT_LANG=""

### IPv4 endpoint WARP — прибит принудительно, чтобы не зависеть от DNS (имя резолвится и в IPv6)
WARP_ENDPOINT_V4="162.159.192.1:2408"

### Файлы wgcf держим в директории проекта
WGCF_DIR="/opt/warp-native/wgcf"

function select_language {
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
                "no_downloader") echo "Не найден wget или curl. Установите один из них и повторите." ;;
                "register_wgcf") echo "4. Регистрация и генерация конфигурации wgcf..." ;;
                "account_exists") echo "Файл wgcf-account.toml уже существует. Пропускаем регистрацию." ;;
                "account_reuse_hint") echo "Используется существующий аккаунт. Если после установки не будет связи — удалите /opt/warp-native/wgcf/wgcf-account.toml и переустановите для чистой регистрации." ;;
                "account_migrated") echo "Аккаунт wgcf перенесён из домашней директории в /opt/warp-native/wgcf." ;;
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
                "warp_plus_prompt") echo "Если у вас есть WARP+ ключ, вы можете его применить." ;;
                "enter_license") echo "Введите лицензионный ключ WARP+ (Enter - пропустить): " ;;
                "applying_license") echo "Применение WARP+ лицензии..." ;;
                "license_applied") echo "WARP+ лицензия успешно применена!" ;;
                "license_failed") echo "Не удалось применить лицензию. Проверьте ключ." ;;
                "license_not_applied") echo "WARP+ ключ введён, но лицензия не была применена. Используется бесплатная версия." ;;
                "continuing_free") echo "Продолжаем с бесплатной версией WARP." ;;
                "skipping_license") echo "Пропускаем применение WARP+ лицензии." ;;
                "config_regenerated") echo "Конфигурация перегенерирована с WARP+." ;;
                "edit_config") echo "5. Редактирование конфигурации WARP..." ;;
                "config_not_found") echo "не найден." ;;
                "dns_removed") echo "Не удалось удалить строку DNS из конфигурации." ;;
                "table_off_failed") echo "Не удалось добавить Table = off." ;;
                "keepalive_failed") echo "Не удалось добавить PersistentKeepalive = 25." ;;
                "wireguard_dir_failed") echo "Не удалось создать директорию /etc/wireguard." ;;
                "config_move_failed") echo "Не удалось переместить конфигурацию." ;;
                "config_saved") echo "Конфигурация сохранена в /etc/wireguard/warp.conf." ;;
                "check_ipv6") echo "6. Настройка только IPv4: удаление IPv6 из конфигурации и фиксация IPv4-endpoint..." ;;
                "ipv6_removed") echo "IPv6 удалён из конфигурации, endpoint зафиксирован на IPv4." ;;
                "connect_warp") echo "7. Подключение интерфейса WARP..." ;;
                "connect_failed") echo "Не удалось подключить интерфейс." ;;
                "warp_connected") echo "Интерфейс WARP успешно подключен." ;;
                "check_status") echo "8. Проверка статуса подключения WARP..." ;;
                "warp_not_found") echo "Интерфейс WARP не найден — туннель не работает." ;;
                "handshake_received") echo "Получен handshake →" ;;
                "warp_active") echo "WARP подключён и активно обменивается трафиком." ;;
                "waiting_handshake") echo "Ожидание подключения" ;;
                "handshake_pending") echo "Туннель ещё поднимается — проверю связь ниже." ;;
                "cf_response") echo "Ответ от Cloudflare: warp=on" ;;
                "cf_not_confirmed") echo "Cloudflare не подтвердил warp=on, но интерфейс работает. Это нормально." ;;
                "warp_plus_active") echo "WARP+ активирован" ;;
                "warp_free_active") echo "Используется бесплатная версия WARP" ;;
                "enable_autostart") echo "9. Включение автозапуска WARP при старте..." ;;
                "autostart_failed") echo "Не удалось настроить автозапуск." ;;
                "autostart_enabled") echo "Автозапуск включен." ;;
                "setup_watchdog") echo "10. Настройка WARP Watchdog..." ;;
                "watchdog_interval_prompt") echo "Выберите интервал проверки watchdog:" ;;
                "watchdog_opt_5") echo "1) Каждые 5 минут (по умолчанию)" ;;
                "watchdog_opt_10") echo "2) Каждые 10 минут" ;;
                "watchdog_opt_15") echo "3) Каждые 15 минут" ;;
                "watchdog_opt_30") echo "4) Каждые 30 минут" ;;
                "watchdog_interval_set") echo "Интервал watchdog установлен:" ;;
                "watchdog_created") echo "Watchdog скрипт создан: /opt/warp-native/warp-watchdog.sh" ;;
                "watchdog_cron_set") echo "Cron задача создана: /etc/cron.d/warp-native" ;;
                "watchdog_dir_failed") echo "Не удалось создать директорию /opt/warp-native." ;;
                "installation_complete") echo "Установка и настройка Cloudflare WARP завершены!" ;;
                "summary_header") echo "═══════════════ ИТОГ ═══════════════" ;;
                "summary_account") echo "Тип аккаунта :" ;;
                "summary_tunnel_ip") echo "IP туннеля   :" ;;
                "summary_handshake") echo "Handshake    :" ;;
                "summary_seconds_ago") echo "сек. назад" ;;
                "summary_footer") echo "════════════════════════════════════" ;;
                "check_service") echo "Проверить статус службы:" ;;
                "show_info") echo "Посмотреть информацию (WG):" ;;
                "stop_interface") echo "Остановить интерфейс:" ;;
                "start_interface") echo "Запустить интерфейс:" ;;
                "restart_interface") echo "Перезапустить интерфейс:" ;;
                "disable_autostart") echo "Отключить автозапуск:" ;;
                "enable_autostart_cmd") echo "Включить автозапуск:" ;;
                "watchdog_log") echo "Лог watchdog:" ;;
                "watchdog_config") echo "Настройки watchdog:" ;;
                "dns_restored") echo "DNS возвращены к заводскому состоянию (восстановлены из резервной копии)" ;;
                "cf_response_plus") echo "Ответ от Cloudflare: warp=plus — WARP+ работает!" ;;
                "recreating_account") echo "Обнаружен старый аккаунт. Для активации WARP+ пересоздаём аккаунт..." ;;
                "old_account_removed") echo "Старый аккаунт удалён." ;;
                "setup_alias") echo "11. Создание команды warp..." ;;
                "exit_header") echo "══════════ ВЫХОД ЧЕРЕЗ WARP ═════════" ;;
                "exit_provider") echo "Провайдер" ;;
                "exit_avail") echo "доступен" ;;
                "exit_unavail") echo "недоступен" ;;
                "exit_unreachable") echo "Через туннель нет связи. Установка завершена — watchdog будет поднимать туннель, проверьте позже командой: warp check" ;;
                "alias_created") echo "Команда \e[1;32mwarp\e[0m создана: введите \e[1;32mwarp\e[0m для просмотра статуса." ;;
                "killswitch_failed") echo "Не удалось включить kill-switch (проверьте поддержку nftables в ядре)." ;;
                "killswitch_enabled") echo "Fail-closed kill-switch включён (метка 51888 → только через warp)." ;;
                "rollback_start") echo "Установка не завершена — откатываем изменения..." ;;
                "rollback_done") echo "Изменения откачены." ;;
                "rollback_skipped") echo "Обнаружена предыдущая установка — автоматический откат не выполняется. Для полного удаления запустите uninstall.sh." ;;
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
                "no_downloader") echo "Neither wget nor curl found. Please install one and try again." ;;
                "register_wgcf") echo "4. Registering and generating wgcf configuration..." ;;
                "account_exists") echo "wgcf-account.toml file already exists. Skipping registration." ;;
                "account_reuse_hint") echo "Reusing existing account. If there is no connectivity after install — delete /opt/warp-native/wgcf/wgcf-account.toml and reinstall for a clean registration." ;;
                "account_migrated") echo "wgcf account moved from home directory to /opt/warp-native/wgcf." ;;
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
                "warp_plus_prompt") echo "If you have a WARP+ key, you can apply it now." ;;
                "enter_license") echo "Enter WARP+ license key (Enter to skip): " ;;
                "applying_license") echo "Applying WARP+ license..." ;;
                "license_applied") echo "WARP+ license successfully applied!" ;;
                "license_failed") echo "Failed to apply license. Check your key." ;;
                "license_not_applied") echo "WARP+ key was entered but license was not applied. Using free version." ;;
                "continuing_free") echo "Continuing with free WARP version." ;;
                "skipping_license") echo "Skipping WARP+ license application." ;;
                "config_regenerated") echo "Configuration regenerated with WARP+." ;;
                "edit_config") echo "5. Editing WARP configuration..." ;;
                "config_not_found") echo "not found." ;;
                "dns_removed") echo "Failed to remove DNS line from configuration." ;;
                "table_off_failed") echo "Failed to add Table = off." ;;
                "keepalive_failed") echo "Failed to add PersistentKeepalive = 25." ;;
                "wireguard_dir_failed") echo "Failed to create /etc/wireguard directory." ;;
                "config_move_failed") echo "Failed to move configuration." ;;
                "config_saved") echo "Configuration saved to /etc/wireguard/warp.conf." ;;
                "check_ipv6") echo "6. IPv4-only setup: removing IPv6 from configuration and pinning IPv4 endpoint..." ;;
                "ipv6_removed") echo "IPv6 removed from configuration, endpoint pinned to IPv4." ;;
                "connect_warp") echo "7. Connecting WARP interface..." ;;
                "connect_failed") echo "Failed to connect interface." ;;
                "warp_connected") echo "WARP interface successfully connected." ;;
                "check_status") echo "8. Checking WARP connection status..." ;;
                "warp_not_found") echo "WARP interface not found — tunnel is not working." ;;
                "handshake_received") echo "Handshake received →" ;;
                "warp_active") echo "WARP is connected and actively exchanging traffic." ;;
                "waiting_handshake") echo "Waiting for connection" ;;
                "handshake_pending") echo "Tunnel is still coming up — connectivity will be checked below." ;;
                "cf_response") echo "Cloudflare response: warp=on" ;;
                "cf_not_confirmed") echo "Cloudflare did not confirm warp=on, but interface is working. This is normal." ;;
                "warp_plus_active") echo "WARP+ activated" ;;
                "warp_free_active") echo "Using free WARP version" ;;
                "enable_autostart") echo "9. Enabling WARP autostart on boot..." ;;
                "autostart_failed") echo "Failed to configure autostart." ;;
                "autostart_enabled") echo "Autostart enabled." ;;
                "setup_watchdog") echo "10. Setting up WARP Watchdog..." ;;
                "watchdog_interval_prompt") echo "Select watchdog check interval:" ;;
                "watchdog_opt_5") echo "1) Every 5 minutes (default)" ;;
                "watchdog_opt_10") echo "2) Every 10 minutes" ;;
                "watchdog_opt_15") echo "3) Every 15 minutes" ;;
                "watchdog_opt_30") echo "4) Every 30 minutes" ;;
                "watchdog_interval_set") echo "Watchdog interval set:" ;;
                "watchdog_created") echo "Watchdog script created: /opt/warp-native/warp-watchdog.sh" ;;
                "watchdog_cron_set") echo "Cron job created: /etc/cron.d/warp-native" ;;
                "watchdog_dir_failed") echo "Failed to create /opt/warp-native directory." ;;
                "installation_complete") echo "Cloudflare WARP installation and configuration completed!" ;;
                "summary_header") echo "════════════════ SUMMARY ═══════════════" ;;
                "summary_account") echo "Account type :" ;;
                "summary_tunnel_ip") echo "Tunnel IP    :" ;;
                "summary_handshake") echo "Handshake    :" ;;
                "summary_seconds_ago") echo "sec. ago" ;;
                "summary_footer") echo "════════════════════════════════════════" ;;
                "check_service") echo "Check service status:" ;;
                "show_info") echo "Show information (WG):" ;;
                "stop_interface") echo "Stop interface:" ;;
                "start_interface") echo "Start interface:" ;;
                "restart_interface") echo "Restart interface:" ;;
                "disable_autostart") echo "Disable autostart:" ;;
                "enable_autostart_cmd") echo "Enable autostart:" ;;
                "watchdog_log") echo "Watchdog log:" ;;
                "watchdog_config") echo "Watchdog config:" ;;
                "dns_restored") echo "DNS restored to factory state (restored from backup)" ;;
                "cf_response_plus") echo "Cloudflare response: warp=plus — WARP+ is working!" ;;
                "recreating_account") echo "Old account detected. Recreating account to activate WARP+..." ;;
                "old_account_removed") echo "Old account removed." ;;
                "setup_alias") echo "11. Creating warp command..." ;;
                "exit_header") echo "═══════════ WARP EXIT INFO ══════════" ;;
                "exit_provider") echo "Provider" ;;
                "exit_avail") echo "available" ;;
                "exit_unavail") echo "unavailable" ;;
                "exit_unreachable") echo "No connectivity through the tunnel. Installation finished — the watchdog will keep bringing it up, check later with: warp check" ;;
                "alias_created") echo "\e[1;32mwarp\e[0m command created: type \e[1;32mwarp\e[0m to view status." ;;
                "killswitch_failed") echo "Failed to enable kill-switch (check nftables support in the kernel)." ;;
                "killswitch_enabled") echo "Fail-closed kill-switch enabled (mark 51888 → warp only)." ;;
                "rollback_start") echo "Installation did not complete — rolling back changes..." ;;
                "rollback_done") echo "Changes rolled back." ;;
                "rollback_skipped") echo "A previous installation was detected — automatic rollback is skipped. Run uninstall.sh for a full removal." ;;
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

function try_register {
    output=$(timeout 60 bash -c 'yes | wgcf register' 2>&1)
    ret=$?
    echo "$output"
    return $ret
}

RESTORE_DNS_REQUIRED=false

function restore_dns {
    if [[ "$RESTORE_DNS_REQUIRED" == true && -f /etc/resolv.conf.backup ]]; then
        cp /etc/resolv.conf.backup /etc/resolv.conf
        ok "$(msg "dns_restored")"
        RESTORE_DNS_REQUIRED=false
    fi
}

WG_PREINSTALLED=false
NFT_PREINSTALLED=false
PREV_INSTALL=false
ROLLBACK_ARMED=false
INSTALL_COMPLETE=false

function pkg_installed {
    dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "ok installed"
}

function fetch_warp {
    local url="$1" out=""
    for attempt in 1 2 3; do
        out=$(curl -s --interface warp --max-time 8 "$url" 2>/dev/null)
        [ -n "$out" ] && { echo "$out"; return 0; }
        sleep 1
    done
    return 1
}

### Откат при ошибке: убираем всё, что создал установщик.
### wgcf-account.toml сохраняем, иначе повторная регистрация упрётся в rate limit Cloudflare.
function rollback_install {
    echo ""
    warn "$(msg "rollback_start")"

    systemctl disable --now wg-quick@warp &>/dev/null || true
    ip link delete warp &>/dev/null || true
    systemctl disable --now warp-native-killswitch.service &>/dev/null || true
    nft delete table inet warp_native &>/dev/null || true

    rm -f /etc/cron.d/warp-native
    rm -f /etc/systemd/system/warp-native-killswitch.service
    rm -f /etc/systemd/system/wg-quick@warp.service.d/warp-native-killswitch.conf
    rm -f /etc/systemd/system/nftables.service.d/warp-native-killswitch.conf
    rmdir /etc/systemd/system/wg-quick@warp.service.d /etc/systemd/system/nftables.service.d &>/dev/null || true
    systemctl daemon-reload &>/dev/null || true
    systemctl reset-failed wg-quick@warp warp-native-killswitch.service &>/dev/null || true

    rm -rf /opt/warp-native
    rm -f /usr/local/bin/warp /usr/local/bin/wgcf
    rm -f /etc/wireguard/warp.conf
    rmdir /etc/wireguard &>/dev/null || true
    rm -f "$WGCF_DIR/wgcf-profile.conf"

    ### Пакеты удаляем только если их поставил этот запуск
    if [[ "$WG_PREINSTALLED" == false ]]; then
        DEBIAN_FRONTEND=noninteractive apt remove --purge -y wireguard wireguard-tools &>/dev/null || true
    fi
    if [[ "$NFT_PREINSTALLED" == false ]]; then
        DEBIAN_FRONTEND=noninteractive apt remove --purge -y nftables &>/dev/null || true
    fi

    ok "$(msg "rollback_done")"
}

function on_exit {
    if [[ "$ROLLBACK_ARMED" == true && "$INSTALL_COMPLETE" != true ]]; then
        if [[ "$PREV_INSTALL" == true ]]; then
            warn "$(msg "rollback_skipped")"
        else
            rollback_install
        fi
    fi
    restore_dns
}

trap on_exit EXIT
trap 'exit 130' INT
trap 'exit 143' TERM HUP

if [[ $EUID -ne 0 ]]; then
    fail "This script must be run as root / Этот скрипт должен быть запущен от имени root"
    exit 1
fi

select_language

### Состояние до установки, для безопасного отката (снимаем ДО создания файлов)
if [[ -f /etc/wireguard/warp.conf || -d /opt/warp-native || -f /usr/local/bin/warp ]]; then
    PREV_INSTALL=true
fi
if pkg_installed wireguard || pkg_installed wireguard-tools; then
    WG_PREINSTALLED=true
fi
if pkg_installed nftables; then
    NFT_PREINSTALLED=true
fi
ROLLBACK_ARMED=true

mkdir -p "$WGCF_DIR"

### Миграция со старых версий: переносим аккаунт из $HOME, чтобы сохранить device и не триггерить новую регистрацию (rate limit)
if [[ -f "$HOME/wgcf-account.toml" && ! -f "$WGCF_DIR/wgcf-account.toml" ]]; then
    mv "$HOME/wgcf-account.toml" "$WGCF_DIR/wgcf-account.toml"
    [[ -f "$HOME/wgcf-profile.conf" ]] && mv "$HOME/wgcf-profile.conf" "$WGCF_DIR/wgcf-profile.conf"
    info "$(msg "account_migrated")"
fi

cd "$WGCF_DIR"

info "$(msg "start_install")"
echo ""

info "$(msg "install_wireguard")"
apt update -qq &>/dev/null || error_exit "$(msg "update_failed")"
apt install wireguard nftables -y &>/dev/null || error_exit "$(msg "wireguard_failed")"
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

if command -v wget &>/dev/null; then
    wget -q "$WGCF_DOWNLOAD_URL" -O "$WGCF_BINARY_NAME" || error_exit "$(msg "wgcf_download_failed")"
elif command -v curl &>/dev/null; then
    curl -sL "$WGCF_DOWNLOAD_URL" -o "$WGCF_BINARY_NAME" || error_exit "$(msg "wgcf_download_failed")"
else
    error_exit "$(msg "no_downloader")"
fi

chmod +x "$WGCF_BINARY_NAME" || error_exit "$(msg "wgcf_chmod_failed")"
mv "$WGCF_BINARY_NAME" /usr/local/bin/wgcf || error_exit "$(msg "wgcf_move_failed")"
ok "wgcf $WGCF_VERSION $(msg "wgcf_installed")"
echo ""

info "$(msg "register_wgcf")"

echo ""
info "$(msg "warp_plus_prompt")"
read -p "$(msg "enter_license")" WARP_LICENSE

if [[ -n "$WARP_LICENSE" && -f wgcf-account.toml ]]; then
    warn "$(msg "recreating_account")"
    rm -f wgcf-account.toml wgcf-profile.conf
    ok "$(msg "old_account_removed")"
fi

LICENSE_APPLIED=false

if [[ -f wgcf-account.toml ]]; then
    info "$(msg "account_exists")"
    warn "$(msg "account_reuse_hint")"
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
    
    output=$(try_register)
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
        try_register &>/dev/null || true
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

if [[ -n "$WARP_LICENSE" ]]; then
    info "$(msg "applying_license")"
    wgcf update --license-key "$WARP_LICENSE" &>/dev/null
    if [[ $? -eq 0 ]]; then
        LICENSE_APPLIED=true
        ok "$(msg "license_applied")"
        wgcf generate &>/dev/null || error_exit "$(msg "config_gen_failed")"
        ok "$(msg "config_regenerated")"
    else
        warn "$(msg "license_failed")"
        warn "$(msg "license_not_applied")"
        info "$(msg "continuing_free")"
    fi
else
    info "$(msg "skipping_license")"
fi
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
sed -i 's/,\s*[0-9a-fA-F:]\+\/128//' /etc/wireguard/warp.conf
sed -i '/Address = [0-9a-fA-F:]\+\/128/d' /etc/wireguard/warp.conf
sed -i "s|^Endpoint = .*|Endpoint = ${WARP_ENDPOINT_V4}|" /etc/wireguard/warp.conf
sed -i 's|^AllowedIPs = .*|AllowedIPs = 0.0.0.0/0|' /etc/wireguard/warp.conf
chmod 600 /etc/wireguard/warp.conf
ok "$(msg "ipv6_removed")"
echo ""

info "$(msg "connect_warp")"
### Чистый запуск: при переустановке юнит может висеть active (exited) без интерфейса
systemctl stop wg-quick@warp &>/dev/null || true
ip link delete warp &>/dev/null || true
systemctl reset-failed wg-quick@warp &>/dev/null || true
systemctl start wg-quick@warp &>/dev/null || error_exit "$(msg "connect_failed")"
ok "$(msg "warp_connected")"
echo ""

info "$(msg "check_status")"

if ! wg show warp &>/dev/null; then
    warn "$(msg "warp_not_found")"
else
    ### Ждём handshake 15с. Это НЕ вердикт - связь проверяется ниже
    handshake_ts=0
    HANDSHAKE_WAIT=15
    SPIN='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    for ((i=0; i<HANDSHAKE_WAIT; i++)); do
        handshake_ts=$(wg show warp latest-handshakes 2>/dev/null | awk '{print $2}')
        if [[ -n "$handshake_ts" && "$handshake_ts" -gt 0 ]]; then
            break
        fi
        c="${SPIN:i%10:1}"
        printf "\r\e[1;34m[..]\e[0m $(msg "waiting_handshake") \e[1;36m%s\e[0m  %ss " "$c" "$((HANDSHAKE_WAIT-i))"
        sleep 1
    done
    printf "\r\e[K"

    if [[ -n "$handshake_ts" && "$handshake_ts" -gt 0 ]]; then
        age=$(( $(date +%s) - handshake_ts ))
        ok "$(msg "handshake_received") ${age}s ago"
        ok "$(msg "warp_active")"
    else
        info "$(msg "handshake_pending")"
    fi
fi

wgcf_account_type=$(wgcf status 2>/dev/null | grep -i "Account type" | awk -F': ' '{print $2}' | xargs)
if [[ "$wgcf_account_type" == "unlimited" ]]; then
    ok "$(msg "warp_plus_active")"
elif [[ -n "$wgcf_account_type" ]]; then
    info "$(msg "warp_free_active")"
fi
echo ""

info "$(msg "enable_autostart")"
systemctl enable wg-quick@warp &>/dev/null || error_exit "$(msg "autostart_failed")"
ok "$(msg "autostart_enabled")"
echo ""

info "$(msg "setup_watchdog")"
echo ""
info "$(msg "watchdog_interval_prompt")"
echo -e "\e[1;32m$(msg "watchdog_opt_5")\e[0m"
echo -e "\e[1;32m$(msg "watchdog_opt_10")\e[0m"
echo -e "\e[1;32m$(msg "watchdog_opt_15")\e[0m"
echo -e "\e[1;32m$(msg "watchdog_opt_30")\e[0m"
echo ""

WATCHDOG_INTERVAL=5
WATCHDOG_CRON_INTERVAL="*/5 * * * *"

read -p "Choice / Выбор [1-4, Enter = 1]: " wdog_choice
case "$wdog_choice" in
    1) WATCHDOG_INTERVAL=5;  WATCHDOG_CRON_INTERVAL="*/5 * * * *" ;;
    2) WATCHDOG_INTERVAL=10; WATCHDOG_CRON_INTERVAL="*/10 * * * *" ;;
    3) WATCHDOG_INTERVAL=15; WATCHDOG_CRON_INTERVAL="*/15 * * * *" ;;
    4) WATCHDOG_INTERVAL=30; WATCHDOG_CRON_INTERVAL="*/30 * * * *" ;;
    *)  WATCHDOG_INTERVAL=5;  WATCHDOG_CRON_INTERVAL="*/5 * * * *" ;;
esac

ok "$(msg "watchdog_interval_set") ${WATCHDOG_INTERVAL} min"
echo ""

mkdir -p /opt/warp-native/logs || error_exit "$(msg "watchdog_dir_failed")"

cat > /opt/warp-native/config.env <<EOF
# warp-native watchdog configuration
# Edited values take effect on next cron run

# Cooldown between restarts in seconds (default: 120)
RESTART_COOLDOWN=120

# Max log lines before rotation (default: 1000)
LOG_MAX_LINES=1000
EOF

cat > /opt/warp-native/warp-killswitch.sh <<'KILLSWITCH_EOF'
#!/bin/bash
set -euo pipefail

TABLE="warp_native"
CHAIN="warp_native_killswitch"
MARK="51888"
IFACE="warp"

enable_killswitch() {
    if ! nft list table inet "$TABLE" &>/dev/null; then
        nft -f - <<EOF
add table inet $TABLE
add chain inet $TABLE $CHAIN { type filter hook output priority -150; policy accept; }
add rule inet $TABLE $CHAIN meta mark $MARK oifname != "$IFACE" counter drop comment "warp-native kill-switch"
EOF
    elif ! nft list chain inet "$TABLE" "$CHAIN" &>/dev/null; then
        nft -f - <<EOF
add chain inet $TABLE $CHAIN { type filter hook output priority -150; policy accept; }
add rule inet $TABLE $CHAIN meta mark $MARK oifname != "$IFACE" counter drop comment "warp-native kill-switch"
EOF
    else
        nft -f - <<EOF
flush chain inet $TABLE $CHAIN
add rule inet $TABLE $CHAIN meta mark $MARK oifname != "$IFACE" counter drop comment "warp-native kill-switch"
EOF
    fi
}

case "${1:-}" in
    start)
        enable_killswitch
        ;;
    stop)
        nft delete chain inet "$TABLE" "$CHAIN" 2>/dev/null || true
        ;;
    status)
        nft -a list chain inet "$TABLE" "$CHAIN"
        ;;
    *)
        echo "Usage: $0 {start|stop|status}"
        exit 1
        ;;
esac
KILLSWITCH_EOF

chmod +x /opt/warp-native/warp-killswitch.sh

cat > /etc/systemd/system/warp-native-killswitch.service <<'KILLSWITCH_SERVICE_EOF'
[Unit]
Description=WARP Native fail-closed kill-switch
After=nftables.service
Before=wg-quick@warp.service

[Service]
Type=oneshot
ExecStart=/opt/warp-native/warp-killswitch.sh start
ExecStop=/opt/warp-native/warp-killswitch.sh stop
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
KILLSWITCH_SERVICE_EOF

mkdir -p /etc/systemd/system/nftables.service.d
cat > /etc/systemd/system/nftables.service.d/warp-native-killswitch.conf <<'NFTABLES_DROPIN_EOF'
[Service]
ExecStartPost=/opt/warp-native/warp-killswitch.sh start
ExecReload=/opt/warp-native/warp-killswitch.sh start
NFTABLES_DROPIN_EOF

mkdir -p /etc/systemd/system/wg-quick@warp.service.d
cat > /etc/systemd/system/wg-quick@warp.service.d/warp-native-killswitch.conf <<'WARP_DEPENDENCY_EOF'
[Unit]
Requires=warp-native-killswitch.service
After=warp-native-killswitch.service

[Service]
ExecStartPre=/opt/warp-native/warp-killswitch.sh start
WARP_DEPENDENCY_EOF

systemctl daemon-reload

systemctl enable --now warp-native-killswitch.service &>/dev/null || \
    error_exit "$(msg "killswitch_failed")"

ok "$(msg "killswitch_enabled")"
echo ""

cat > /opt/warp-native/warp-watchdog.sh <<'WATCHDOG_EOF'
#!/bin/bash

CONFIG="/opt/warp-native/config.env"
LOG="/opt/warp-native/logs/watchdog.log"
COOLDOWN_FILE="/opt/warp-native/logs/.last_restart"

if [[ -f "$CONFIG" ]]; then
    source "$CONFIG"
fi

RESTART_COOLDOWN="${RESTART_COOLDOWN:-120}"
LOG_MAX_LINES="${LOG_MAX_LINES:-1000}"

log() {
    local level="$1"
    local message="$2"
    local ts
    ts=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$ts] [$level] $message" >> "$LOG"
}

rotate_log() {
    if [[ -f "$LOG" ]]; then
        local lines
        lines=$(wc -l < "$LOG")
        if [[ $lines -gt $LOG_MAX_LINES ]]; then
            tail -n "$LOG_MAX_LINES" "$LOG" > "${LOG}.tmp" && mv "${LOG}.tmp" "$LOG"
        fi
    fi
}

do_restart() {
    local reason="$1"

    if [[ -f "$COOLDOWN_FILE" ]]; then
        local last_restart
        last_restart=$(cat "$COOLDOWN_FILE")
        local now
        now=$(date +%s)
        local diff=$(( now - last_restart ))
        if [[ $diff -lt $RESTART_COOLDOWN ]]; then
            log "SKIP" "Restart skipped (cooldown: ${diff}s < ${RESTART_COOLDOWN}s). Reason was: $reason"
            return
        fi
    fi

    log "RESTART" "Restarting wg-quick@warp. Reason: $reason"

    ### Интерфейс поднят вручную мимо systemd — иначе restart упал бы с "File exists"
    if ! systemctl is-active --quiet wg-quick@warp && ip link show warp &>/dev/null; then
        wg-quick down warp &>/dev/null || ip link delete warp &>/dev/null
    fi

    systemctl restart wg-quick@warp
    local ret=$?
    date +%s > "$COOLDOWN_FILE"

    if [[ $ret -eq 0 ]]; then
        log "OK" "wg-quick@warp restarted successfully"
    else
        log "ERROR" "Failed to restart wg-quick@warp (exit code: $ret)"
    fi
}

rotate_log

if ! systemctl is-active --quiet wg-quick@warp; then
    do_restart "systemd unit is not active"
    exit 0
fi

### Возраст handshake только для лога, НЕ критерий рестарта:
### На живой ноде в простое он протухает, но туннель рабочий
handshake_ts=$(wg show warp latest-handshakes 2>/dev/null | awk '{print $2}')
if [[ -n "$handshake_ts" && "$handshake_ts" -gt 0 ]]; then
    hs_age=$(( $(date +%s) - handshake_ts ))
else
    hs_age="n/a"
fi

### Главный критерий - идёт ли трафик. ICMP заодно будит handshake, а если ICMP зарезан - пробуем TCP
if ping -I warp -c 2 -W 3 1.1.1.1 &>/dev/null; then
    log "OK" "WARP is healthy via ICMP (handshake: ${hs_age}s ago)"
    exit 0
fi

### ICMP не прошёл — фолбэк на TCP
if curl -s --interface warp --max-time 8 https://www.cloudflare.com/cdn-cgi/trace 2>/dev/null | grep -q '^warp='; then
    log "OK" "WARP is healthy via TCP (ICMP blocked; handshake: ${hs_age}s ago)"
    exit 0
fi

### Ни ICMP, ни TCP - туннель действительно мёртв
do_restart "no connectivity via warp (ICMP + TCP failed; handshake: ${hs_age}s ago)"
exit 0
WATCHDOG_EOF

chmod +x /opt/warp-native/warp-watchdog.sh
ok "$(msg "watchdog_created")"

cat > /etc/cron.d/warp-native <<EOF
# warp-native watchdog — checks WARP tunnel health
${WATCHDOG_CRON_INTERVAL} root /opt/warp-native/warp-watchdog.sh
EOF

chmod 644 /etc/cron.d/warp-native
ok "$(msg "watchdog_cron_set")"
echo ""

info "$(msg "setup_alias")"

cat > /usr/local/bin/warp <<'WARP_CMD_EOF'
#!/bin/bash

### Запрос через warp с ретраями: 3 попытки, таймаут 8с
function fetch_warp {
    local url="$1" out=""
    for attempt in 1 2 3; do
        out=$(curl -s --interface warp --max-time 8 "$url" 2>/dev/null)
        [ -n "$out" ] && { echo "$out"; return 0; }
        sleep 1
    done
    return 1
}

function check_exit {
    echo -e "\e[1;35m──────────────────────────────────────\e[0m"
    echo -e "\e[1;36mВыход через WARP:\e[0m"
    printf "  \e[2;37m%s\e[0m\r" "проверяю выход..."

    local ij ip1 co1 ci1 asn aj co2 isp cg
    ij=$(fetch_warp https://ifconfig.co/json)
    ip1=$(echo "$ij" | grep -oE '"ip":[ ]*"[^"]*"'      | cut -d'"' -f4)
    co1=$(echo "$ij" | grep -oE '"country":[ ]*"[^"]*"' | cut -d'"' -f4)
    ci1=$(echo "$ij" | grep -oE '"city":[ ]*"[^"]*"'    | cut -d'"' -f4)
    asn=$(echo "$ij" | grep -oE '"asn_org":[ ]*"[^"]*"' | cut -d'"' -f4)

    aj=$(fetch_warp http://ip-api.com/json)
    co2=$(echo "$aj" | grep -oE '"country":[ ]*"[^"]*"' | cut -d'"' -f4)
    isp=$(echo "$aj" | grep -oE '"isp":[ ]*"[^"]*"'     | cut -d'"' -f4)

    printf "  \e[1;36mIP          \e[0m %s\n"  "${ip1:-—}"
    printf "  \e[1;36mifconfig.co \e[0m %s%s\n" "${co1:-—}" "${ci1:+, $ci1}"
    printf "  \e[1;36mip-api      \e[0m %s\n"  "${co2:-—}"
    printf "  \e[1;36mПровайдер   \e[0m %s\n"  "${asn:-${isp:-—}}"

    cg=$(fetch_warp https://chatgpt.com/cdn-cgi/trace | grep '^loc=' | cut -d= -f2)
    printf "                      \r"
    local v
    if [ -n "$cg" ]; then
        if [[ "$cg" =~ ^(RU|CN|BY|IR|KP|CU|SY|VE)$ ]]; then
            v="\e[1;31mнедоступен\e[0m ($cg)"
        else
            v="\e[1;32mдоступен\e[0m ($cg)"
        fi
    else
        v="—"
    fi
    printf "  \e[1;36mChatGPT     \e[0m %b\n" "$v"
    echo -e "\e[1;35m──────────────────────────────────────\e[0m"
}

function show_status {
    echo ""
    echo -e "\e[1;35m╭─────────────────────────────────────╮"
    echo -e "│      \e[1;36m  W A R P - N A T I V E        \e[1;35m│"
    echo -e "│     \e[2;37m       by distillium            \e[1;35m│"
    echo -e "\e[1;35m╰─────────────────────────────────────╯\e[0m"
    echo ""

    if systemctl is-active --quiet wg-quick@warp; then
        status="\e[1;32mactive\e[0m"
    else
        status="\e[1;31minactive\e[0m"
    fi

    tunnel_ip=$(ip addr show warp 2>/dev/null | grep 'inet ' | awk '{print $2}' | head -1)
    [ -z "$tunnel_ip" ] && tunnel_ip="—"

    hs_ts=$(wg show warp latest-handshakes 2>/dev/null | awk '{print $2}')
    if [[ -n "$hs_ts" && "$hs_ts" -gt 0 ]]; then
        age=$(( $(date +%s) - hs_ts ))
        handshake="${age}s ago"
    else
        handshake="—"
    fi

    account_type=$(wgcf --config /opt/warp-native/wgcf/wgcf-account.toml status 2>/dev/null | grep -i "Account type" | awk -F': ' '{print $2}' | xargs)
    if [[ "$account_type" == "unlimited" ]]; then
        account="WARP+"
    elif [[ -n "$account_type" ]]; then
        account="Free"
    else
        account="—"
    fi

    echo -e "  \e[1;36mСтатус     :\e[0m $status"
    echo -e "  \e[1;36mIP туннеля :\e[0m $tunnel_ip"
    echo -e "  \e[1;36mHandshake  :\e[0m $handshake"
    echo -e "  \e[1;36mАккаунт    :\e[0m $account"
    echo ""

    if systemctl is-active --quiet wg-quick@warp; then
        check_exit
        echo ""
    fi

    echo -e "\e[1;35m──────────────────────────────────────\e[0m"
    echo -e "  \e[1;32mwarp start\e[0m    — запустить"
    echo -e "  \e[1;32mwarp stop\e[0m     — остановить"
    echo -e "  \e[1;32mwarp restart\e[0m  — перезапустить"
    echo -e "  \e[1;32mwarp check\e[0m    — проверить выход (IP, страна, ChatGPT)"
    echo -e "  \e[1;32mwarp log\e[0m      — лог watchdog"
    echo -e "\e[1;35m──────────────────────────────────────\e[0m"
    echo ""
}

case "$1" in
    start)   systemctl start wg-quick@warp ;;
    stop)    systemctl stop wg-quick@warp ;;
    restart) systemctl restart wg-quick@warp ;;
    check)   check_exit ;;
    log)
        if [[ ! -f /opt/warp-native/logs/watchdog.log ]]; then
            echo "Лог пока пуст — watchdog ещё не запускался."
        else
            tail -f /opt/warp-native/logs/watchdog.log
        fi
        ;;
    *)       show_status ;;
esac
WARP_CMD_EOF

chmod +x /usr/local/bin/warp
ok "$(msg "alias_created")"
echo ""

INSTALL_COMPLETE=true

tunnel_ip=$(ip addr show warp 2>/dev/null | grep 'inet ' | awk '{print $2}' | head -1)
[[ -z "$tunnel_ip" ]] && tunnel_ip="—"

final_handshake_ts=$(wg show warp latest-handshakes 2>/dev/null | awk '{print $2}')
if [[ -n "$final_handshake_ts" && "$final_handshake_ts" -gt 0 ]]; then
    final_age=$(( $(date +%s) - final_handshake_ts ))
    handshake_display="${final_age} $(msg "summary_seconds_ago")"
else
    handshake_display="—"
fi

if [[ "$wgcf_account_type" == "unlimited" ]]; then
    account_display="WARP+"
elif [[ -n "$wgcf_account_type" ]]; then
    account_display="Free"
else
    account_display="—"
fi

echo ""
ok "$(msg "installation_complete")"
echo ""
echo -e "\e[1;36m$(msg "summary_header")\e[0m"
echo -e "\e[1;36m  $(msg "summary_account") \e[0m${account_display}"
echo -e "\e[1;36m  $(msg "summary_tunnel_ip") \e[0m${tunnel_ip}"
echo -e "\e[1;36m  $(msg "summary_handshake") \e[0m${handshake_display}"
echo -e "\e[1;36m$(msg "summary_footer")\e[0m"
echo ""

if systemctl is-active --quiet wg-quick@warp && wg show warp &>/dev/null; then
    printf "\e[2;37m%s\e[0m\r" "проверяю выход..."
    ij=$(fetch_warp https://ifconfig.co/json)
    ip1=$(echo "$ij" | grep -oE '"ip":[ ]*"[^"]*"'      | cut -d'"' -f4)
    co1=$(echo "$ij" | grep -oE '"country":[ ]*"[^"]*"' | cut -d'"' -f4)
    ci1=$(echo "$ij" | grep -oE '"city":[ ]*"[^"]*"'    | cut -d'"' -f4)
    asn=$(echo "$ij" | grep -oE '"asn_org":[ ]*"[^"]*"' | cut -d'"' -f4)
    aj=$(fetch_warp http://ip-api.com/json)
    co2=$(echo "$aj" | grep -oE '"country":[ ]*"[^"]*"' | cut -d'"' -f4)
    isp=$(echo "$aj" | grep -oE '"isp":[ ]*"[^"]*"'     | cut -d'"' -f4)
    cg=$(fetch_warp https://chatgpt.com/cdn-cgi/trace | grep '^loc=' | cut -d= -f2)
    printf "                      \r"

    echo -e "\e[1;36m$(msg "exit_header")\e[0m"
    printf "  \e[1;36mIP          \e[0m %s\n"  "${ip1:-—}"
    printf "  \e[1;36mifconfig.co \e[0m %s%s\n" "${co1:-—}" "${ci1:+, $ci1}"
    printf "  \e[1;36mip-api      \e[0m %s\n"  "${co2:-—}"
    printf "  \e[1;36mПровайдер   \e[0m %s\n"  "${asn:-${isp:-—}}"
    if [ -n "$cg" ]; then
        if [[ "$cg" =~ ^(RU|CN|BY|IR|KP|CU|SY|VE)$ ]]; then
            printf "  \e[1;36mChatGPT     \e[0m \e[1;31m%s\e[0m (%s)\n" "$(msg "exit_unavail")" "$cg"
        else
            printf "  \e[1;36mChatGPT     \e[0m \e[1;32m%s\e[0m (%s)\n" "$(msg "exit_avail")" "$cg"
        fi
    else
        printf "  \e[1;36mChatGPT     \e[0m —\n"
    fi
    echo -e "\e[1;36m$(msg "summary_footer")\e[0m"
    echo ""

    ### Вердикт: ни один сервис не ответил - реальная проблема связи
    if [[ -z "$ip1" && -z "$co2" && -z "$cg" ]]; then
        warn "$(msg "exit_unreachable")"
    fi
fi

echo -e "\e[1;32m➤ warp\e[0m — статус туннеля и управление"
echo ""
echo -e "\e[1;36m➤ $(msg "disable_autostart"): \e[0msystemctl disable wg-quick@warp"
echo -e "\e[1;36m➤ $(msg "enable_autostart_cmd"): \e[0msystemctl enable wg-quick@warp"
echo -e "\e[1;36m➤ $(msg "watchdog_config"): \e[0mnano /opt/warp-native/config.env"
echo ""
