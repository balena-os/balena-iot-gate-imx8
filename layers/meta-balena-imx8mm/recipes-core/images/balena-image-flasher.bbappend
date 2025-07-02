include balena-image.inc

BALENA_BOOT_PARTITION_FILES:append:iot-gate-imx8 = " \
    boot.scr:/boot.scr \
"

python do_image_check() {
    if d.getVar("SOM_SUPPORTS_FASTBOOT") == "yes":
        bb.fatal("SOM_SUPPORTS_FASTBOOT is yes; Make it no for balena-image-flasher")
}
addtask do_image_check
do_rootfs[depends] += "balena-image-flasher:do_image_check"
