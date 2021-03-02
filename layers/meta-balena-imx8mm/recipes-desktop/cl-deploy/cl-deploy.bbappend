PACKAGE_ARCH = "${MACHINE_ARCH}"
RDEPENDS_${PN}_remove = "u-boot-fw-utils"
SRC_URI_remove = "file://cl-deploy.mtd"
COMPATIBLE_MACHINE = "(cl-som-imx8|ucm-imx8|ucm-imx8m-mini|mcm-imx8m-mini|iot-gate-imx8|mcm-imx8m-nano)"
