FILESEXTRAPATHS:append := ":${THISDIR}/${PN}"

SRC_URI += " \
    file://os-helpers-power \
"

PACKAGES += "${PN}-power"

do_install:append() {
	install -m 0775 ${WORKDIR}/os-helpers-power ${D}${libexecdir}
}

FILES:${PN}-power = "/usr/libexec/os-helpers-power"
