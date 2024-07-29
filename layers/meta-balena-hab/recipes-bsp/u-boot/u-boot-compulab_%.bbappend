FILESEXTRAPATHS:prepend := "${THISDIR}/hab:"

do_generate_resin_uboot_configuration:prepend() {
    d.appendVar('UBOOT_VARS', ' KERNEL_SIGN_IVT_OFFSET')
    hab_auth_file = os.path.join(d.getVar('STAGING_DIR_TARGET'), "sysroot-only", "hab_auth")
    if os.path.exists(hab_auth_file):
        with open(hab_auth_file) as f:
            for line in f:
                if line.strip() and not line.startswith('#'):
                    key, value = line.strip().split('=', 1)
                    if key == 'KERNEL_SIGN_IVT_OFFSET':
                        d.setVar(key, value)
    bb.note("KERNEL_SIGN_IVT_OFFSET is now %s" % d.getVar('KERNEL_SIGN_IVT_OFFSET'))
}

SRC_URI:append:mx8m-generic-bsp = " \
    file://security.cfg \
    file://mach-imx-hab-allow-to-specify-custom-IVT-offset-from.patch \
    file://iot-gate-imx8-extend-the-load-address-for-FDT-files.patch \
    file://iot-gate-imx8-add-placeholder-for-IVT-offset-to-envi.patch \
"

do_configure:prepend:mx8m-generic-bsp () {
    cat ${WORKDIR}/security.cfg >> ${S}/configs/${MACHINE}_defconfig
}

# For KERNEL_SIGN_IVT_OFFSET
do_generate_resin_uboot_configuration[depends] += " linux-compulab:do_populate_sysroot"
