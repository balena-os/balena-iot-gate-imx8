BOOT_TOOLS = "imx-boot-tools"

DEPENDS:append = " coreutils-native curl-native jq-native ca-certificates-native xxd-native"

inherit deploy

BALENA_SIGN_SLOT_INDEX ?= "0"
BALENA_SIGN_CERTS_KEY_LENGTH ?= "4096"
SIGN_HAB_TYPE ?= "hab"
# From U-boot's hab.c CONFIG_PAD_SIZE, 0x2000
CONFIG_PAD_SIZE_D ?= "8192"

# This is the IVT_SIZE macro in U-boot, 0x20
IVT_SIZE_D = "32"

KERNEL_SIGN_IVT_OFFSET ?= "0"

cst() {
    _input_artifact="${1}"
    _csf_artifact="${2}"
    _output_artifact="${2}.bin"

    if [ -z "${_input_artifact}" ]; then
        bbfatal "Nothing to sign"
    fi

    if [ -z "${_csf_artifact}" ]; then
        bbfatal "CSF description file is required"
    fi

    if [ "x${SIGN_API}" = "x" ]; then
        bbnote "Signing API not defined"
        return 1
    fi

    if [ "x${SIGN_API_KEY}" = "x" ]; then
        bbfatal "Signing API key must be defined"
    fi

    if [ "${SIGN_HAB_TYPE}" = "hab" ]; then
        if [ "x${SIGN_HAB_PKI_ID}" = "x" ]; then
            bbfatal "HAB PKI ID must be defined"
        else
            SIGN_NXP_PKI_ID=${SIGN_HAB_PKI_ID}
        fi
    fi

    if [ "${SIGN_HAB_TYPE}" = "ahab" ]; then
        if [ "x${SIGN_AHAB_PKI_ID}" = "x" ]; then
            bbfatal "AHAB PKI ID must be defined"
        else
            SIGN_NXP_PKI_ID=${SIGN_AHAB_PKI_ID}
        fi
    fi

    if [ -z "${SIGN_NXP_PKI_ID}" ]; then
        bbfatal "PKI ID must be defined"
    fi

    REQUEST_FILE=$(mktemp)
    RESPONSE_FILE=$(mktemp)
    _size=$(du -b "${_input_artifact}" | awk '{print $1}')
    # Timeout is 1 minute plus 1 minute per MB
    _timeout=$(expr 60 +  $_size / 1024 / 1024 \* 60)
    echo "{\"pki_id\": \"${SIGN_NXP_PKI_ID}\", \"hab_type\": \"${SIGN_HAB_TYPE}\",\"payload\": \"$(base64 -w 0 ${_input_artifact})\", \"csf\": \"$(base64 -w 0 ${_csf_artifact})\" }" > "${REQUEST_FILE}"
    if CURL_CA_BUNDLE="${STAGING_DIR_NATIVE}/etc/ssl/certs/ca-certificates.crt" curl --retry 5 --silent --show-error --max-time ${_timeout} "${SIGN_API}/nxp/cst" -X POST -H "Content-Type: application/json" -H "X-API-Key: ${SIGN_API_KEY}" -d "@${REQUEST_FILE}" --output "${RESPONSE_FILE}"; then
        jq -r ".csf_bin" < "${RESPONSE_FILE}" | base64 -d > "${_output_artifact}"
    else
        bbfatal "Failed to sign ${_input_artifact} with error $?"
    fi
    if [ ! -s "${_output_artifact}" ]; then
        bbfatal "Unspecified error - empty file"
    fi
    rm -f "${REQUEST_FILE}" "${RESPONSE_FILE}"
}

image_size() {
    echo "$(stat -L -c %s ${1})"
}


# +------------+  0x0 (DDR_UIMAGE_START) -
# |   Header   |                          |
# +------------+  0x40                    |
# |            |                          |
# |            |                          |
# |            |                          |
# |            |                          |
# | Image Data |                          |
# .            |                          |
# .            |                           > Stuff to be authenticated ----+
# .            |                          |                                |
# |            |                          |                                |
# |            |                          |                                |
# +------------+                          |                                |
# |            |                          |                                |
# | Fill Data  |                          |                                |
# |            |                          |                                |
# +------------+ Align to ALIGN_SIZE      |                                |
# |    IVT     |                          |                                |
# +------------+ + IVT_SIZE              -                                 |
# |            |                                                           |
# |  CSF DATA  | <---------------------------------------------------------+
# |            |
# +------------+
# |            |
# | Fill Data  |
# |            |
# +------------+ + CSF_PAD_SIZE

