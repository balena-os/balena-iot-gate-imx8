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

SRC_URI:append = " \
    file://arm64-kexec_file-use-more-system-keyrings-to-verify-.patch \
    file://kexec-KEYS-make-the-code-in-bzImage64_verify_sig-gen.patch \
"

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

# Safely optimizes code density without touching any kernel features or APIs
BALENA_CONFIGS:append = " core-optimization"
BALENA_CONFIGS[core-optimization] = " \
    CONFIG_CC_OPTIMIZE_FOR_SIZE=y \
    CONFIG_NUMA=n \
"

# Strips non-existent hardware drivers and Xen (which requires them to function)
BALENA_CONFIGS:append = " iommu-smmu"
BALENA_CONFIGS[iommu-smmu] = " \
    CONFIG_ARM_SMMU=n \
    CONFIG_ARM_SMMU_V3=n \
    CONFIG_IOMMU_IO_PGTABLE=n \
    CONFIG_IOMMU_IO_PGTABLE_LPAE=n \
    CONFIG_XEN=n \
"

# Removes common clock routing trees compiled for alternative family chips (Plus, Nano, etc.)
BALENA_CONFIGS:append = " alternative-clocks"
BALENA_CONFIGS[alternative-clocks] = " \
    CONFIG_CLK_IMX8MN=n \
    CONFIG_CLK_IMX8MP=n \
    CONFIG_CLK_IMX8MQ=n \
    CONFIG_CLK_IMX8QXP=n \
"

# Disables USB 3.0 frameworks and SATA controllers (IMX8MM is restricted to USB 2.0 and eMMC)
BALENA_CONFIGS:append = " extra-storage"
BALENA_CONFIGS[extra-storage] = " \
    CONFIG_USB_XHCI_HCD=n \
    CONFIG_USB_DWC3=n \
    CONFIG_USB_DWC3_IMX8MP=n \
    CONFIG_SATA_AHCI=n \
    CONFIG_AHCI_IMX=n \
"

# Eliminates alternative video processing engines; the i.MX8M Mini exclusively supports the Hantro VPU
BALENA_CONFIGS:append = " multimedia-vpu"
BALENA_CONFIGS[multimedia-vpu] = " \
    CONFIG_MXC_VPU_MALONE=n \
    CONFIG_MXC_VPU_WINDSOR=n \
"

# Eliminates enterprise-grade PCIe network adapters
BALENA_CONFIGS:append = " server-nics"
BALENA_CONFIGS[server-nics] = " \
    CONFIG_AMD_XGBE=n \
    CONFIG_THUNDER_NIC_PF=n \
    CONFIG_HNS3=n \
    CONFIG_NET_VENDOR_MELLANOX=n \
    CONFIG_E1000E=n \
"


do_install:append() {
    # Module support is needed as a dependency for kexec image authentication
    # specifically CONFIG_SYSTEM_DATA_VERIFICATION
    # But we remove modules here
    rm -rf ${D}/etc ${D}${nonarch_base_libdir} ${D}${exec_prefix}
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
