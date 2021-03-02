# Simple recipe to add desktop icon and executable to run
# CompuLab Deployment Tool

DESCRIPTION = "CompuLab Deployment Tool"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://COPYING;md5=4a0e2a2916052068a420bbc50873f515"

PR = "r3"

SRC_URI = " \
	file://cl-deploy \
	file://cl-deploy.work \
	file://cl-deploy.helper \
	file://cl-deploy.mtd \
	file://cl-deploy.desktop \
	file://cl-deploy.png \
	file://cl-auto \
	file://cl-init \
	file://cl-reboot \
	file://cl-auto.conf.header \
	file://cl-auto.conf_cl-som-imx7 \
	file://cl-auto.conf_cl-som-imx8 \
	file://cl-auto.conf_ucm-imx8m-mini \
	file://cl-auto.bashrc \
	file://cl-auto.shell \
	file://cl-functions.inc \
	file://cl-auto.inc \
	file://cl-auto.notifier \
	file://COPYING \
"

SRC_URI_append_cl-som-imx6ul = " \
	file://cl-deploy.cl-som-imx6ul \
"

S = "${WORKDIR}"

do_install() {
	mkdir -p ${D}/usr/local/bin/
	mkdir -p ${D}/usr/share/applications/
	install -m 0755 ${S}/cl-deploy ${D}/usr/local/bin/
	install -m 0755 ${S}/cl-deploy.work ${D}/usr/local/bin/
	install -m 0755 ${S}/cl-deploy.helper ${D}/usr/local/bin/
	install -m 0755 ${S}/cl-auto ${D}/usr/local/bin/
	install -m 0755 ${S}/cl-auto.shell ${D}/usr/local/bin/
	install -m 0755 ${S}/cl-init ${D}/usr/local/bin/
	install -m 0755 ${S}/cl-reboot ${D}/usr/local/bin/
	install -m 0644 ${S}/cl-deploy.png ${D}/usr/share/applications/
	install -m 0644 ${S}/cl-deploy.desktop ${D}/usr/share/applications/
	mkdir -p ${D}/usr/share/cl-deploy/
	if [ -f ${S}/cl-auto.conf_${MACHINE} ];then
	cat ${S}/cl-auto.conf.header ${S}/cl-auto.conf_${MACHINE} > ${S}/cl-auto.conf.sample
	install -m 0644 ${S}/cl-auto.conf.sample ${D}/usr/share/cl-deploy/
	fi
	install -m 0644 ${S}/cl-auto.bashrc ${D}/usr/share/cl-deploy/
	install -m 0644 ${S}/cl-functions.inc ${D}/usr/share/cl-deploy/
	install -m 0644 ${S}/cl-auto.inc ${D}/usr/share/cl-deploy/
	install -m 0644 ${S}/cl-auto.notifier ${D}/usr/share/cl-deploy/
}

do_mtd_copy() {
	[ -f ${S}/cl-deploy.mtd ] && install -m 0755 ${S}/cl-deploy.mtd ${D}/usr/local/bin/
}

do_install_append_cm-fx6-evk() {
	do_mtd_copy
}

do_install_append_cl-som-imx6() {
	do_mtd_copy
}

do_install_append_cl-som-imx7() {
	do_mtd_copy
}

do_install_append_cl-som-imx6ul() {
	cp ${S}/cl-deploy.cl-som-imx6ul ${D}/usr/local/bin/cl-deploy.platform
}

FILES_${PN} = " \
	/usr/local/bin/* \
	/usr/share/* \
"

RDEPENDS_${PN} = "bash pv dialog file gzip bzip2 dosfstools util-linux xz e2fsprogs parted"
RDEPENDS_${PN}_append = " ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'xterm', '', d)}"
PACKAGE_ARCH = "all"
