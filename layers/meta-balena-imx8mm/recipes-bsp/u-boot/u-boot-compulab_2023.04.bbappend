FILESEXTRAPATHS:prepend := "${THISDIR}/patches:"

inherit resin-u-boot

BALENA_STAGE2 = "balena_stage2"
UBOOT_VARS += "BALENA_STAGE2"

DEPENDS = "bison-native"

PV:append ="+git${SRCPV}"

require ${@bb.utils.contains('SOM_SUPPORTS_FASTBOOT', 'yes', 'fastboot.inc', 'flasher.inc', d)}

SRC_URI:append = " \
    file://0001-Balena-Patch-for-2023.04.patch \
    file://0002-Balena-Fix-build-error-env-mmc.c.patch \
"

do_configure:prepend () {
    export PATH=${PATH}:${S}/scripts/kconfig/
}

do_deploy:append () {
    BOOTENV_FILE="${DEPLOYDIR}/bootenv"
    grub-editenv "${BOOTENV_FILE}" create
    grub-editenv "${BOOTENV_FILE}" set "resin_root_part=A"
    grub-editenv "${BOOTENV_FILE}" set "bootcount=0"
    grub-editenv "${BOOTENV_FILE}" set "upgrade_available=0"
}
do_deploy[depends] += " grub-native:do_populate_sysroot"

do_configure[nostamp] = "1"
do_compile[nostamp] = "1"
