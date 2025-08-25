# ATH10K for QCA9880 (used by customer),
# iwlwifi for internal BT
CONNECTIVITY_FIRMWARES:append = " \
    linux-firmware-ath10k \
    linux-firmware-qca \
    linux-firmware-iwlwifi-cc-a0 \
    linux-firmware-ibt-20 \
    linux-firmware-iwlwifi-ty-a0 \
    linux-firmware-ibt-41-41 \
    linux-firmware-iwlwifi-license \
"

# Fixes: nothing provides linux-firmware-bcm43143 needed by packagegroup-balena-connectivity-1.0-r0.all
CONNECTIVITY_FIRMWARES:remove = " \
    linux-firmware-bcm43143 \
"
