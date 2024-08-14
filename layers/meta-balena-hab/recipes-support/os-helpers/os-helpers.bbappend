FILESEXTRAPATHS:append := ":${THISDIR}/${PN}"

SRC_URI += " \
    file://os-helpers-sb \
"

do_install:append() {
	install -m 0775 ${WORKDIR}/os-helpers-sb ${D}${libexecdir}
	sed -i -e "s,@@KERNEL_IMAGETYPE@@,${KERNEL_IMAGETYPE},g" ${D}${libexecdir}/os-helpers-sb
	sed -i -e "s,@@BALENA_IMAGE_FLAG_FILE@@,${BALENA_IMAGE_FLAG_FILE},g" ${D}${libexecdir}/os-helpers-sb
}
