inherit hab

# kernel load address in memory i.e u-boot loadaddr
HAB_LOAD_ADDR ?= "0x40480000"

SIGNING_ARTIFACTS ?= "${SIGNING_ARTIFACTS_BASE}"
addtask sign before do_populate_sysroot after do_bundle_initramfs

# Stage the kernel bundle IVT offset for u-boot to use in its environment
sysroot_stage_all:append:class-target () {
    set -x
    install -d "${SYSROOT_DESTDIR}/sysroot-only/"
    install "${STAGING_DIR_HOST}/hab_auth" "${SYSROOT_DESTDIR}/sysroot-only/"
}

# The kernel is not an EFI artifact
deltask do_sign_efi
deltask do_sign_gpg
