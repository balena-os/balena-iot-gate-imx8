# ATH10K for QCA9880 (used by customer),
# iwlwifi for internal BT
CONNECTIVITY_FIRMWARES_append = " \
    linux-firmware-ath10k \
    linux-firmware-iwlwifi-cc-a0 \
    linux-firmware-ibt-20 \
"

# Fixes: nothing provides linux-firmware-bcm43143 needed by packagegroup-balena-connectivity-1.0-r0.all
CONNECTIVITY_FIRMWARES_remove = " \
    linux-firmware-bcm43143 \
"
