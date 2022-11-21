include balena-image.inc

BALENA_BOOT_PARTITION_FILES_append_iot-gate-imx8 = " \
    boot.scr:/boot.scr \
    ${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-${MACHINE}.bin:/Image.gz \
"
