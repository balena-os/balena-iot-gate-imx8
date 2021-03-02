# Simple recipe to add desktop icon and executable to run
# CompuLab U-Boot Tool

DESCRIPTION = "CompuLab U-Boot Tool"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://COPYING;md5=258fbdf7b6336b41e0980f2046ff2ac0"

PR = "r1"

SRC_URI = " \
	file://cl-uboot \
	file://cl-uboot.work \
	file://cl-uboot.desktop \
	file://cl-uboot.png \
	file://COPYING \
"

S = "${WORKDIR}"

do_install() {
	mkdir -p ${D}/usr/local/bin/
	mkdir -p ${D}/usr/share/applications/
	cp ${S}/cl-uboot ${D}/usr/local/bin/
	cp ${S}/cl-uboot.work ${D}/usr/local/bin/
	cp ${S}/cl-uboot.png ${D}/usr/share/applications/
	cp ${S}/cl-uboot.desktop ${D}/usr/share/applications/
}

FILES_${PN} = " \
	/usr/local/bin/* \
	/usr/share/applications/* \
"

RDEPENDS_${PN} = "bash pv dialog mtd-utils"
#RDEPENDS_${PN}_append = " ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'xterm', '', d)}"
PACKAGE_ARCH = "all"
