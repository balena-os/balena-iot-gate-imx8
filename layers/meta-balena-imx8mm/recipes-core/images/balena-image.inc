IMAGE_FSTYPES:append = " balenaos-img"

BALENA_BOOT_PARTITION_FILES += " \
    balena-bootloader/ucm-imx8m-mini.dtb:/ucm-imx8m-mini.dtb \
    balena-bootloader/sb-iotgimx8.dtb:/sb-iotgimx8.dtb \
    balena-bootloader/sb-iotgimx8-can.dtb:/sb-iotgimx8-can.dtb \
    balena-bootloader/sb-iotgimx8-ied.dtb:/sb-iotgimx8-ied.dtb \
    balena-bootloader/${KERNEL_IMAGETYPE}-initramfs-${MACHINE}.bin:/${KERNEL_IMAGETYPE} \
    balena-bootloader/bootenv:/bootenv \
    imx-boot-${MACHINE}-sd.bin-flash_evk:/imx-boot-${MACHINE}-sd.bin-flash_evk \
"

IMAGE_CMD:balenaos-img:append () {
    dd if=${DEPLOY_DIR_IMAGE}/imx-boot-${MACHINE}-sd.bin-flash_evk of=${BALENA_RAW_IMG} conv=notrunc seek=33 bs=1K
}

IMAGE_INSTALL:append = " linux-firmware-imx-sdma-imx7d grub-editenv"
IMAGE_INSTALL:remove = "kernel-image"

do_rootfs[depends] += " virtual/balena-bootloader:do_deploy"
do_image_balenaos_img[depends] += " virtual/balena-bootloader:do_deploy"

ALLOWED_FIRMWARE_PACKAGES = " \
    linux-firmware-ax200 \
    linux-firmware-ax210 \
"

BALENA_ALLOWED_FIRMWARE_PACKAGES:append = "${ALLOWED_FIRMWARE_PACKAGES}"

TEMPORARILY_ALLOWED_PACKAGES = " \
    linux-firmware-ibt-20 \
    linux-firmware-qca \
"

BALENA_ALLOWED_FIRMWARE_PACKAGES:append = "${TEMPORARILY_ALLOWED_PACKAGES}"
