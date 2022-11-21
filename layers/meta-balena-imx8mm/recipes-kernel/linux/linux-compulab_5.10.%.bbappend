inherit kernel-resin

# Fixes error: packages already installed
# by kernel-image-initramfs
do_install_append() {
	rm ${D}/boot/Image.gz
}

BALENA_CONFIGS_append = " nfsd"
BALENA_CONFIGS[nfsd] = " \
    CONFIG_NFSD=y \
    CONFIG_NFSD_V3=y \
    CONFIG_NFSD_V4=y \
"

BALENA_CONFIGS_append = " ath10k"
BALENA_CONFIGS[ath10k] = " \
    CONFIG_ATH10K=m \
    CONFIG_ATH10K_PCI=m \
"

SCMVERSION="n"
