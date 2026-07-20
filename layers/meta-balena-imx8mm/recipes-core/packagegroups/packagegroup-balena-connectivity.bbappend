# ATH10K for QCA9880 (used by customer),
# iwlwifi for internal BT
CONNECTIVITY_FIRMWARES:append = " \
    linux-firmware-iwlwifi-cc-a0 \
    linux-firmware-ibt-20 \
"

# Fixes: nothing provides linux-firmware-bcm43143 needed by packagegroup-balena-connectivity-1.0-r0.all
CONNECTIVITY_FIRMWARES:remove = " \
    linux-firmware-ath9k \
    linux-firmware-bcm43143 \
    linux-firmware-iwlwifi-135-6 \
    linux-firmware-iwlwifi-3160 \
    linux-firmware-iwlwifi-6000-4 \
    linux-firmware-iwlwifi-6000g2a-6 \
    linux-firmware-iwlwifi-6000g2b-6 \
    linux-firmware-iwlwifi-6050-5 \
    linux-firmware-iwlwifi-7260 \
    linux-firmware-iwlwifi-7265 \
    linux-firmware-iwlwifi-7265d \
    linux-firmware-iwlwifi-8000c \
    linux-firmware-iwlwifi-8265 \
    linux-firmware-iwlwifi-9260 \
    linux-firmware-mt7601u \
    linux-firmware-ralink \
    linux-firmware-rtl8188eu \
    linux-firmware-rtl8192cu \
    linux-firmware-rtl8192su \
    linux-firmware-rtl8723 \
    linux-firmware-rtl8723b-bt \
    linux-firmware-wl12xx \
    linux-firmware-wl18xx \
"