do_hab_ivt() {
    _signing_artifact="${1}"
    _load_addr="${2}"

    if [ -z "${_signing_artifact}" ] || [ -z "${_load_addr}" ]; then
        bbfatal "Both signing artifact and load address required"
    fi

    _image_size_d=$(image_size "${_signing_artifact}")
    _image_size=$(printf "0x%x" ${_image_size_d})
    # Align to the next multiple of 4096
    # Equivalent to `raw_image_size + ALIGN_SIZE - 1) & ~(ALIGN_SIZE - 1)`
    # in U-Boot's hab.c authenticate_image()
    _padsize_d="$( expr \( $_image_size_d + 4096 - 1 \) / 4096 \* 4096)"
    _padsize=$(printf "0x%x" ${_padsize_d})
    _ivt_artifact="${_signing_artifact}.ivt"

    # Pad for IVT
    objcopy -I binary -O binary --pad-to ${_padsize_d} --gap-fill=0x00 "${_signing_artifact}" "${_ivt_artifact}"

    _ivt_off=$(printf 0x%x ${_padsize})
    echo "KERNEL_SIGN_IVT_OFFSET=${_ivt_off}" > "${STAGING_DIR_HOST}/hab_auth"
    _load_addr_d=$(printf "%d" ${_load_addr})
    _ivt_ptr=$(printf 0x%x $(expr ${_load_addr_d} + ${_padsize_d}))
    _csf_ptr=$(printf 0x%x $(expr ${_load_addr_d} + ${_padsize_d} + ${IVT_SIZE_D} ))

    bbnote "_load_addr ${_load_addr} _image_size ${_image_size} _padsize ${_padsize} _ivt_off ${_ivt_off} _ivt_ptr ${_ivt_ptr} _csf_ptr ${_csf_ptr}"
    # Generate and concatenate little endian IVT
    # Fields: IVT header, jump location, reserved (0), DCD pointer (null), boot data (null), self pointer, CSF pointer, reserved (0)
    _ivt_header="0x402000D1"
    # Avoid using the shell printf built-in
    PRINTF=$(which printf)
    {
        ${PRINTF} $(${PRINTF} "%08x" ${_ivt_header} | sed 's/.\{2\}/&\n/g' | tac | sed 's,^,\\x,g' | tr -d '\n') # W: Quote this to prevent word splitting.
        ${PRINTF} $(${PRINTF} "%08x" ${_load_addr} | sed 's/.\{2\}/&\n/g' | tac | sed 's,^,\\x,g' | tr -d '\n') # W: Quote this to prevent word splitting.
        ${PRINTF} $(${PRINTF} "%08x" 0 | sed 's/.\{2\}/&\n/g' | tac | sed 's,^,\\x,g' | tr -d '\n') # W: Quote this to prevent word splitting.
        ${PRINTF} $(${PRINTF} "%08x" 0 | sed 's/.\{2\}/&\n/g' | tac | sed 's,^,\\x,g' | tr -d '\n') # W: Quote this to prevent word splitting.
        ${PRINTF} $(${PRINTF} "%08x" 0 | sed 's/.\{2\}/&\n/g' | tac | sed 's,^,\\x,g' | tr -d '\n') # W: Quote this to prevent word splitting.
        ${PRINTF} $(${PRINTF} "%08x" ${_ivt_ptr} | sed 's/.\{2\}/&\n/g' | tac | sed 's,^,\\x,g' | tr -d '\n') # W: Quote this to prevent word splitting.
        ${PRINTF} $(${PRINTF} "%08x" ${_csf_ptr} | sed 's/.\{2\}/&\n/g' | tac | sed 's,^,\\x,g' | tr -d '\n') # W: Quote this to prevent word splitting.
        ${PRINTF} $(${PRINTF} "%08x" 0 | sed 's/.\{2\}/&\n/g' | tac | sed 's,^,\\x,g' | tr -d '\n') # W: Quote this to prevent word splitting.
    } >> "${_ivt_artifact}"

    echo "${_ivt_artifact}"
}

