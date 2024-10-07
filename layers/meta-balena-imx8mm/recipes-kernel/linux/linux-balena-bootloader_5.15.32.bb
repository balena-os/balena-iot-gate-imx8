SUMMARY = "Balena bootloader based on Compulab Linux Kernel for compulab-imx8mm"

inherit kernel-yocto kernel fsl-kernel-localversion balena-bootloader

LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

SRCBRANCH = "lf-5.15.y"
KERNEL_SRC ?= "git://github.com/nxp-imx/linux-imx.git;protocol=https"
SRC_URI = "${KERNEL_SRC};branch=${SRCBRANCH}"

SRCREV = "fa6c3168595c02bd9d5366fcc28c9e7304947a3d"

# PV is defined in the base in linux-imx.inc file and uses the LINUX_VERSION definition
# required by kernel-yocto.bbclass.
#
# LINUX_VERSION define should match to the kernel version referenced by SRC_URI and
# should be updated once patchlevel is merged.
LINUX_VERSION = "5.15.32"

# Tell to kernel class that we would like to use our defconfig to configure the kernel.
# Otherwise, the --allnoconfig would be used per default which leads to mis-configured
# kernel.
#
# This behavior happens when a defconfig is provided, the kernel-yocto configuration
# uses the filename as a trigger to use a 'allnoconfig' baseline before merging
# the defconfig into the build.
#
# If the defconfig file was created with make_savedefconfig, not all options are
# specified, and should be restored with their defaults, not set to 'n'.
# To properly expand a defconfig like this, we need to specify: KCONFIG_MODE="--alldefconfig"
# in the kernel recipe include.
KCONFIG_MODE="--alldefconfig"

# We need to pass it as param since kernel might support more then one
# machine, with different entry points
KERNEL_EXTRA_ARGS += "LOADADDR=${UBOOT_ENTRYPOINT}"

DEPENDS += "lzop-native bc-native"

KERNEL_VERSION_SANITY_SKIP="1"

# Fetch this from meta-bsp-imx8mm
FILESEXTRAPATHS:prepend := "${COREBASE}/../meta-bsp-imx8mm/recipes-kernel/linux/compulab/imx8mm:"
require recipes-kernel/linux/compulab/imx8mm.inc

BALENA_DEFCONFIG_NAME = "cl-imx8m-mini_defconfig"

do_configure() {
    oe_runmake -C ${S} O=${B} ${BALENA_DEFCONFIG_NAME} ${MACHINE}.config ${KBUILD_DEFCONFIG_EXTRA_FRAGMENTS}
}

do_compile:prepend() {
    export SOURCE_DATE_EPOCH=$(date +%s)
}

do_kernel_localversion:prepend() {
    touch ${WORKDIR}/defconfig
}

PACKAGESPLITFUNCS:remove = "split_kernel_module_packages"

COMPATIBLE_MACHINE = "(ucm-imx8mm|iot-gate-imx8)"

BALENA_CONFIGS_DEPS[secureboot] += " \
    CONFIG_MODULE_SIG_FORMAT=y \
    CONFIG_PKCS7_MESSAGE_PARSER=y \
    CONFIG_SYSTEM_DATA_VERIFICATION=y \
    CONFIG_SIGNED_PE_FILE_VERIFICATION=y \
"

BALENA_CONFIGS[secureboot] += " \
    CONFIG_KEXEC_IMAGE_VERIFY_SIG=y \
"

BALENA_CONFIGS[misc] += " \
    CONFIG_NLS_ISO8859_1=y \
"

BALENA_CONFIGS[i2c] += " \
    CONFIG_FSL_QIXIS=n \
"

do_install:append() {
    # Module support is needed as a dependency for kexec image authentication
    # specifically CONFIG_SYSTEM_DATA_VERIFICATION
    # But we remove modules here
    rm -rf ${D}/etc ${D}/lib
}

do_deploy:append () {
    BOOTENV_FILE="${DEPLOYDIR}/${KERNEL_PACKAGE_NAME}/bootenv"
    grub-editenv "${BOOTENV_FILE}" create
    grub-editenv "${BOOTENV_FILE}" set "resin_root_part=A"
    grub-editenv "${BOOTENV_FILE}" set "bootcount=0"
    grub-editenv "${BOOTENV_FILE}" set "upgrade_available=0"
}

do_deploy[depends] += " grub-native:do_populate_sysroot"

INITRAMFS_IMAGE = "balena-image-bootloader-initramfs"

KERNEL_PACKAGE_NAME = "balena-bootloader"

PROVIDES = "virtual/balena-bootloader"
