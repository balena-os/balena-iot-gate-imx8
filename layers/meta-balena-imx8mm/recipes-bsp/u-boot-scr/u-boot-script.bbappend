FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

do_compile:prepend() {
	BOOTLOADER=$(basename $(ls ${WORKDIR}/recipe-sysroot/boot/imx-boot-* | head -1))
	sed -i "s|##BOOTLOADER##|${BOOTLOADER}|" ${WORKDIR}/boot.script
}

DEPENDS += "imx-boot"

# The boot script (boot.scr) of the install medium updates the eMMC bootloader
# from boot/<imx-boot file> in the second partition of the medium. A board that
# still runs the factory U-Boot depends on it to install the balena bootloader,
# since that U-Boot cannot boot the balena kernel by itself. Install the
# bootloader in the root filesystem explicitly.
RDEPENDS:${PN} += "imx-boot"
