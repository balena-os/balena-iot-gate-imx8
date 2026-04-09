FILES:${PN}-iwlwifi-cc-a0 = " \
    ${nonarch_base_libdir}/firmware/iwlwifi-cc-a0-59.ucode* \
    ${nonarch_base_libdir}/firmware/iwlwifi-cc-a0-66.ucode* \
"

FILES:${PN}-ax200 = " \
       ${nonarch_base_libdir}/firmware/iwlwifi-cc-a0-50.ucode* \
       ${nonarch_base_libdir}/firmware/iwlwifi-cc-a0-48.ucode* \
       ${nonarch_base_libdir}/firmware/iwlwifi-cc-a0-46.ucode* \
"

FILES:${PN}-ax200-bt = " \
       ${nonarch_base_libdir}/firmware/intel/ibt-20-1-3.ddc* \
       ${nonarch_base_libdir}/firmware/intel/ibt-20-1-3.sfi* \
"

FILES:${PN}-ax210 = " \
        ${nonarch_base_libdir}/firmware/iwlwifi-ty-a0-gf-a0-59.ucode* \
        ${nonarch_base_libdir}/firmware/iwlwifi-ty-a0-gf-a0-66.ucode* \
        ${nonarch_base_libdir}/firmware/iwlwifi-ty-a0-gf-a0-72.ucode* \
        ${nonarch_base_libdir}/firmware/iwlwifi-ty-a0-gf-a0.pnvm* \
"

FILES:${PN}-ax210-bt = " \
        ${nonarch_base_libdir}/firmware/intel/ibt-0041-0041.sfi* \
        ${nonarch_base_libdir}/firmware/intel/ibt-0041-0041.ddc* \
"

PACKAGES =+ " ${PN}-ax200-bt "
PROVIDES =+ " ${PN}-ax200-bt "

PACKAGES =+ " ${PN}-ax210-bt "
PROVIDES =+ " ${PN}-ax210-bt "

