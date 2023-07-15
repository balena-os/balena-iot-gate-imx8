IMAGE_FSTYPES:append = " balenaos-img"


BALENA_BOOT_PARTITION_FILES += " \
    ucm-imx8m-mini.dtb:/ucm-imx8m-mini.dtb \
    sb-iotgimx8.dtb:/sb-iotgimx8.dtb \
    sb-iotgimx8-can.dtb:/sb-iotgimx8-can.dtb \
    sb-iotgimx8-ied.dtb:/sb-iotgimx8-ied.dtb \
    imx-boot-${MACHINE}-sd.bin-flash_evk:/imx-boot-${MACHINE}-sd.bin-flash_evk \
"

IMAGE_CMD:balenaos-img:append () {
    dd if=${DEPLOY_DIR_IMAGE}/imx-boot-${MACHINE}-sd.bin-flash_evk of=${BALENA_RAW_IMG} conv=notrunc seek=33 bs=1K
}

IMAGE_INSTALL:append = " linux-firmware-imx-sdma-imx7d "
IMAGE_INSTALL:remove = "kernel-image"
