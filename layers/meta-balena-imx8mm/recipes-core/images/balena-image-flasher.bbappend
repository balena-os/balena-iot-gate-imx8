include balena-image.inc

BALENA_BOOT_PARTITION_FILES:append:iot-gate-imx8 = " \
    boot.scr:/boot.scr \
"
