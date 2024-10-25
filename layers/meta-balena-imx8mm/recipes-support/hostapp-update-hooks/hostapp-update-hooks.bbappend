FILESEXTRAPATHS:append := ":${THISDIR}/files"

HOSTAPP_HOOKS:append = " \
    99-balena-bootloader \
    99-flash-bootloader \
"
