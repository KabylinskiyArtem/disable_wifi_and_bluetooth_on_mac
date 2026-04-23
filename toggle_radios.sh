cat << 'EOF' > toggle_radios.sh
#!/bin/bash

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "Please run this script with sudo (e.g., sudo ./toggle_radios.sh)"
   exit 1
fi

echo "--- macOS Stealth Mode Toggle ---"
echo "1) Stealth Mode (Disable Wi-Fi, BT, Location)"
echo "2) Normal Mode (Enable Wi-Fi, BT, Location)"
read -p "Select an option [1-2]: " choice

case $choice in
    1)
        echo "Entering Stealth Mode..."
        launchctl unload -w /System/Library/LaunchDaemons/com.apple.airportd.plist 2>/dev/null
        launchctl unload -w /System/Library/LaunchDaemons/com.apple.bluetoothd.plist 2>/dev/null
        launchctl unload -w /System/Library/LaunchAgents/com.apple.locationd.plist 2>/dev/null
        echo "SUCCESS: Wireless modules and Location services disabled."
        ;;
    2)
        echo "Restoring Normal Mode..."
        launchctl load -w /System/Library/LaunchDaemons/com.apple.airportd.plist 2>/dev/null
        launchctl load -w /System/Library/LaunchDaemons/com.apple.bluetoothd.plist 2>/dev/null
        launchctl load -w /System/Library/LaunchAgents/com.apple.locationd.plist 2>/dev/null
        echo "SUCCESS: Wireless modules and Location services restored."
        ;;
    *)
        echo "Invalid choice. Exiting."
        ;;
esac
EOF
