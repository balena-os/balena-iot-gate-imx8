FILESEXTRAPATHS:prepend := "${THISDIR}/linux-compulab:"

inherit kernel-resin

# The BSP recipe tracks AUTOREV, pin it
SRCREV = "c0f74147d79e65b839284ed41d0ee73cbe483d90"

DEPENDS += "rsync-native"

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

# Frees the uart2/uart4 termination GPIOs claimed by always-on regulators
# on the IED extension board (carried over from the BSP's balena branch)
SRC_URI:append = " file://0001-iot-gate-imx8-dts-free-gpio_rs485_trm.patch"

# uart4 shares its pads with ECSPI2, which the PoE extension uses for its
# SPI Ethernet controller. The -poed DTB is not shipped in the boot
# partition yet (carried over from the BSP's balena branch)
SRC_URI:append = " file://0002-iot-gate-imx8-dtb-Fix-PoE-rev1.0.patch"

BALENA_CONFIGS:append = " f81232"
BALENA_CONFIGS[f81232] = " \
    CONFIG_USB_SERIAL_F81232=m \
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


# The 6.6 vendor defconfig sets MEDIA_SUPPORT_FILTER=n, which builds every media subsystem
# (DVB, analog TV, radio, SDR, CEC, test drivers: ~1.4 MiB of modules). Restore the filtering the 5.15
# config had and keep only camera/platform capture support.
BALENA_CONFIGS:append = " media-filter"
BALENA_CONFIGS[media-filter] = " \
    CONFIG_MEDIA_SUPPORT_FILTER=y \
    CONFIG_MEDIA_DIGITAL_TV_SUPPORT=n \
    CONFIG_MEDIA_ANALOG_TV_SUPPORT=n \
    CONFIG_MEDIA_RADIO_SUPPORT=n \
    CONFIG_MEDIA_SDR_SUPPORT=n \
    CONFIG_MEDIA_CEC_SUPPORT=n \
    CONFIG_MEDIA_TEST_SUPPORT=n \
"

# meta-balena-hab carries this fix for older kernels, it is already in
# the Compulab 6.6 tree and the patch does not apply
SRC_URI:remove = "file://crypto-engine-fix-crypto_queue-backlog-handling.patch"
