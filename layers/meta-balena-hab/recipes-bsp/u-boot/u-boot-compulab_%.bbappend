FILESEXTRAPATHS:prepend := "${THISDIR}/hab:"

SRC_URI:append:mx8m-generic-bsp = " \
    file://security.cfg \
"

do_configure:prepend:mx8m-generic-bsp () {
    cat ${WORKDIR}/security.cfg >> ${S}/configs/${MACHINE}_defconfig
}
