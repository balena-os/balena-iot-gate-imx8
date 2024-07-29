inherit hab

SIGN_ARTIFACT_NAME = "Image.gz.initramfs"
# kernel load address in memory
HAB_LOAD_ADDR ?= "0x402000D1"

addtask sign before do_deploy after do_bundle_initramfs

# The kernel is not an EFI artifact
deltask do_sign_efi
deltask do_sign_gpg
