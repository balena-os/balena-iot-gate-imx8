IMAGE_ROOTFS_MAXSIZE = "40960"

PACKAGE_INSTALL:append = " os-helpers-power"

PACKAGE_INSTALL:remove:iot-gate-imx8 = " initramfs-module-recovery"
PACKAGE_INSTALL:remove:iot-gate-imx8 = " initramfs-module-migrate"
