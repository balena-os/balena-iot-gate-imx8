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

BALENA_CONFIGS_append = " tpm"
BALENA_CONFIGS_DEPS[tpm] = " \
    CONFIG_HW_RANDOM_TPM=y \
    CONFIG_SECURITYFS=y \
"
BALENA_CONFIGS[tpm] = " \
    CONFIG_TCG_TPM=m \
    CONFIG_TCG_TIS_CORE=m \
    CONFIG_TCG_TIS=m \
    CONFIG_TCG_CRB=m \
"

SCMVERSION="n"
