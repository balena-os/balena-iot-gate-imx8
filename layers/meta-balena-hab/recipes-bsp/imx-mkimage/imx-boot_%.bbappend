inherit hab

SIGN_ARTIFACT_NAME = "flash.bin"

do_compile:append:iot-gate-imx8() {
    # [AG] if this is needed consider adding as patch to all directories
    #sed -i '/@rm -f u-boot.its $(dtb)$/d' iMX8M/soc.mak
    set -x
    for target in flash_evk print_fit_hab; do
        bbnote "building ${IMX_BOOT_SOC_TARGET} - ${target}"
        make SOC=${IMX_BOOT_SOC_TARGET} dtbs=${UBOOT_DTB_NAME} ${target} 2>&1 | tee ${target}.log
    done
}

do_install:append:iot-gate-imx8() {
    DEST="${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/"
    install -d ${DEST}
    for target in flash_evk print_fit_hab; do
        if [ ${target} = "flash_evk" ]; then
            if [ -e "${BOOT_STAGING}/${SIGN_ARTIFACT_NAME}" ]; then
                cp ${BOOT_STAGING}/${SIGN_ARTIFACT_NAME} ${DEST}/
            fi
        fi
        install "${B}/${target}.log" "${DEST}/"
    done
}

do_sign_hab:mx8m-generic-bsp() {
    DEST="${DEPLOY_DIR_IMAGE}"/"${BOOT_TOOLS}"
    if [ ! -f "${DEST}/flash_evk.log" ] || [ ! -f "${DEST}/print_fit_hab.log" ]; then
        bbfatal "mkimage output files not available in ${DEST} directory"
    fi

    _payload=%%BIN_PATH%%
    # Extract load address, offset and length from mkimage log file
    eval $(awk  -F":" '(/hab block/)&&(gsub(/ /,"_",$1))&&($0=$1"=\""$2"\"")' ${DEST}/flash_evk.log)
    # Append the image binary path
    _spl_hab_block="${_spl_hab_block} \"${_payload}\""
    _sld_hab_block="${_sld_hab_block} \"${_payload}\""

    bbnote "_spl_hab_block=${_spl_hab_block} _sld_hab_block=${_sld_hab_block}"

    # Extract load addresses, offsets and lengths from FIT log file
    blocks=$(awk -v payload=${_payload} '(/^0x/)&&($0=","$0" \""payload"\" \\\n")' ORS=" " ${DEST}/print_fit_hab.log)

    bbnote "blocks=${blocks}"

    prepare_sign_csf

    # Append blocks lines to template
    cat ${WORKDIR}/csf > ${WORKDIR}/csf_fit
    echo "$_sld_hab_block \ " >> ${WORKDIR}/csf_fit
    echo "${blocks}" >> ${WORKDIR}/csf_fit

    cat ${WORKDIR}/csf > ${WORKDIR}/csf_spl
    echo "$_spl_hab_block" >> ${WORKDIR}/csf_spl

    # Generate CSF binaries
    cst ${DEST}/${SIGN_ARTIFACT_NAME} ${WORKDIR}/csf_fit
    cst ${DEST}/${SIGN_ARTIFACT_NAME} ${WORKDIR}/csf_spl

    # Extract offsets from mkimage log file
    eval $(awk '(/csf_off|sld_csf_off/)&&($0=$1"="$2)' ${DEST}/flash_evk.log)
    bbnote "csf_off=${csf_off} sld_csf_off=${sld_csf_off}"

    # Append to image to generate signed image
    install "${DEST}/${SIGN_ARTIFACT_NAME}" "${D}/${SIGN_ARTIFACT_NAME}"
    dd if=${WORKDIR}/csf_spl.bin of=${D}/${SIGN_ARTIFACT_NAME} seek=$(printf "%d" ${csf_off}) bs=1 conv=notrunc
    dd if=${WORKDIR}/csf_fit.bin of=${D}/${SIGN_ARTIFACT_NAME} seek=$(printf "%d" ${sld_csf_off}) bs=1 conv=notrunc
}

do_efuses() {
    set -x
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
    xxd -e -g 4 -c 4 -u "${WORKDIR}/efuses.bin" | awk '{print "0x" $2}' | awk 'BEGIN {BANK=5; ADDR=0;} { BANK+=(ADDR==0); $0="fuse prog "BANK" "ADDR" "$0; ADDR+=1 ; ADDR%=4;}1' > ${D}/lock.scr
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
addtask sign after do_install before do_deploy
addtask efuses after do_sign before do_deploy
