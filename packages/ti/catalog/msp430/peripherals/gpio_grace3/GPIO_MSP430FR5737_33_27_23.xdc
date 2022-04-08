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
import ti.catalog.msp430.peripherals.clock.CS as CS;

/*!
 *  ======== GPIO for MSP430FR5737_33_27_23 ========
 *  MSP430 General Purpose Input Output Ports
 */
metaonly module GPIO_MSP430FR5737_33_27_23 inherits IGPIO {
    /*!
     *  ======== create ========
     *  Create an instance of this peripheral. Use a customized
     *  init function so that we can get access to the CS
     *  instances.
     */
    create(CS.Instance clock);

instance:
    /*! @_nodoc */
    config CS.Instance clock;
    
    config Int numPortInterrupts = 4;
}
/*
 */

