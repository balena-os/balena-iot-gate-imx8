inherit kernel-resin

# Fixes error: packages already installed
# by kernel-image-initramfs
do_install_append() {
	rm ${D}/boot/Image.gz
}

BALENA_CONFIGS_append = " nfsd"
BALENA_CONFIGS[nfsd] = " \
    CONFIG_NFSD=m \
    CONFIG_NFS_ACL_SUPPORT=y \
"
