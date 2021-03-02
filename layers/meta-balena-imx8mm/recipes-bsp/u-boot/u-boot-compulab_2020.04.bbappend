FILESEXTRAPATHS_prepend := "${THISDIR}/patches:"

UBOOT_KCONFIG_SUPPORT = "1"
inherit resin-u-boot

SRC_URI_remove = " \
	file://resin-specific-env-integration-kconfig.patch \
"

SRC_URI_append = " \
	file://0001-Integrate-with-Balena-u-boot-environment.patch \
	file://0002-rework-resin-specific-env-integration-kconfig.patch \
	file://0003-increase-default-env-size.patch \
"

RESIN_UBOOT_DEVICE_TYPES_prepend = " usb "
