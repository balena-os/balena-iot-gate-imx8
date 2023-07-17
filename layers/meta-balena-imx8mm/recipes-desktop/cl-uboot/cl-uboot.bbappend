# Simple recipe to add desktop icon and executable to run
# CompuLab U-Boot Tool

DESCRIPTION = "CompuLab U-Boot Tool for imx8 SoC"
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

do_install:prepend() {
    sed -i "s|##SEEK##|${IMX_BOOT_SEEK}|" ${S}/cl-uboot.work
}

PACKAGE_ARCH = "${MACHINE_ARCH}"
RDEPENDS:${PN}:remove  = " mtd-utils u-boot-compulab "
RDEPENDS:${PN}:append  = " imx-boot mmc-utils "
COMPATIBLE_MACHINE = "(cl-som-imx8|ucm-imx8m-mini|mcm-imx8m-mini|iot-gate-imx8|mcm-imx8m-nano)"
