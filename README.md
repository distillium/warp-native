<p aling="center"><a href="https://github.com/distillium/warp-native">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="./media/logo.png" />
   <source media="(prefers-color-scheme: light)" srcset="./media/logo-black.png" />
   <img alt="Warp Native" src="./media/logo.png" />
 </picture>
</a></p>

**🇷🇺 [Русская версия](./README_ru.md)**

This script installs Cloudflare WARP in "native" mode via `WireGuard` as an interface, without using `warp-cli`.

⚠️ Only **Debian/Ubuntu** based systems are supported.

It automates:
- Installation of required packages
- Download and configuration of `wgcf`
- IPv6 availability check in the system
- Generation and modification of WireGuard configuration
- Connection and status verification
- Enable auto-start of `warp` interface

---

## 🚀 Installation Methods

### Option 1: Shell Script (Quick Install)

Install on each required node:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/distillium/warp-native/main/install.sh)
```

### Option 2: Ansible Role (Recommended for automation)

For managing multiple servers, use the Ansible role:

**Install from Ansible Galaxy:**
```bash
ansible-galaxy install themelbine.warp_native
```

**GitHub Repository:** [ansible-role-warp-native](https://github.com/TheMelbine/ansible-role-warp-native)

**Example playbook:**
```yaml
- hosts: warp_servers
  become: yes
  roles:
    - themelbine.warp_native
  vars:
    warp_native_state: present
    warp_native_modify_resolv: true
```

## Xray Configuration Templates

<details>
  <summary>📝 Show outbound example</summary>

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
      "mark": 51888,
      "tcpFastOpen": true
    }
  }
}
```
</details>

<details>
  <summary>📝 Show routing rule example</summary>

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

## WARP Kill-switch

The installer enables `warp-native-killswitch.service`. It drops locally generated packets marked `51888` when their selected output interface is not `warp`. This prevents marked WARP traffic from falling back to the server's ordinary network connection when the `warp` interface is unavailable.

The protection applies only to outbounds that set the same mark in Xray:

```json
"sockopt": {
  "interface": "warp",
  "mark": 51888
}
```

Removing `mark` disables the kill-switch for that outbound.
The kill-switch manages only its own nftables chain and restores it after a system nftables reload. After a manual `nft flush ruleset`, restore it:

```bash
systemctl reload nftables
```

Check its state and the active rule:

```bash
systemctl status warp-native-killswitch.service
nft list chain inet warp_native warp_native_killswitch
```

## WARP Interface Management

| Operation                    | Command                             |
|------------------------------|-------------------------------------|
| Check service status         | `systemctl status wg-quick@warp`    |
| Show information (wg)        | `wg show warp`                      |
| Stop interface               | `systemctl stop wg-quick@warp`      |
| Start interface              | `systemctl start wg-quick@warp`     |
| Restart interface            | `systemctl restart wg-quick@warp`   |
| Disable auto-start           | `systemctl disable wg-quick@warp`   |
| Enable auto-start            | `systemctl enable wg-quick@warp`    |

## Uninstall

### Shell Script Method:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/distillium/warp-native/main/uninstall.sh)
```

### Ansible Method:
```yaml
- hosts: warp_servers
  become: yes
  roles:
    - themelbine.warp_native
  vars:
    warp_native_state: absent
```

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Author

Created by [distillium](https://github.com/distillium)

## Language Support

The installation script supports interactive language selection. During installation, you'll be prompted to choose between English and Russian.
