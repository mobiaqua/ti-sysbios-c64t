/* 
 *  Copyright (c) 2008 Texas Instruments and others.
 *  All rights reserved. This program and the accompanying materials
 *  are made available under the terms of the Eclipse Public License v1.0
 *  which accompanies this distribution, and is available at
 *  http://www.eclipse.org/legal/epl-v10.html
 *
 *  Contributors:
 *      Texas Instruments - initial implementation
 *
 * */
import ti.catalog.msp430.peripherals.adc.ADC10 as ADC10;
import ti.catalog.msp430.peripherals.clock.BCSplus as BCSplus;

/*!
 *  ======== GPIO for MSP430G2x44 ========
 *  MSP430 General Purpose Input Output Ports
 */
metaonly module GPIO_MSP430G2x44 inherits IGPIO {
    /*!
     *  ======== create ========
     *  Create an instance of this peripheral. Use a customized
     *  init function so that we can get access to the ADC10
     *  and BCS+ instances.
     */
    create(ADC10.Instance adc10, BCSplus.Instance clock);

instance:
    /*! @_nodoc */
    config ADC10.Instance adc10;

    /*! @_nodoc */
    config BCSplus.Instance clock;

    /*! Define an array to describe all device pins. The 1st dimension
     *  denotes the port, the second the pin on that port. On an
     *  MSP430G2x44 device, there are 4 x 8 = 32 pins total.
     */

    /* TODO: This here should really be a module-wide feature, rather than an instance feature,
     * however due to limitations in XDCtools 3.21.0.0 the data is located here */
    readonly config DevicePin_t devicePins[4][8];

    /*! Implementation of Device Pin Functional Configuration */
    override config DevicePinFunctionSetting_t devicePinSetting[4][8];

    /*! Determine if each Register needs to be forced set or not */
    readonly config ForceSetDefaultRegister_t forceSetDefaultRegister[] =
    [
        { register : "P1OUT" , regForceSet : true  },
        { register : "P1SEL" , regForceSet : false },
        { register : "P1DIR" , regForceSet : true  },
        { register : "P1REN" , regForceSet : false },
        { register : "P1IES" , regForceSet : true },
        { register : "P1IFG" , regForceSet : true },
        { register : "P1IE"  , regForceSet : false },
        { register : "P2OUT" , regForceSet : true  },
        { register : "P2SEL" , regForceSet : false },
        { register : "P2DIR" , regForceSet : true  },
        { register : "P2REN" , regForceSet : false },
        { register : "P2IES" , regForceSet : true },
        { register : "P2IFG" , regForceSet : true },
        { register : "P2IE"  , regForceSet : false },
        { register : "P3OUT" , regForceSet : true  },
        { register : "P3SEL" , regForceSet : false },
        { register : "P3DIR" , regForceSet : true  },
        { register : "P3REN" , regForceSet : false },
        { register : "P4OUT" , regForceSet : true  },
        { register : "P4SEL" , regForceSet : false },
        { register : "P4DIR" , regForceSet : true  },
        { register : "P4REN" , regForceSet : false }
    ];

    /*
     *  GPIO Digital I/O Registers
     *
     *  One GIPO instance defines the configuration of an entire,
     *  8-bit wide digital I/O port.
     */

    /*! Port 1 Output Register */
    config GpioBits8PxOut_t P1OUT = {
        Bit0        : BIT0_OFF,
        Bit1        : BIT1_OFF,
        Bit2        : BIT2_OFF,
        Bit3        : BIT3_OFF,
        Bit4        : BIT4_OFF,
        Bit5        : BIT5_OFF,
        Bit6        : BIT6_OFF,
        Bit7        : BIT7_OFF
    };

    /*! Port 1 Port Select Register */
    config GpioBits8PxSel_t P1SEL = {
        Bit0        : BIT0_OFF,
        Bit1        : BIT1_OFF,
        Bit2        : BIT2_OFF,
        Bit3        : BIT3_OFF,
        Bit4        : BIT4_OFF,
        Bit5        : BIT5_OFF,
        Bit6        : BIT6_OFF,
        Bit7        : BIT7_OFF
    };

    /*! Port 1 Direction Register */
    config GpioBits8PxDir_t P1DIR = {
        Bit0        : BIT0_OFF,
        Bit1        : BIT1_OFF,
        Bit2        : BIT2_OFF,
        Bit3        : BIT3_OFF,
        Bit4        : BIT4_OFF,
        Bit5        : BIT5_OFF,
        Bit6        : BIT6_OFF,
        Bit7        : BIT7_OFF
    };

    /*! Port 1 Resistor Enable Register */
    config GpioBits8PxRen_t P1REN = {
        Bit0        : BIT0_OFF,
        Bit1        : BIT1_OFF,
        Bit2        : BIT2_OFF,
        Bit3        : BIT3_OFF,
        Bit4        : BIT4_OFF,
        Bit5        : BIT5_OFF,
        Bit6        : BIT6_OFF,
        Bit7        : BIT7_OFF
    };

    /*! Port 2 Output Register */
    config GpioBits8PxOut_t P2OUT = {
        Bit0        : BIT0_OFF,
        Bit1        : BIT1_OFF,
        Bit2        : BIT2_OFF,
        Bit3        : BIT3_OFF,
        Bit4        : BIT4_OFF,
        Bit5        : BIT5_OFF,
        Bit6        : BIT6_OFF,
        Bit7        : BIT7_OFF
    };

    /*! Port 2 Port Select Register */
    config GpioBits8PxSel_t P2SEL = {
        Bit0        : BIT0_OFF,
        Bit1        : BIT1_OFF,
        Bit2        : BIT2_OFF,
        Bit3        : BIT3_OFF,
        Bit4        : BIT4_OFF,
        Bit5        : BIT5_OFF,
        Bit6        : BIT6,         /* POR default for all 2xx devices */
        Bit7        : BIT7          /* POR default for all 2xx devices */
    };

    /*! Port 2 Direction Register */
    config GpioBits8PxDir_t P2DIR = {
        Bit0        : BIT0_OFF,
        Bit1        : BIT1_OFF,
        Bit2        : BIT2_OFF,
        Bit3        : BIT3_OFF,
        Bit4        : BIT4_OFF,
        Bit5        : BIT5_OFF,
        Bit6        : BIT6_OFF,
        Bit7        : BIT7_OFF
    };

    /*! Port 2 Resistor Enable Register */
    config GpioBits8PxRen_t P2REN = {
        Bit0        : BIT0_OFF,
        Bit1        : BIT1_OFF,
        Bit2        : BIT2_OFF,
        Bit3        : BIT3_OFF,
        Bit4        : BIT4_OFF,
        Bit5        : BIT5_OFF,
        Bit6        : BIT6_OFF,
        Bit7        : BIT7_OFF
    };

    /*! Port 3 Output Register */
    config GpioBits8PxOut_t P3OUT = {
        Bit0        : BIT0_OFF,
        Bit1        : BIT1_OFF,
        Bit2        : BIT2_OFF,
        Bit3        : BIT3_OFF,
        Bit4        : BIT4_OFF,
        Bit5        : BIT5_OFF,
        Bit6        : BIT6_OFF,
        Bit7        : BIT7_OFF
    };

    /*! Port 3 Port Select Register */
    config GpioBits8PxSel_t P3SEL = {
        Bit0        : BIT0_OFF,
        Bit1        : BIT1_OFF,
        Bit2        : BIT2_OFF,
        Bit3        : BIT3_OFF,
        Bit4        : BIT4_OFF,
        Bit5        : BIT5_OFF,
        Bit6        : BIT6_OFF,
        Bit7        : BIT7_OFF
    };

    /*! Port 3 Direction Register */
    config GpioBits8PxDir_t P3DIR = {
        Bit0        : BIT0_OFF,
        Bit1        : BIT1_OFF,
        Bit2        : BIT2_OFF,
        Bit3        : BIT3_OFF,
        Bit4        : BIT4_OFF,
        Bit5        : BIT5_OFF,
        Bit6        : BIT6_OFF,
        Bit7        : BIT7_OFF
    };

    /*! Port 3 Resistor Enable Register */
    config GpioBits8PxRen_t P3REN = {
        Bit0        : BIT0_OFF,
        Bit1        : BIT1_OFF,
        Bit2        : BIT2_OFF,
        Bit3        : BIT3_OFF,
        Bit4        : BIT4_OFF,
        Bit5        : BIT5_OFF,
        Bit6        : BIT6_OFF,
        Bit7        : BIT7_OFF
    };

    /*! Port 4 Output Register */
    config GpioBits8PxOut_t P4OUT = {
        Bit0        : BIT0_OFF,
        Bit1        : BIT1_OFF,
        Bit2        : BIT2_OFF,
        Bit3        : BIT3_OFF,
        Bit4        : BIT4_OFF,
        Bit5        : BIT5_OFF,
        Bit6        : BIT6_OFF,
        Bit7        : BIT7_OFF
    };

    /*! Port 4 Port Select Register */
    config GpioBits8PxSel_t P4SEL = {
        Bit0        : BIT0_OFF,
        Bit1        : BIT1_OFF,
        Bit2        : BIT2_OFF,
        Bit3        : BIT3_OFF,
        Bit4        : BIT4_OFF,
        Bit5        : BIT5_OFF,
        Bit6        : BIT6_OFF,
        Bit7        : BIT7_OFF
    };

    /*! Port 4 Direction Register */
    config GpioBits8PxDir_t P4DIR = {
        Bit0        : BIT0_OFF,
        Bit1        : BIT1_OFF,
        Bit2        : BIT2_OFF,
        Bit3        : BIT3_OFF,
        Bit4        : BIT4_OFF,
        Bit5        : BIT5_OFF,
        Bit6        : BIT6_OFF,
        Bit7        : BIT7_OFF
    };

    /*! Port 4 Resistor Enable Register */
    config GpioBits8PxRen_t P4REN = {
        Bit0        : BIT0_OFF,
        Bit1        : BIT1_OFF,
        Bit2        : BIT2_OFF,
        Bit3        : BIT3_OFF,
        Bit4        : BIT4_OFF,
        Bit5        : BIT5_OFF,
        Bit6        : BIT6_OFF,
        Bit7        : BIT7_OFF
    };
}
/*
 */

