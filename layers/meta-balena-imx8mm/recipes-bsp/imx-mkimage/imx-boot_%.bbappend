DEPENDS:append = " \
    u-boot-compulab \
"
do_configure[nostamp] = "1"
do_compile[depends] += "u-boot-compulab:do_deploy"
do_compile[nostamp] = "1"

do_install:remove() {
    ln -fs ${BOOT_CONFIG_MACHINE}-${target} ${D}/boot/imx-boot
}
