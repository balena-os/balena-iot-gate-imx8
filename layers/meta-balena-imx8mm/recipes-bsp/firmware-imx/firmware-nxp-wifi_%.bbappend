# The installed Bluetooth firmware files have a doubled "uart" prefix that the
# upstream FILES patterns don't match, which fails the installed-vs-shipped QA check
FILES:${PN}-nxp8997-common += "${nonarch_base_libdir}/firmware/nxp/uartuart8997_bt_v4.bin"
FILES:${PN}-nxp9098-common += "${nonarch_base_libdir}/firmware/nxp/uartuart9098_bt_v1.bin"
