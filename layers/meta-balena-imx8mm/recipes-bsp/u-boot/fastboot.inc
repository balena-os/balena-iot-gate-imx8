SRC_URI:append = " \
    file://fastboot.cfg \
    file://0003-Balen-Reduce-BOOT_TARGET_DEVICES-list-to-emmc-only.patch \
    file://0004-Balen-Reduce-BOOT_CANDIDATE_LIST-list-to-emmc-only.patch \
"

do_compile:prepend () {
    sed -i 's/\(resin_flasher_skip\)=0/\1=1/g' ${S}/include/env_resin.h
}
