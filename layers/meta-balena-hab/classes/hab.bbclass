BOOT_TOOLS = "imx-boot-tools"

DEPENDS:append = " coreutils-native curl-native jq-native ca-certificates-native xxd-native"

inherit deploy

BALENA_SIGN_SLOT_INDEX ?= "0"
BALENA_SIGN_CERTS_KEY_LENGTH ?= "4096"
SIGN_HAB_TYPE ?= "hab"

cst() {
    set -x
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

do_hab_ivt() {
    _signing_artifact="${1}"
    _load_addr="${2}"

    if [ -z "${_signing_artifact}" ] || [ -z "${_load_addr}" ]; then
        bbfatal "Both signing artifact and load address required"
    fi

    _image_size=$(image_size "${_signing_artifact}")
    # Align to the next multiple of 4096
    _padsize_d="$( expr \( $_image_size + 4096 - 1 \) / 4096 \* 4096)"
    _padsize=$(printf "0x%x" ${_padsize_d})
    _ivt_artifact="${_signing_artifact}.ivt"

    # Pad for IVT
    objcopy -I binary -O binary --pad-to ${_padsize_d} --gap-fill=0x00 "${_signing_artifact}" "${_ivt_artifact}"

    _ivt_off=$(printf 0x%x ${_padsize})
    _load_addr_d=$(printf "%d" ${_load_addr})
    _ivt_ptr=$(printf 0x%x $(expr ${_load_addr_d} + ${_padsize_d}))
    _0x20=32
    _csf_ptr=$(printf 0x%x $(expr ${_load_addr_d} + ${_padsize_d} + ${_0x20} ))

    # Generate and concatenate little endian IVT
    # Fields: IVT header, jump location, reserved (0), DCD pointer (null), boot data (null), self pointer, CSF pointer, reserved (0)
    _ivt_header="0x402000D1"
    {
        printf $(printf "%08x" ${_ivt_header} | sed 's/.\{2\}/&\n/g' | tac | sed 's,^,\\x,g' | tr -d '\n') # W: Quote this to prevent word splitting.
        printf $(printf "%08x" ${_load_addr} | sed 's/.\{2\}/&\n/g' | tac | sed 's,^,\\x,g' | tr -d '\n') # W: Quote this to prevent word splitting.
        printf $(printf "%08x" 0 | sed 's/.\{2\}/&\n/g' | tac | sed 's,^,\\x,g' | tr -d '\n') # W: Quote this to prevent word splitting.
        printf $(printf "%08x" 0 | sed 's/.\{2\}/&\n/g' | tac | sed 's,^,\\x,g' | tr -d '\n') # W: Quote this to prevent word splitting.
        printf $(printf "%08x" 0 | sed 's/.\{2\}/&\n/g' | tac | sed 's,^,\\x,g' | tr -d '\n') # W: Quote this to prevent word splitting.
        printf $(printf "%08x" ${_ivt_ptr} | sed 's/.\{2\}/&\n/g' | tac | sed 's,^,\\x,g' | tr -d '\n') # W: Quote this to prevent word splitting.
        printf $(printf "%08x" ${_csf_ptr} | sed 's/.\{2\}/&\n/g' | tac | sed 's,^,\\x,g' | tr -d '\n') # W: Quote this to prevent word splitting.
        printf $(printf "%08x" 0 | sed 's/.\{2\}/&\n/g' | tac | sed 's,^,\\x,g' | tr -d '\n') # W: Quote this to prevent word splitting.
    } >> "${_ivt_artifact}"

    # TODO: Not sure how u-boot uses this yet
    cat << EOF >> "${WORKDIR}/hab_auth_$(basename ${_signing_artifact}).scr"
setenv ivt_off ${_ivt_off}
load mmc \${mmcdev} \${loadaddr} \${image}
hab_auth_img \${loadaddr} \${filesize} \${ivt_off}
EOF

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
    set -x
    _signing_artifact="${WORKDIR}/${SIGN_ARTIFACT_NAME}"
    _load_addr="${HAB_LOAD_ADDR}"

    if [ "${SIGN_HAB_TYPE}" != "hab" ]; then
        bbfatal "Wrong signing class for ${SIGN_HAB_TYPE}"
    fi
    if [ -z "${SIGN_ARTIFACT_NAME}" ]; then
        bbfatal "Artifact name to sign is required"
    fi
    if [ -z "${HAB_LOAD_ADDR}" ]; then
        bbfatal "Load address is required"
    fi

    install "${B}/arch/arm64/boot/${SIGN_ARTIFACT_NAME}" ${_signing_artifact}
    _ivt_artifact=$(do_hab_ivt ${_signing_artifact} ${HAB_LOAD_ADDR})

    prepare_sign_csf

    # Append blocks lines to template
    _ivt_size=$(printf 0x%x $(image_size ${_ivt_artifact}))
    _blocks="  ${HAB_LOAD_ADDR} 0x00000000 ${_ivt_size} \"%%BIN_PATH%%\""
    bbnote "blocks=${_blocks}"
    echo "${_blocks}" >> ${WORKDIR}/csf

    # Generate CSF binaries
    cst ${_ivt_artifact} ${WORKDIR}/csf

    # Append to image to generate signed image
    cat "${_ivt_artifact}" "${WORKDIR}/csf.bin" > "${D}/${SIGN_ARTIFACT_NAME}"
}

do_sign_ahab() {
    bbfatal "Unimplemented AHAB signing"
}

do_sign() {
    do_sign_${SIGN_HAB_TYPE}
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
    install -d "${DEPLOYDIR}/${BOOT_TOOLS}/"
    if [ -f "${D}/${SIGN_ARTIFACT_NAME}" ]; then
        install -m 0644 "${D}/${SIGN_ARTIFACT_NAME}" "${DEPLOYDIR}/${BOOT_TOOLS}/${SIGN_ARTIFACT_NAME}.signed"
    fi
    for f in ${D}/*.scr; do
        if [ -f "${f}" ]; then
            install -m 0644 "${f}" "${DEPLOYDIR}/${BOOT_TOOLS}/$(basename ${f})"
        fi
    done
}
