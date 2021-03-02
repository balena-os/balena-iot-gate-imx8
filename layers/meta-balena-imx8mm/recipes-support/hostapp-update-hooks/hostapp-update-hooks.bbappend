FILESEXTRAPATHS_append := ":${THISDIR}/files"

HOSTAPP_HOOKS_append = " \
    99-resin-uboot \
    99-flash-bootloader \
"
