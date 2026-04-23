#!/bin/bash

# Ensure the script is run with sudo
if [[ $EUID -ne 0 ]]; then
   echo "Error: Please run with sudo (e.g., sudo ./stealth.sh)"
   exit 1
fi

# Identify the Wi-Fi device (usually en0)
WIFI_DEV=$(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}')

show_menu() {
    echo "=========================================="
    echo "   macOS HARDWARE STEALTH CONTROLLER      "
    echo "=========================================="
    echo "1) [STEALTH] Kill Wireless & Location"
    echo "2) [NORMAL]  Restore All Services"
    echo "3) [STATUS]  Check Module States"
    echo "q) Exit"
    echo "------------------------------------------"
    read -p "Selection: " choice
}

enter_stealth() {
    echo "Disabling Wi-Fi Hardware Service..."
    networksetup -setnetworkserviceenabled Wi-Fi off
    ifconfig $WIFI_DEV down

    echo "Unloading Launch Daemons (Persistence)..."
    launchctl unload -w /System/Library/LaunchDaemons/com.apple.airportd.plist 2>/dev/null
    launchctl unload -w /System/Library/LaunchDaemons/com.apple.bluetoothd.plist 2>/dev/null
    launchctl unload -w /System/Library/LaunchAgents/com.apple.locationd.plist 2>/dev/null
    
    echo "DONE: Devices are now in stealth mode. LAN only."
}

restore_normal() {
    echo "Re-enabling Wi-Fi Hardware Service..."
    networksetup -setnetworkserviceenabled Wi-Fi on
    ifconfig $WIFI_DEV up

    echo "Reloading Launch Daemons..."
    launchctl load -w /System/Library/LaunchDaemons/com.apple.airportd.plist 2>/dev/null
    launchctl load -w /System/Library/LaunchDaemons/com.apple.bluetoothd.plist 2>/dev/null
    launchctl load -w /System/Library/LaunchAgents/com.apple.locationd.plist 2>/dev/null
    
    echo "DONE: Standard functionality restored."
}

check_status() {
    echo "--- Current Status ---"
    echo -n "Wi-Fi Power: "
    networksetup -getairportpower $WIFI_DEV
    echo -n "Wi-Fi Service: "
    networksetup -getnetworkserviceenabled Wi-Fi
}

while true; do
    show_menu
    case $choice in
        1) enter_stealth ;;
        2) restore_normal ;;
        3) check_status ;;
        q) exit 0 ;;
        *) echo "Invalid option." ;;
    esac
    echo ""
done
