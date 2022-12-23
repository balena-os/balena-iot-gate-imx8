deviceTypesCommon = require '@resin.io/device-types/common'
{ networkOptions, commonImg, instructions } = deviceTypesCommon

IOT_GATE_IMX8PLUS_FLASH = 'Insert USB STICK. Device will automatically boot from USB'
 
postProvisioningInstructions = [
        instructions.BOARD_SHUTDOWN
        instructions.REMOVE_INSTALL_MEDIA
        instructions.BOARD_REPOWER
]
 
module.exports =
        version: 1
        slug: 'iot-gate-imx8plus'
        name: 'Compulab IOT-GATE-iMX8PLUS'
        arch: 'aarch64'
        state: 'released'
 
        stateInstructions:
                postProvisioning: postProvisioningInstructions
 
        instructions: [
                instructions.ETCHER_USB
                instructions.EJECT_USB
                instructions.FLASHER_WARNING
                IOT_GATE_IMX8PLUS_FLASH
        ].concat(postProvisioningInstructions)

        gettingStartedLink:
                windows: 'http://docs.balena.io/iot-gate-imx8plus/nodejs/getting-started/#adding-your-first-device'
                osx: 'http://docs.balena.io/iot-gate-imx8plus/getting-started/#adding-your-first-device'
                linux: 'http://docs.balena.io/iot-gate-imx8plus/getting-started/#adding-your-first-device'

        supportsBlink: false

        yocto:
                machine: 'iot-gate-imx8plus'
                image: 'balena-image-flasher'
                fstype: 'balenaos-img'
                version: 'yocto-dunfell'
                deployArtifact: 'balena-image-flasher-iot-gate-imx8plus.balenaos-img'
                compressed: true

        options: [ networkOptions.group ]

        configuration:
                config:
                        partition:
                                primary: 1
                        path: '/config.json'

        initialization: commonImg.initialization
