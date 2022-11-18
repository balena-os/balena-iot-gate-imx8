CONNECTIVITY_FIRMWARES_append = " \
    linux-firmware-ath10k \
"

# Fixes: nothing provides linux-firmware-bcm43143 needed by packagegroup-balena-connectivity-1.0-r0.all
CONNECTIVITY_FIRMWARES_remove = " \
    linux-firmware-bcm43143 \
"
