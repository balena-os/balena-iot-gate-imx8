IMAGE_FSTYPES_append = " balenaos-img"


BALENA_BOOT_PARTITION_FILES = " \
    ${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-${MACHINE}.bin:/Image.gz \
    ucm-imx8m-mini.dtb:/ucm-imx8m-mini.dtb \
    sb-iotgimx8.dtb:/sb-iotgimx8.dtb \
    sb-iotgimx8-can.dtb:/sb-iotgimx8-can.dtb \
    sb-iotgimx8-ied.dtb:/sb-iotgimx8-ied.dtb \
    imx-boot-${MACHINE}-sd.bin-flash_evk:/imx-boot-${MACHINE}-sd.bin-flash_evk \
"

IMAGE_CMD_balenaos-img_append () {
    dd if=${DEPLOY_DIR_IMAGE}/imx-boot-${MACHINE}-sd.bin-flash_evk of=${BALENA_RAW_IMG} conv=notrunc seek=33 bs=1K
}
