deviceTypesCommon = require '@resin.io/device-types/common'
{ networkOptions, commonImg, instructions } = deviceTypesCommon
 
IOT_GATE_IMX8_FLASH = 'Insert USB STICK. Device will automatically boot from USB'
 
postProvisioningInstructions = [
        instructions.BOARD_SHUTDOWN
        instructions.REMOVE_INSTALL_MEDIA
        instructions.BOARD_REPOWER
]
 
module.exports =
        version: 1
        slug: 'iot-gate-imx8'
        name: 'Compulab IOT-GATE-iMX8'
        arch: 'aarch64'
        state: 'released'
        private: false
 
        stateInstructions:
                postProvisioning: postProvisioningInstructions
 
        instructions: [
                instructions.ETCHER_SD
                instructions.EJECT_SD
                instructions.FLASHER_WARNING
                IOT_GATE_IMX8_FLASH
        ].concat(postProvisioningInstructions)

        gettingStartedLink:
                windows: 'http://docs.resin.io/cl-som-imx8/nodejs/getting-started/#adding-your-first-device'
                osx: 'http://docs.resin.io/cl-som-imx8/getting-started/#adding-your-first-device'
                linux: 'http://docs.resin.io/cl-som-imx8/getting-started/#adding-your-first-device'

        supportsBlink: false

        yocto:
                machine: 'iot-gate-imx8'
                image: 'resin-image-flasher'
                fstype: 'resinos-img'
                version: 'yocto-dunfell'
                deployArtifact: 'resin-image-flasher-iot-gate-imx8.resinos-img'
                compressed: true

        options: [ networkOptions.group ]

        configuration:
                config:
                        partition:
                                primary: 1
                        path: '/config.json'

        initialization: commonImg.initialization
