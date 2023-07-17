FILESEXTRAPATHS:append := ":${THISDIR}/files"

HOSTAPP_HOOKS:append = " \
    99-resin-uboot \
    99-flash-bootloader \
"
