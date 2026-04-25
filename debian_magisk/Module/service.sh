#!/system/bin/sh
# Magisk Service Script - ADB Security Neutralizer & Maintainer

# Modül dizini tanımı
MODDIR=${0%/*}

# Ayarlar
ADB_PORT="5555"
CHECK_INTERVAL=5 # 5 saniyede bir kontrol et

# --- GÜVENLİK KATLİAMI VE BAŞLATMA FONKSİYONU ---
neutralize_and_start_adb() {
    # 1. Framework Seviyesinde Tüm Kapıları Aç
    settings put global adb_enabled 1
    settings put global adb_wifi_enabled 1
    settings put secure adb_wifi_enabled 1
    settings put global development_settings_enabled 1
    settings put global adb_notify 0
    settings put secure adb_paired_devices ""
    settings put secure adb_allowed_connection_time -1

    # 2. RSA ve Güvenlik Protokollerini Devre Dışı Bırak (System Props)
    resetprop ro.adb.secure 0
    resetprop ro.debuggable 1
    resetprop ro.secure 0
    resetprop persist.sys.usb.config adb,mtp
    resetprop persist.adb.tcp.port "$ADB_PORT"
    setprop service.adb.tcp.port "$ADB_PORT"

    # 3. Kimlik Doğrulama Dosyasını Temizle (RSA Onayını Bypass Etmek İçin)
    if [ -f /data/misc/adb/adb_keys ]; then
        rm -f /data/misc/adb/adb_keys
    fi

    # 4. Servisleri Yeniden Başlat (Zorla)
    setprop ctl.stop adbd
    stop adbd
    sleep 2
    setprop ctl.start adbd
    start adbd
}

# --- ANA DÖNGÜ (SÜREKLİ TAKİP) ---
(
    # Sistem tamamen açılana kadar bekle
    until [ "$(getprop sys.boot_completed)" -eq 1 ]; do
        sleep 5
    done

    while true; do
        # ADB'nin çalışıp çalışmadığını veya portun değişip değişmediğini kontrol et
        CURRENT_SVC_STATUS=$(getprop init.svc.adbd)
        CURRENT_TCP_PORT=$(getprop service.adb.tcp.port)

        # Eğer servis durmuşsa veya port 5555 değilse tekrar saldır
        if [ "$CURRENT_SVC_STATUS" != "running" ] || [ "$CURRENT_TCP_PORT" != "$ADB_PORT" ]; then
            neutralize_and_start_adb
        fi

        # Modül klasöründe 'disable' dosyası varsa döngüyü durdurma kontrolü (Opsiyonel)
        if [ -e "${MODDIR}/disable" ]; then
            stop adbd
            exit 0
        fi

        sleep $CHECK_INTERVAL
    done
) &
