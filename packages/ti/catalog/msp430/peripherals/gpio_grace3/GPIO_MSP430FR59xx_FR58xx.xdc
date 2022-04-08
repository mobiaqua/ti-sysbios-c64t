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
import ti.catalog.msp430.peripherals.clock.CS_A as CS_A;

/*!
 *  ======== GPIO for MSP430FR59xx_FR58xx ========
 *  MSP430 General Purpose Input Output Ports
 */
metaonly module GPIO_MSP430FR59xx_FR58xx inherits IGPIO {
    /*!
     *  ======== create ========
     *  Create an instance of this peripheral. Use a customized
     *  init function so that we can get access to the CS_A
     *  instances.
     */
    create(CS_A.Instance clock);

instance:
    /*! @_nodoc */
    config CS_A.Instance clock;

    config Int numPortInterrupts = 4;    
}
/*
 */

