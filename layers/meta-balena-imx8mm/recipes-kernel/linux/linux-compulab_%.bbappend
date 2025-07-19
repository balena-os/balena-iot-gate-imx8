FILESEXTRAPATHS:prepend := "${THISDIR}/linux-compulab:"

inherit kernel-resin kernel-balena

DEPENDS += "rsync-native"

SRC_URI:append = " file://balena.cfg "

KERNEL_PACKAGE_NAME="kernel"

SCMVERSION="n"

SRCREV = "8c23146939f2b7ca74adc813480f4a207c64bebf"
