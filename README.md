# X-UI Backup System

The **X-UI Backup System** automates:
- Pulling backups from multiple Iranian servers.
- Sending backups directly to a Telegram bot for easy access.
- Managing backups with customizable cron jobs for periodic execution.

This script is designed for non-Iranian servers and offers a simple installation process for seamless management.

---

## ⚡ Quick Install

Run the following command to install the backup system on your server:

```bash
bash <(curl -s https://raw.githubusercontent.com/darklies/x-uis-backup/main/install.sh)
```
## 📋 Features

- **Backup Management:** Automatically pull backups from multiple servers.
- **Telegram Integration:** Send backups directly to a Telegram bot.
- **Customizable Scheduling:** Schedule periodic backups using cron jobs.
- **Simple Configuration:** Easily manage server configurations.
- **Complete Uninstallation:** Cleanly remove the script and all related files.

---

## 🛠️ Usage

Once installed, the script provides a menu with the following options:

1. **Install the Backup System:** Set up the backup system and configure servers.
2. **Uninstall the Backup System:** Remove the script, configurations, and cron jobs.
3. **Show Configured Servers:** Display the list of Iranian servers currently configured.
4. **Exit:** Quit the script.

---

## 📦 How It Works

1. **Server Configuration:**
   - Add the details of your Iranian servers (IP, username, file path).
   - Configure SSH keys for passwordless access.

2. **Backup Process:**
   - The script uses `scp` to pull backups from the configured servers.
   - Each backup is sent to the specified Telegram bot.

3. **Cron Scheduling:**
   - Set up periodic execution of the backup script (e.g., every X minutes, hours, or days).

---

## 🚀 Requirements

- **Operating System:** Ubuntu 18.04 or newer.
- **Permissions:** Root or sudo access.
- **Telegram Bot:** Create a bot and obtain its token and chat ID.
- **Non-Iranian Server:** Ensure the server where this script is installed is not located in Iran.

---

## 🔧 Configuration

During installation, you'll be asked to provide:
- **Telegram Bot Token:** The token of your Telegram bot.
- **Telegram Chat ID:** The ID of the Telegram chat to send backups to.
- **Iranian Servers:** A list of servers to pull backups from (IP, username, and file path).

The configuration is saved in `/etc/iranian_servers.conf`.

---

## 🗑️ Uninstallation

To completely remove the backup system:
1. Run the script and select the **Uninstall the Backup System** option.
2. This will:
   - Remove the transfer script.
   - Delete all configurations.
   - Remove the associated cron job.

---

## ⚠️ Important Notes

1. **Geolocation Check:**
   - The script checks the server's geolocation and exits if it's located in Iran.

2. **System Compatibility:**
   - This script is tested and supported on Ubuntu systems.

---

## 📝 License

This project is licensed under the MIT License.
