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

/*
 *  ======== GPIO_MSP430G2x01.xs ========
 */

/*
 *  ======== instance$meta$init ========
 */
function instance$meta$init()
{
    /* Call super's initializer */
    this.$module.$super.instance$meta$init.$apply(this, []);
    var caps = xdc.loadCapsule
        ("ti/catalog/msp430/peripherals/gpio/GPIO_MSP430G2x01_pins.xs");
    caps.setPins(this);
}
/*
 */

