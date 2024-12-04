#!/bin/bash
clear

echo " 
▀▄▀ ▄▄ █░█ █   █▄▄ ▄▀█ █▀▀ █▄▀ █░█ █▀█
█░█ ░░ █▄█ █   █▄█ █▀█ █▄▄ █░█ █▄█ █▀▀"



echo -e "\n\e[92mplease wait ...\033[0m\n"
# نمایش هشدار
echo "────────────────────────────────────────────────────────────────"
echo "⚠️ WARNING: This script must ONLY be installed on non-Iranian servers!"
echo "Checking server location..."
echo "────────────────────────────────────────────────────────────────"

# دریافت آی‌پی عمومی
SERVER_IP=$(curl -s https://api.ipify.org)

# دریافت اطلاعات موقعیت جغرافیایی
SERVER_COUNTRY=$(curl -s https://ipinfo.io/$SERVER_IP/country)

# چک کردن کشور
if [[ "$SERVER_COUNTRY" == "IR" ]]; then
    echo "❌ Your server's IP ($SERVER_IP) is located in Iran."
    echo "⚠️ This script cannot be executed on servers in Iran. Exiting now."
    exit 1
else
    echo "✅ Your server's IP ($SERVER_IP) is NOT located in Iran."
    
fi

# ادامه اسکریپت...
# Displaying a banner
echo "────────────────────────────────────────────────────────────────"
echo "🚀 Starting the Setup Script"
echo "Please follow the instructions carefully to avoid errors."
echo "────────────────────────────────────────────────────────────────"

# ────────────────────────────────────────────────────────────────────────
# ℹ️ INSTRUCTIONS:
# 1. Ensure your server is running Ubuntu 18.04 or newer.
# 2. Run this script as a root user or with sudo permissions.
# 3. Make sure all dependencies are installed before proceeding.
# 4. Keep your server up-to-date for better security and performance.
# ────────────────────────────────────────────────────────────────────────

# ────────────────────────────────────────────────────────────────────────
# 💡 NOTE:
# If you encounter any issues during the installation process, 
# please contact your system administrator or refer to the official 
# documentation provided with this script.
# ────────────────────────────────────────────────────────────────────────

# Script begins here
echo "Checking system requirements..."
sleep 2

# Example of a system check
if [[ "$(lsb_release -is)" != "Ubuntu" ]]; then
    echo "❌ This script is only supported on Ubuntu systems. Exiting."
    exit 1
fi

echo "✅ System requirements passed!"
# Add your main script logic here...


# فایل‌های کانفیگ و اسکریپت‌ها
TRANSFER_SCRIPT="/usr/local/bin/pull_and_send.sh"
CONFIG_FILE="/etc/iranian_servers.conf"

# منوی اصلی
function main_menu() {
    echo "======================================"
    echo "Multi-Server File Transfer Management"
    echo "======================================"
    echo "1) Install the backup system"
    echo "2) Uninstall the backup system"
    echo "3) Show the list of configured servers"
    echo "4) Add new servers for backup"
    echo "5) Update backup schedule"
    echo "6) Backup Now"
    echo "7) Exit"
    echo "======================================"
    read -p "Enter your choice: " CHOICE

    case $CHOICE in
        1)
            install_system
            ;;
        2)
            uninstall_system
            ;;
        3)
            show_servers
            ;;
			
	4)
            add_servers
            ;;
	    
	5)
            update_cron
            ;;
	6)
            backup_now
            ;;		
        7)
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            main_menu
            ;;
    esac
}
# backup دستی
function backup_now() {
    echo "Starting immediate backup process..."

    if [[ ! -f $CONFIG_FILE ]]; then
        echo "Configuration file not found. No servers are configured."
        return
    fi

    # اطلاعات تاریخ و زمان
    CURRENT_DATE=$(date +"%Y-%m-%d")
    CURRENT_TIME=$(date +"%H:%M:%S")

    # خواندن لیست سرورها
    while read -r SERVER; do
        USER_HOST=$(echo "$SERVER" | cut -d':' -f1)
        FILE_PATH=$(echo "$SERVER" | cut -d':' -f2)
        SERVER_IP=$(echo "$USER_HOST" | cut -d'@' -f2)

        # نام فایل جدید
        NEW_FILENAME="/tmp/${SERVER_IP}_${CURRENT_DATE}_${CURRENT_TIME}_backup.db"

        # کپی فایل
        echo "Pulling backup from $USER_HOST:$FILE_PATH..."
        scp "$USER_HOST:$FILE_PATH" "$NEW_FILENAME"

        if [ $? -eq 0 ]; then
            echo "File pulled successfully: $NEW_FILENAME"

            # ارسال به تلگرام
            CAPTION="💻 Host: $(hostname)\n🌐 IPv4: $(curl -s https://api.ipify.org)\n⏰ Date&Time: $CURRENT_DATE $CURRENT_TIME"
            echo "Sending file to Telegram..."
            curl -F "chat_id=$CHAT_ID" \
                 -F "document=@$NEW_FILENAME" \
                 -F "caption=$CAPTION" \
                 "https://api.telegram.org/bot$BOT_TOKEN/sendDocument"

            # بررسی موفقیت ارسال
            if [ $? -eq 0 ]; then
                echo "File sent to Telegram successfully."
                rm -f "$NEW_FILENAME"
            else
                echo "Failed to send file to Telegram. File retained: $NEW_FILENAME"
            fi
        else
            echo "Failed to pull file from $USER_HOST:$FILE_PATH"
        fi
    done < "$CONFIG_FILE"

    echo "Backup process completed."
    sleep 2
}


