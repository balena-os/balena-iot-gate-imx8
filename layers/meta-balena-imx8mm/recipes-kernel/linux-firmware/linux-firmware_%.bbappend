FILES:${PN}-iwlwifi-cc-a0 = " \
    ${nonarch_base_libdir}/firmware/iwlwifi-cc-a0-59.ucode* \
    ${nonarch_base_libdir}/firmware/iwlwifi-cc-a0-66.ucode* \
"

# Include only the maximum version supported
# to avoid increasing the occupied rootfs space
# by too much. With this addition the space taken
# up by firmware increases from 2.7M to 3.6M as
# reported by du -h.
FILES:${PN}-iwlwifi-ty-a0 = " \
    ${nonarch_base_libdir}/firmware/iwlwifi-ty-a0-gf-a0-66.ucode* \
    ${nonarch_base_libdir}/firmware/iwlwifi-ty-a0-gf-a0.pnvm* \
"

FILES:${PN}-ax200 += " \
       ${nonarch_base_libdir}/firmware/iwlwifi-cc-a0-50.ucode* \
       ${nonarch_base_libdir}/firmware/iwlwifi-cc-a0-48.ucode* \
       ${nonarch_base_libdir}/firmware/iwlwifi-cc-a0-46.ucode* \
       ${nonarch_base_libdir}/firmware/intel/ibt-20-1-3.ddc* \
       ${nonarch_base_libdir}/firmware/intel/ibt-20-1-3.sfi* \
"

FILES:${PN}-ax210 += " \
        ${nonarch_base_libdir}/firmware/iwlwifi-ty-a0-gf-a0-59.ucode* \
        ${nonarch_base_libdir}/firmware/iwlwifi-ty-a0-gf-a0-66.ucode* \
        ${nonarch_base_libdir}/firmware/iwlwifi-ty-a0-gf-a0-72.ucode* \
        ${nonarch_base_libdir}/firmware/iwlwifi-ty-a0-gf-a0.pnvm* \
        ${nonarch_base_libdir}/firmware/intel/ibt-0041-0041.sfi* \
        ${nonarch_base_libdir}/firmware/intel/ibt-0041-0041.ddc* \
"
