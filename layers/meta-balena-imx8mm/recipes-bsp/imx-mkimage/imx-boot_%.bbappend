DEPENDS:append = " \
    u-boot-compulab \
"
do_configure[nostamp] = "1"
do_compile[depends] += "u-boot-compulab:do_deploy"
do_compile[nostamp] = "1"

do_install:prepend() {
    nconfigs=0
    for type in ${UBOOT_CONFIG}; do
        nconfigs=$(expr $nconfigs + 1)
    done
    if [ "$nconfigs" -gt 1 ]; then
        bbfatal "More than one U-boot is being built - please adapt. Current configs: ${UBOOT_CONFIG}"
    fi
}
