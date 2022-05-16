FILESEXTRAPATHS_prepend := "${THISDIR}/patches:"

UBOOT_KCONFIG_SUPPORT = "1"
inherit resin-u-boot

DEPENDS = "bison-native"

PV_append ="+git${SRCPV}"

SRC_URI_remove = " \
	file://resin-specific-env-integration-kconfig.patch \
"

do_compile_prepend() {
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

BALENA_UBOOT_DEVICE_TYPES_prepend = " usb "

SRC_URI_append = " \
	file://1127-Revert-remove-include-config_defaults.h.patch \
	file://1128-Integrate-with-Balena-u-boot-environment.patch \
	file://1129-iot-gate-imx8-Load-kernel-and-fdt-from-root-partitio.patch \
	file://1130-rework-resin-specific-env-integration-kconfig.patch \
	file://1132-u-boot-compulab-Don-t-run-script-if-booting-with-Bal.patch \
"
