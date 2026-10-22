DEPENDS:append = " \
    u-boot-compulab \
"
do_configure[nostamp] = "1"
do_compile[depends] += "u-boot-compulab:do_deploy"
do_compile[nostamp] = "1"

do_install:prepend() {
    nconfigs=0
    for type in ${UBOOT_CONFIG}; do
        nconfigs=$(expr $nconfigs + 1)
    done
    if [ "$nconfigs" -gt 1 ]; then
        bbfatal "More than one U-boot is being built - please adapt. Current configs: ${UBOOT_CONFIG}"
    fi
}

# Only the generic image, with the timings of all the DRAM sizes, is used by balenaOS
# (see hostapp-update hooks, rollback_fixup and the flasher). Do not package the per-size
# images and the tagged copy to save space in the rootfs, the HUP size check is tight.
do_install:append() {
    rm -f ${D}/boot/${FLASH_NAME}-[0-9]*.bin-* ${D}/boot/*.tagged
}
