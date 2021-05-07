include balena-image.inc

BALENA_BOOT_PARTITION_FILES_append_iot-gate-imx8 = " \
    imx-boot-${MACHINE}-sd.bin-flash_evk: \
"