prepare_sign_csf() {
    cat << 'EOF' > ${WORKDIR}/csf
[Header]
    Version = 4.2
    Hash Algorithm = sha256
    Engine = CAAM
    Engine Configuration = 0
    Certificate Format = X509
    Signature Format = CMS

[Install SRK]
    File = "%%CERTS_PATH%%/../SRK_table.bin"
    Source index = %%SLOT_INDEX%%

[Install CSFK]
    File = "%%CERTS_PATH%%/CSF%%SLOT_INDEX+1%%_1_sha256_%%CERTS_KEY_LENGTH%%_65537_v3_usr_crt.pem"

[Authenticate CSF]

[Unlock]
    Engine = CAAM
    Features = MFG

[Install Key]
    Verification index = 0
    Target Index = 2
    File = "%%CERTS_PATH%%/IMG%%SLOT_INDEX+1%%_1_sha256_%%CERTS_KEY_LENGTH%%_65537_v3_usr_crt.pem"

[Authenticate Data]
    Verification index = 2
    Blocks = \
EOF

    # Configure CSF template for key slot index to use
    bbnote "Configuring to use signing slot ${BALENA_SIGN_SLOT_INDEX}"
    sed -i "s/%%SLOT_INDEX%%/${BALENA_SIGN_SLOT_INDEX}/g" "${WORKDIR}/csf"
    _slot_index_1=$(expr ${BALENA_SIGN_SLOT_INDEX} + 1)
    sed -i "s/%%SLOT_INDEX+1%%/${_slot_index_1}/g" "${WORKDIR}/csf"
    bbnote "Configuring to use certificate key lenght ${BALENA_SIGN_CERTS_KEY_LENGTH}"
    sed -i "s/%%CERTS_KEY_LENGTH%%/${BALENA_SIGN_CERTS_KEY_LENGTH}/g" "${WORKDIR}/csf"
}

do_sign_hab() {
    _signing_artifact="${1}"
    _load_addr="${HAB_LOAD_ADDR}"

    if [ -z "${_signing_artifact}" ]; then
        bbfatal "Artifact name to sign is required"
    fi
    if [ -z "${HAB_LOAD_ADDR}" ]; then
        bbfatal "Load address is required"
    fi

    _gzip_payload=0
    _filetype=$(file --mime-type -b "${_signing_artifact}")
    if [ "${_filetype}" = "application/gzip" ]; then
        _gzip_payload=1
        bbnote "Uncompressing compressed payload"
        mv "${_signing_artifact}" "${_signing_artifact}.gz"
        gunzip "${_signing_artifact}.gz"
    fi

    _ivt_artifact=$(do_hab_ivt ${_signing_artifact} ${HAB_LOAD_ADDR})

    prepare_sign_csf

    # Append blocks lines to template
    _image_size_d=$(image_size ${_ivt_artifact})
    _image_size=$(printf 0x%x ${_image_size_d})
    _blocks="  ${HAB_LOAD_ADDR} 0x00000000 ${_image_size} \"%%BIN_PATH%%\""
    bbnote "blocks=${_blocks}"
    echo "${_blocks}" >> ${WORKDIR}/csf

    # Generate CSF binaries
    cst ${_ivt_artifact} ${WORKDIR}/csf

    # Append to image to generate signed image
    cat "${_ivt_artifact}" "${WORKDIR}/csf.bin" > "${_signing_artifact}"

    if [ "${_gzip_payload}" = "1" ]; then
        gzip "${_signing_artifact}"
        mv "${_signing_artifact}.gz" "${_signing_artifact}"
    fi
}

do_sign_ahab() {
    bbfatal "Unimplemented AHAB signing"
}

do_sign() {
    for SIGNING_ARTIFACT in ${SIGNING_ARTIFACTS}; do
        do_sign_${SIGN_HAB_TYPE} ${SIGNING_ARTIFACT}
    done
}

do_sign[depends] += " \
    coreutils-native:do_populate_sysroot \
    curl-native:do_populate_sysroot \
    jq-native:do_populate_sysroot \
    ca-certificates-native:do_populate_sysroot \
"
do_sign[network] = "1"

do_sign[vardeps] += " \
    SIGN_API \
    SIGN_HAB_PKI_ID \
    SIGN_AHAB_PKI_ID \
    SIGN_HAB_TYPE \
"

do_deploy:append() {
    for SIGNING_ARTIFACT in ${SIGNING_ARTIFACTS}; do
        if [ -f "${SIGNING_ARTIFACT}.signed" ]; then
            install -m 0644 "${SIGNING_ARTIFACT}.signed" "${DEPLOYDIR}/$(basename ${SIGNING_ARTIFACT})"
        fi
    done
}
