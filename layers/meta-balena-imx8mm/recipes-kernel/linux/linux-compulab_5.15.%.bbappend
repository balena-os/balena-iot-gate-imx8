FILESEXTRAPATHS:prepend := "${THISDIR}/linux-compulab:"

inherit kernel-resin

DEPENDS += "rsync-native"

SRC_URI:append = " \
    file://soc-imx8m-Enable-OCOTP-clock-before-reading-the-regi.patch \
    file://soc-imx8m-Fix-incorrect-check-for-of_clk_get_by_name.patch \
    file://soc-imx8m-Enable-OCOTP-clock-for-imx8mm-before-readi.patch \
    file://iot-gate-imx8-release-3.2.2.1.patch \
"

# Fixes issue where cryptodev module is installed
# along with the kernel image in the initramfs
KERNEL_PACKAGE_NAME="kernel"

BALENA_CONFIGS:append = " nfsd"
BALENA_CONFIGS[nfsd] = " \
    CONFIG_NFSD=y \
    CONFIG_NFSD_V3=y \
    CONFIG_NFSD_V4=y \
"

BALENA_CONFIGS:append = " ath10k"
BALENA_CONFIGS[ath10k] = " \
    CONFIG_ATH10K=m \
    CONFIG_ATH10K_PCI=m \
"

SCMVERSION="n"

BALENA_CONFIGS:append = " imx-sdma "
BALENA_CONFIGS[imx-sdma] = " \
	CONFIG_IMX_SDMA=m \
"

# Ensure this module isn't built-in
BALENA_CONFIGS:append = " cf80211 "
BALENA_CONFIGS[cf80211] = " \
	CONFIG_CFG80211=m \
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

# The merge config performed by the BSP
# overrides the balena OS config elements,
# let's remove it and reinstate it before
# meta-balena injects balena config elements
do_merge_config () {
    echo "Override BSP merge defconfig"
}

# This function was named do_merge_config
# in the BSP kernel recipe. We moved it here
# to ensure it executes before balena configs
# are injected and not after.
do_merge_config_before_resin_inject () {
    configs=arch/arm64/configs
    cp ${S}/${configs}/${MACHINE}_defconfig ${S}/${configs}/compulab_defconfig
    echo "# CONFIG_MACHINE_STUB is not set " > ${WORKDIR}/CONFIG_MACHINE_STUB.cfg
    ${S}/scripts/kconfig/merge_config.sh  -O ${S}/${configs}/ -m ${S}/${configs}/${MACHINE}_defconfig ${WORKDIR}/*.cfg
    mv ${S}/${configs}/.config ${S}/${configs}/${MACHINE}_defconfig
    oe_runmake ${MACHINE}_defconfig
    mv ${S}/${configs}/compulab_defconfig ${S}/${configs}/${MACHINE}_defconfig
    cp ${S}/${configs}/${MACHINE}_defconfig ${}
}

addtask do_merge_config_before_resin_inject after do_configure before kernel_resin_injectconfig

# meta-bsp-imx8mm explicitly packages for /lib so let's also append the path set by nonarch_base_libdir for future use of usrmerge
FILES:${KERNEL_PACKAGE_NAME}-modules += "${nonarch_base_libdir}/modules/"

