FILESEXTRAPATHS:prepend := "${THISDIR}/patches:"

inherit resin-u-boot

BALENA_STAGE2 = "balena_stage2"
UBOOT_VARS += "BALENA_STAGE2"

DEPENDS = "bison-native"

PV = "2021.04"

do_compile:prepend() {
    if [ ${BUILD_REPRODUCIBLE_BINARIES} -eq 1 ];then
        export SOURCE_DATE_EPOCH=$(date +%s)
    fi
}

# Imported from Poky Dunfell in order to call
# merge_config from the right directory
do_configure () {
    if [ -n "${UBOOT_CONFIG}" ]; then
        unset i j
        for config in ${UBOOT_MACHINE}; do
            i=$(expr $i + 1);
            for type in ${UBOOT_CONFIG}; do
                j=$(expr $j + 1);
                if [ $j -eq $i ]; then
                    oe_runmake -C ${S} O=${B}/${config} ${config}
                    if [ -n "${@' '.join(find_cfgs(d))}" ]; then
                        ${S}/scripts/kconfig/merge_config.sh -m -O ${B}/${config} ${B}/${config}/.config ${@" ".join(find_cfgs(d))}
                        oe_runmake -C ${S} O=${B}/${config} oldconfig
                    fi
                fi
            done
            unset j
        done
        unset i
        DEVTOOL_DISABLE_MENUCONFIG=true
    else
        if [ -n "${UBOOT_MACHINE}" ]; then
            oe_runmake -C ${S} O=${B} ${UBOOT_MACHINE}
        else
            oe_runmake -C ${S} O=${B} oldconfig
        fi
        merge_config.sh -m .config ${@" ".join(find_cfgs(d))}
        cml1_do_configure
    fi
}

BALENA_UBOOT_DEVICE_TYPES:prepend = " usb "

# Fixes SPL crash with CRC32 checks PR in meta-balena.
# CRC32 checks on kernel image and fdt run fine with the above.
UBOOT_VARS:remove = "CONFIG_CMD_HASH"

SRC_URI:append = " \
	file://1127-Revert-remove-include-config_defaults.h.patch \
	file://1128-Integrate-with-Balena-u-boot-environment.patch \
	file://1129-iot-gate-imx8-Load-kernel-and-fdt-from-root-partitio.patch \
	file://1132-u-boot-compulab-Don-t-run-script-if-booting-with-Bal.patch \
	file://1133-iot-gate-imx8-Increase-fdt-address.patch \
	file://1134-iot-gate-imx8-Run-CRC-checks-for-kernel-and-device-t.patch \
	file://1135-iot-gate-imx8-modify-configuration-to-fetch-kernel-b.patch \
	file://1136-configs-cl-imx8m-mini_defconfig-increase-the-default.patch \
	file://1137-iot-gate-imx8-enable-balena-second-stage-bootloader.patch \
"

do_configure[nostamp] = "1"
do_compile[nostamp] = "1"
