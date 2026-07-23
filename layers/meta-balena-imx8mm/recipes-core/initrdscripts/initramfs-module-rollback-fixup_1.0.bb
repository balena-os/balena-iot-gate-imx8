SUMMARY = "Roll back u-boot when removing balena bootloader"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${BALENA_COREBASE}/COPYING.Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"
RDEPENDS:${PN} = " \
    initramfs-framework-base \
    util-linux-lsblk \
    os-helpers-logging \
    initramfs-module-abroot \
"

inherit allarch

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI = "file://rollback_fixup"

S = "${WORKDIR}"

do_install() {
    install -d ${D}/init.d
    install -m 0755 ${WORKDIR}/rollback_fixup ${D}/init.d/75-rollback_fixup
}

FILES:${PN} = "/init.d/75-rollback_fixup"
