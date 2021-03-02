# CompuLab CleanUp Tool

DESCRIPTION = "CompuLab CleanUp Tool"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://COPYING;md5=4a0e2a2916052068a420bbc50873f515"

PR = "r1"

SRC_URI = " \
	file://cl-cleanup \
	file://cl-cleanup.work \
	file://cl-cleanup.desktop \
	file://cl-cleanup.png \
	file://COPYING \
"

S = "${WORKDIR}"

do_install() {
	mkdir -p ${D}/usr/local/bin/
	mkdir -p ${D}/usr/share/applications/
	cp ${S}/cl-cleanup ${D}/usr/local/bin/
	cp ${S}/cl-cleanup.work ${D}/usr/local/bin/
	cp ${S}/cl-cleanup.png ${D}/usr/share/applications/
	cp ${S}/cl-cleanup.desktop ${D}/usr/share/applications/
}

FILES_${PN} = " \
	/usr/local/bin/* \
	/usr/share/applications/* \
"

ALLOW_EMPTY_${PN} = "1"
RDEPENDS_${PN} = "bash"
