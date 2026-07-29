do_install:append() {
    # Single quotes, do not expand variables !
    sed -i 's/mount "${BOOT_PART}" "${BOOT_MOUNT}"/mount -t vfat "${BOOT_PART}" "${BOOT_MOUNT}"/g' ${D}/init.d/*-mountboot
}
