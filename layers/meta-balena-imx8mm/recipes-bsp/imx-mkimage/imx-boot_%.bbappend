# codeuaurora is no longer available, so change the meta-freescale
# entire SRC_URI here to point to the github imx-mkimage mirror
SRC_URI = "git://github.com/nxp-imx/imx-mkimage.git;protocol=https;branch=${SRCBRANCH} \
           file://0001-mkimage_fit_atf-fix-fit-generator-node-naming.patch \
           file://0001-iMX8M-soc.mak-use-native-mkimage-from-sysroot.patch \
           file://0001-Add-support-for-overriding-BL32-and-BL33-not-only-BL.patch \
           file://0001-Add-LDFLAGS-to-link-step.patch \
           file://0001-Add-support-for-overriding-BL31-BL32-and-BL33.patch \
"

DEPENDS:append = " \
    u-boot-compulab \
"
do_configure[nostamp] = "1"
do_compile[depends] += "u-boot-compulab:do_deploy"
do_compile[nostamp] = "1"