# تابع تغییر زمان‌بندی
function update_cron() {
    echo "Updating the backup schedule..."
    
    # حذف کرون‌جاب قبلی
    echo "Removing existing cron job..."
    crontab -l | grep -v "$TRANSFER_SCRIPT" | crontab -

    # دریافت زمان‌بندی جدید
    echo "Set a new schedule for the backup script:"
    echo "1) Every X minutes"
    echo "2) Every X hours"
    echo "3) Every X days"
    read -p "Select an option (1, 2, or 3): " TIME_OPTION

    if [[ "$TIME_OPTION" == "1" ]]; then
        read -p "Enter the interval in minutes (e.g., 30 for every 30 minutes): " MINUTES
        CRON_JOB="*/$MINUTES * * * * $TRANSFER_SCRIPT"
    elif [[ "$TIME_OPTION" == "2" ]]; then
        read -p "Enter the interval in hours (e.g., 2 for every 2 hours): " HOURS
        CRON_JOB="0 */$HOURS * * * $TRANSFER_SCRIPT"
    elif [[ "$TIME_OPTION" == "3" ]]; then
        read -p "Enter the interval in days (e.g., 1 for every day): " DAYS
        CRON_JOB="0 0 */$DAYS * * $TRANSFER_SCRIPT"
    else
        echo "Invalid option. Skipping schedule update."
        return
    fi

    # افزودن زمان‌بندی جدید به کرون
    (crontab -l; echo "$CRON_JOB") | crontab -
    echo "New schedule applied successfully."
    sleep 2
}
# تابع اضافه کردن سرورهای جدید
function add_servers() {
    echo "Adding new servers to the configuration..."
    if [[ ! -f $CONFIG_FILE ]]; then
        echo "Configuration file not found. Creating a new one..."
        touch $CONFIG_FILE
    fi

    # تولید کلید SSH در صورت نبود
    if [[ ! -f ~/.ssh/id_rsa ]]; then
        echo "Creating SSH key for password-less access..."
        ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
    fi

    while true; do
        read -p "Enter the IP of a new server (or press Enter to finish): " SERVER_IP
        if [[ -z "$SERVER_IP" ]]; then
            break
        fi
        read -p "Enter the username for $SERVER_IP: " SERVER_USER
        read -p "Enter the file path to transfer from $SERVER_IP: " FILE_PATH

        NEW_SERVER="$SERVER_USER@$SERVER_IP:$FILE_PATH"

        # اضافه کردن سرور به فایل تنظیمات (اگر وجود ندارد)
        if ! grep -q "$NEW_SERVER" $CONFIG_FILE; then
            echo $NEW_SERVER >> $CONFIG_FILE
            echo "Added $NEW_SERVER to the configuration."
        else
            echo "Server $SERVER_IP is already in the configuration."
        fi

        # همیشه کلید SSH را به سرور اضافه کن
        echo "Setting up SSH access for $SERVER_IP..."
        ssh-copy-id -i ~/.ssh/id_rsa.pub "$SERVER_USER@$SERVER_IP"
        if [ $? -eq 0 ]; then
            echo "SSH access configured successfully for $SERVER_IP."
        else
            echo "Failed to configure SSH access for $SERVER_IP."
        fi
    done

    echo "Updated server configuration:"
    cat $CONFIG_FILE
    sleep 2
}

