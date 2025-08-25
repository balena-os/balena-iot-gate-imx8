FILES:${PN}-iwlwifi-cc-a0 = " \
    ${nonarch_base_libdir}/firmware/iwlwifi-cc-a0-59.ucode* \
    ${nonarch_base_libdir}/firmware/iwlwifi-cc-a0-66.ucode* \
"

# These local fixes below for the AX210 wireless module
# can be removed after https://github.com/balena-os/meta-balena/pull/3718
# is merged and brought in this device repository
FILES:${PN}-ibt-41-41  = " \
    ${nonarch_base_libdir}/firmware/intel/ibt-0041-0041.ddc* \
    ${nonarch_base_libdir}/firmware/intel/ibt-0041-0041.sfi* \
 "

FILES:${PN}-iwlwifi-ty-a0  = " \
    ${nonarch_base_libdir}/firmware/iwlwifi-ty-a0-*.ucode* \
    ${nonarch_base_libdir}/firmware/iwlwifi-ty-a0-*.pnvm* \
"

