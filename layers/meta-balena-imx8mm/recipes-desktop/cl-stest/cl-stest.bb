# Simple recipe to add desktop icon and executable to run
# CompuLab Stress Test Tool

DESCRIPTION = "CompuLab Stress Test Tool"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://COPYING;md5=396ed65bba4045e7a22bcdb2ae6901b8"
MAINTAINER = "CompuLab <compulab@compulab.com>"

PR = "r0"

SRC_URI = " \
	file://cl-stest \
	file://cl-stest.desktop \
	file://cl-stest.png \
	file://gov \
	file://buf \
	file://mem \
	file://cpu \
	file://gpu \
	file://opt \
	file://work \
	file://COPYING \
"

S = "${WORKDIR}"

do_install() {
    install -d ${D}/opt/compulab/cl-stest/

    cp ${S}/cl-stest ${D}/opt/compulab/cl-stest/
    for name in work gov buf mem cpu gpu opt;do
        cp ${S}/$name ${D}/opt/compulab/cl-stest/
    done
    chmod a+x ${D}/opt/compulab/cl-stest/*

    install -d ${D}/usr/share/applications/
    cp ${S}/cl-stest.png ${D}/usr/share/applications/
    cp ${S}/cl-stest.desktop ${D}/usr/share/applications/
}

FILES_${PN} = " \
	/opt/compulab/cl-stest/* \
	/usr/share/applications/* \
"

RDEPENDS_${PN} = "bash xz memtester"
RDEPENDS_${PN}_append = " ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'xterm', '', d)}"
RDEPENDS_${PN}_append = " ${@bb.utils.contains('MACHINE', 'cl-som-imx7', '', 'imx-gpu-viv-demos', d)}"
PACKAGE_ARCH = "${MACHINE_ARCH}"
