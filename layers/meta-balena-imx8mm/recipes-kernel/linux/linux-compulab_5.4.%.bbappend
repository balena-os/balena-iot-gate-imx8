inherit kernel-resin

# Fixes error: packages already installed
# by kernel-image-initramfs
do_install_append() {
	rm ${D}/boot/Image.gz
}