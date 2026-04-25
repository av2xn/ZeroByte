#!/system/bin/sh
# ZeroByte Core Auto-Sleep Service

ADB_PORT="5555"

(
    until [ "$(getprop sys.boot_completed)" -eq 1 ]; do sleep 2; done

    settings put global adb_enabled 1
    settings put global adb_wifi_enabled 1
    settings put secure adb_wifi_enabled 1
    resetprop ro.adb.secure 0
    resetprop ro.debuggable 1
    resetprop persist.sys.usb.config adb,mtp
    resetprop persist.adb.tcp.port "$ADB_PORT"
    setprop service.adb.tcp.port "$ADB_PORT"
    rm -f /data/misc/adb/adb_keys
    setprop ctl.restart adbd

    until ip addr show wlan0 | grep -q "inet "; do sleep 2; done

    /system/bin/zb-sleep
) &
