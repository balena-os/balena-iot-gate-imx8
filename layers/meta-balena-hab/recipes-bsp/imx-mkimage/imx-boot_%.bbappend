inherit hab

python __anonymous () {
    sign_artifact_names = []
    boot_config_machine = d.getVar('BOOT_CONFIG_MACHINE', True)
    imxboot_targets = d.getVar('IMXBOOT_TARGETS', True)
    for target in imxboot_targets.split():
        sign_artifact_names.append(f"{boot_config_machine}-{target}")
    d.setVar('SIGNING_ARTIFACTS', " ".join(sign_artifact_names))
}

do_compile:append() {
    for target in flash_evk print_fit_hab; do
        bbnote "building ${IMX_BOOT_SOC_TARGET} - ${target}"
        make SOC=${IMX_BOOT_SOC_TARGET} dtbs=${UBOOT_DTB_NAME} ${target} 2>&1 | tee ${target}.log
        install "${B}/${target}.log" "${BOOT_STAGING}/"
    done
}

do_sign_hab() {
    if [ ! -f "${BOOT_STAGING}/flash_evk.log" ] || [ ! -f "${BOOT_STAGING}/print_fit_hab.log" ]; then
        bbfatal "mkimage output files not available in ${BOOT_STAGING} directory"
    fi

    _payload=%%BIN_PATH%%
    # Extract load address, offset and length from mkimage log file
    eval $(awk  -F":" '(/hab block/)&&(gsub(/ /,"_",$1))&&($0=$1"=\""$2"\"")' ${BOOT_STAGING}/flash_evk.log)
    # Append the image binary path
    _spl_hab_block="${_spl_hab_block} \"${_payload}\""
    _sld_hab_block="${_sld_hab_block} \"${_payload}\""

    bbnote "_spl_hab_block=${_spl_hab_block} _sld_hab_block=${_sld_hab_block}"

    # Extract load addresses, offsets and lengths from FIT log file
    blocks=$(awk -v payload=${_payload} '(/^0x/)&&($0=","$0" \""payload"\" \\\n")' ORS=" " ${BOOT_STAGING}/print_fit_hab.log)

    bbnote "blocks=${blocks}"

    prepare_sign_csf

    # Append blocks lines to template
    cat ${WORKDIR}/csf > ${WORKDIR}/csf_fit
    echo "$_sld_hab_block \ " >> ${WORKDIR}/csf_fit
    echo "${blocks}" >> ${WORKDIR}/csf_fit

    cat ${WORKDIR}/csf > ${WORKDIR}/csf_spl
    echo "$_spl_hab_block" >> ${WORKDIR}/csf_spl

    # Extract offsets from mkimage log file
    eval $(awk '(/csf_off|sld_csf_off/)&&($0=$1"="$2)' ${BOOT_STAGING}/flash_evk.log)
    bbnote "csf_off=${csf_off} sld_csf_off=${sld_csf_off}"

    for SIGNING_ARTIFACT in ${SIGNING_ARTIFACTS}; do
        # Generate CSF binaries
        cst ${S}/${SIGNING_ARTIFACT} ${WORKDIR}/csf_fit
        cst ${S}/${SIGNING_ARTIFACT} ${WORKDIR}/csf_spl

        # Append signature to image offsets to generate signed FIT image
        dd if=${WORKDIR}/csf_spl.bin of=${S}/${SIGNING_ARTIFACT} seek=$(printf "%d" ${csf_off}) bs=1 conv=notrunc
        dd if=${WORKDIR}/csf_fit.bin of=${S}/${SIGNING_ARTIFACT} seek=$(printf "%d" ${sld_csf_off}) bs=1 conv=notrunc
    done
}

do_efuses() {
    SIGN_HAB_TYPE="${SIGN_HAB_TYPE}"

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
    _timeout=60
    if CURL_CA_BUNDLE="${STAGING_DIR_NATIVE}/etc/ssl/certs/ca-certificates.crt" curl --retry 5 --silent --show-error --max-time ${_timeout} "${SIGN_API}/nxp/efuses/${SIGN_NXP_PKI_ID}" -X GET -H "Content-Type: application/json" -H "X-API-Key: ${SIGN_API_KEY}" --output "${RESPONSE_FILE}"; then
        jq -r ".efuses" < "${RESPONSE_FILE}" | base64 -d > "${WORKDIR}/efuses.bin"
    else
        bbfatal "Failed to fetch efuses for ${SIGN_NXP_PKI_ID} with error $?"
    fi
    rm -f "${REQUEST_FILE}" "${RESPONSE_FILE}"

    if [ ! -s "${WORKDIR}/efuses.bin" ]; then
        bbfatal "Unspecified error - empty file"
    fi
    # Generate efuses programming script
    xxd -e -g 4 -c 4 -u "${WORKDIR}/efuses.bin" | awk '{print "0x" $2}' | awk 'BEGIN {BANK=5; ADDR=0;} { BANK+=(ADDR==0); $0="fuse prog "BANK" "ADDR" "$0; ADDR+=1 ; ADDR%=4;}1' > ${WORKDIR}/lock.scr
}

do_efuses[depends] += " \
    coreutils-native:do_populate_sysroot \
    curl-native:do_populate_sysroot \
    jq-native:do_populate_sysroot \
    ca-certificates-native:do_populate_sysroot \
    xxd-native:do_populate_sysroot \
"
do_efuses[network] = "1"

do_efuses[vardeps] += " \
    SIGN_API \
    SIGN_HAB_PKI_ID \
    SIGN_AHAB_PKI_ID \
    SIGN_HAB_TYPE \
"
addtask sign after do_compile before do_install
addtask efuses after do_sign before do_deploy