# نصب سیستم
function install_system() {
    echo "Starting the installation process..."

    # دریافت اطلاعات تلگرام
    read -p "Enter your Telegram Bot Token: " BOT_TOKEN
    read -p "Enter your Telegram Chat ID: " CHAT_ID

    # دریافت اطلاعات سرورهای ایرانی
     echo "==========================================="
echo " 
█ █▀█ ▄▀█ █▄░█ █ ▄▀█ █▄░█   █▀ █▀▀ █▀█ █░█ █▀▀ █▀█ █▀
█ █▀▄ █▀█ █░▀█ █ █▀█ █░▀█   ▄█ ██▄ █▀▄ ▀▄▀ ██▄ █▀▄ ▄█

█ █▄░█ █▀▀ █▀█ █▀█ █▀▄▀█ ▄▀█ ▀█▀ █ █▀█ █▄░█
█ █░▀█ █▀░ █▄█ █▀▄ █░▀░█ █▀█ ░█░ █ █▄█ █░▀█
"
echo "==============================================="
    echo "Enter the details of your Iranian servers."
    echo "You will be asked for each server's details one by one."
    IRANIAN_SERVERS=()
    while true; do
        read -p "Enter the IP of an Iranian server (or press Enter to finish): " SERVER_IP
        if [[ -z "$SERVER_IP" ]]; then
            break
        fi
        read -p "Enter the username for $SERVER_IP: " SERVER_USER
        read -p "Enter the file path to transfer from $SERVER_IP: " FILE_PATH
        IRANIAN_SERVERS+=("$SERVER_USER@$SERVER_IP:$FILE_PATH")
    done

    if [[ ${#IRANIAN_SERVERS[@]} -eq 0 ]]; then
        echo "No Iranian servers provided. Exiting."
        exit 1
    fi

    # ذخیره سرورها در فایل کانفیگ
    echo "Saving server configuration..."
    echo "" > $CONFIG_FILE
    for SERVER in "${IRANIAN_SERVERS[@]}"; do
        echo $SERVER >> $CONFIG_FILE
    done
    echo "Server configuration saved to $CONFIG_FILE"

    # ایجاد کلید SSH
    if [ ! -f ~/.ssh/id_rsa ]; then
        echo "Creating SSH key for password-less access..."
        ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
    fi

    # تنظیم کلید SSH برای هر سرور
    echo "Setting up SSH keys for Iranian servers..."
    for SERVER in "${IRANIAN_SERVERS[@]}"; do
        SERVER_IP=$(echo $SERVER | cut -d'@' -f2 | cut -d':' -f1)
        echo "Configuring SSH for $SERVER_IP..."
        ssh-copy-id -i ~/.ssh/id_rsa.pub $SERVER_IP
        if [ $? -ne 0 ]; then
            echo "Error setting up SSH for $SERVER_IP. Skipping..."
        fi
    done

    # ایجاد اسکریپت انتقال فایل
    echo "Creating the file transfer script..."
    cat <<EOL > $TRANSFER_SCRIPT
#!/bin/bash

# اطلاعات تلگرام
BOT_TOKEN="$BOT_TOKEN"
CHAT_ID="$CHAT_ID"

# سرورهای ایرانی
IRANIAN_SERVERS=\$(cat $CONFIG_FILE)

# دریافت اطلاعات تاریخ و ساعت
CURRENT_DATE=\$(date +"%Y-%m-%d")
CURRENT_TIME=\$(date +"%H-%M-%S")

# پردازش هر سرور ایرانی
for SERVER in \$IRANIAN_SERVERS; do
    USER_HOST=\$(echo \$SERVER | cut -d':' -f1)
    FILE_PATH=\$(echo \$SERVER | cut -d':' -f2)
    SERVER_IP=\$(echo \$USER_HOST | cut -d'@' -f2)

    # نام فایل با فرمت جدید
    NEW_FILENAME="\${SERVER_IP}_\${CURRENT_DATE}_\${CURRENT_TIME}_x-ui.db"

    # کپی فایل از سرور ایرانی به سرور خارجی
    echo "Pulling file from \$USER_HOST:\$FILE_PATH..."
    scp \$USER_HOST:\$FILE_PATH /tmp/\$NEW_FILENAME

    if [ \$? -eq 0 ]; then
        echo "File pulled successfully: \$NEW_FILENAME"

# اطلاعات تاریخ، ساعت، هاست و آی‌پی
CURRENT_DATE=$(date +"%Y-%m-%d")
CURRENT_TIME=$(date +"%H:%M:%S")
HOSTNAME=$(hostname)
SERVER_IP=$(curl -s https://api.ipify.org)

# کپشن جدید برای فایل
CAPTION="💻 Host: $HOSTNAME\n🌐 IPv4: $SERVER_IP\n⏰ Date&Time: $CURRENT_DATE $CURRENT_TIME"

# ارسال فایل به تلگرام
curl -F "chat_id=$CHAT_ID" \
     -F "document=@/tmp/$NEW_FILENAME" \
     -F "caption=$CAPTION" \
     "https://api.telegram.org/bot$BOT_TOKEN/sendDocument"

# بررسی موفقیت ارسال به تلگرام
if [ $? -eq 0 ]; then
    echo "File sent to Telegram successfully."
    rm -f /tmp/$NEW_FILENAME
else
    echo "Failed to send file to Telegram. File retained: /tmp/$NEW_FILENAME"
fi

done
EOL

    chmod +x $TRANSFER_SCRIPT
    echo "File transfer script created at $TRANSFER_SCRIPT"

    # پیشنهاد اضافه کردن به Cron
    echo "How often do you want to run the script?"
    echo "1) Every X minutes"
    echo "2) Every X hours"
    echo "3) Every X days"
    read -p "Select an option (1, 2, or 3): " TIME_OPTION

    if [[ "$TIME_OPTION" == "1" ]]; then
        read -p "Enter the interval in minutes (e.g., 30 for every 30 minutes): " MINUTES
        CRON_JOB="*/$MINUTES * * * * $TRANSFER_SCRIPT"
    elif [[ "$TIME_OPTION" == "2" ]]; then
        read -p "Enter the interval in hours (e.g., 2 for every 2 hours): " HOURS
        CRON_JOB="0 */$HOURS * * * $TRANSFER_SCRIPT"
    elif [[ "$TIME_OPTION" == "3" ]]; then
        read -p "Enter the interval in days (e.g., 1 for every day): " DAYS
        CRON_JOB="0 0 */$DAYS * * $TRANSFER_SCRIPT"
    else
        echo "Invalid option. Skipping Cron setup."
    fi

    (crontab -l; echo "$CRON_JOB") | crontab -
    echo "Scheduled file transfer script successfully."
}

# حذف سیستم
function uninstall_system() {
    echo "Uninstalling the backup system..."

    # حذف فایل اسکریپت انتقال
    if [[ -f /usr/local/bin/pull_and_send.sh ]]; then
        rm -f /usr/local/bin/pull_and_send.sh
        echo "Removed transfer script: /usr/local/bin/pull_and_send.sh"
    else
        echo "Transfer script not found."
    fi

    # حذف فایل تنظیمات
    if [[ -f /etc/iranian_servers.conf ]]; then
        rm -f /etc/iranian_servers.conf
        echo "Removed server configuration file: /etc/iranian_servers.conf"
    else
        echo "Server configuration file not found."
    fi

    # حذف کرون‌جاب مرتبط
    echo "Removing script from cron jobs..."
    crontab -l | grep -v "/usr/local/bin/pull_and_send.sh" | crontab -
    echo "Cron job removed."

    echo "Backup system uninstalled successfully."
}

# نمایش سرورها
function show_servers() {
    echo "Configured Iranian servers:"
    if [ -f $CONFIG_FILE ]; then
        cat $CONFIG_FILE
    else
        echo "No servers configured."
    fi
}

# اجرای منو
main_menu
