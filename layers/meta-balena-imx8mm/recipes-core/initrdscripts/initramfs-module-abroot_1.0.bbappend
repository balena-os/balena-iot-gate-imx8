FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " file://rollback"

do_install:append() {
	install -m 0755 ${WORKDIR}/rollback ${D}/init.d/74-rollback
}

FILES:${PN}:append = " /init.d/74-rollback" 
