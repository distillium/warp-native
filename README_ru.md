<p aling="center"><a href="https://github.com/distillium/warp-native">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="./media/logo.png" />
   <source media="(prefers-color-scheme: light)" srcset="./media/logo-black.png" />
   <img alt="Warp Native" src="./media/logo.png" />
 </picture>
</a></p>

**🇺🇸 [English version](./README.md)**

Этот скрипт устанавливает Cloudflare WARP в "нативном" режиме через `WireGuard`, как интерфейс, без использования `warp-cli`.

⚠️ Поддерживаются только системы на базе **Debian/Ubuntu**.

Он автоматизирует:
- Установку необходимых пакетов
- Скачивание и настройку `wgcf`
- Проверку наличия ipv6 в системе
- Генерацию и модификацию WireGuard-конфигурации
- Подключение и проверку статуса
- Включение автозапуска интерфейса `warp`

---

## 🚀 Способы установки

### Вариант 1: Shell-скрипт (быстрая установка)

Установка на каждую нужную ноду:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/distillium/warp-native/main/install.sh)
```

### Вариант 2: Ansible роль (рекомендуется для автоматизации)

Для управления несколькими серверами используйте Ansible роль:

**Установка из Ansible Galaxy:**
```bash
ansible-galaxy install themelbine.warp_native
```

**GitHub репозиторий:** [ansible-role-warp-native](https://github.com/TheMelbine/ansible-role-warp-native)

**Пример playbook:**
```yaml
- hosts: warp_servers
  become: yes
  roles:
    - themelbine.warp_native
  vars:
    warp_native_state: present
    warp_native_modify_resolv: true
```

## Шаблоны для конфигурации Xray

<details>
  <summary>📝 Показать пример outbound</summary>

```json
{
  "tag": "warp-out",
  "protocol": "freedom",
  "settings": {
    "domainStrategy": "ForceIPv4"
  },
  "streamSettings": {
    "sockopt": {
      "interface": "warp",
      "tcpFastOpen": true
    }
  }
}
```
</details>

<details>
  <summary>📝 Показать пример routing rule</summary>

```json
{
  "type": "field",
  "domain": [
    "netflix.com",
    "youtube.com",
    "twitter.com"
  ],
  "inboundTag": [
    "Node-1",
    "Node-2"
  ],
  "outboundTag": "warp-out"
}

```
</details>

## Управление интерфейсом WARP

| Операция                    | Команда                             |
|-----------------------------|-------------------------------------|
| Проверить статус службы     | `systemctl status wg-quick@warp`    |
| Посмотреть информацию (wg)  | `wg show warp`                      |
| Остановить интерфейс        | `systemctl stop wg-quick@warp`      |
| Запустить интерфейс         | `systemctl start wg-quick@warp`     |
| Перезапустить интерфейс     | `systemctl restart wg-quick@warp`   |
| Отключить автозапуск        | `systemctl disable wg-quick@warp`   |
| Включить автозапуск         | `systemctl enable wg-quick@warp`    |

## Удаление

### Метод через shell-скрипт:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/distillium/warp-native/main/uninstall.sh)
```

### Метод через Ansible:
```yaml
- hosts: warp_servers
  become: yes
  roles:
    - themelbine.warp_native
  vars:
    warp_native_state: absent
```

## Лицензия

MIT License - подробности см. в файле [LICENSE](LICENSE).

## Автор

Создано [distillium](https://github.com/distillium)

## Поддержка языков

Скрипт установки поддерживает интерактивный выбор языка. Во время установки вам будет предложено выбрать между английским и русским языками.

