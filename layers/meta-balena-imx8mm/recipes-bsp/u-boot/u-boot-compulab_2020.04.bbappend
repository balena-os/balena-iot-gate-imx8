FILESEXTRAPATHS_prepend := "${THISDIR}/patches:"

UBOOT_KCONFIG_SUPPORT = "1"
inherit resin-u-boot

DEPENDS = "bison-native"

PV_append ="+git${SRCPV}"

SRC_URI_remove = " \
	file://resin-specific-env-integration-kconfig.patch \
"

SRC_URI_append = " \
	file://0001-Integrate-with-Balena-u-boot-environment.patch \
	file://0002-iot-gate-imx8-Load-kernel-and-fdt-from-root-partitio.patch \
	file://0003-rework-resin-specific-env-integration-kconfig.patch \
	file://0004-config-Distinguish-Balena-build.patch \
"

BALENA_UBOOT_DEVICE_TYPES_prepend = " usb "
