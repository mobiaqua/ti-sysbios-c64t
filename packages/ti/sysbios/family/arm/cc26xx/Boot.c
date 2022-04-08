/*
 * Copyright (c) 2014, Texas Instruments Incorporated
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * *  Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * *  Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * *  Neither the name of Texas Instruments Incorporated nor the names of
 *    its contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQueueNTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
/*
 *  ======== Boot.c ========
 */

#include <inc/hw_types.h>
#include <inc/hw_memmap.h>
#include <inc/hw_aon_ioc.h>
#include <inc/hw_aon_sysctl.h>
#include <driverlib/sys_ctrl.h>
#include <driverlib/gpio.h>
#include <driverlib/prcm.h>
#include <driverlib/osc.h>
#include <driverlib/ioc.h>

#include "package/internal/Boot.xdc.h"

#if defined(__IAR_SYSTEMS_ICC__)
#include <intrinsics.h>   /* for IAR */
#endif

#define REG(x) (*((volatile unsigned *)(x)))
#define USER_ID 0x50001294
#define PKG     0x00070000

extern volatile unsigned ti_sysbios_family_arm_cc26xx_Boot_backdoorActivated;

void Boot_trimDevice(void);
extern void trimDevice(void);

/*
 *  ======== ti_sysbios_family_arm_cc26xx_Boot_trimDevice ========
 */
void ti_sysbios_family_arm_cc26xx_Boot_trimDevice(void)
{
    trimDevice();
}

/*
 *  ======== ti_sysbios_family_arm_cc26xx_Boot_checkBackdoor ========
 */
void ti_sysbios_family_arm_cc26xx_Boot_checkBackdoor(void)
{
    unsigned savedIoConfig;
    unsigned savedDirection;
    unsigned pkg;
    unsigned gpio_id;

    if (Boot_overrideDefaultBackdoorIOID == FALSE) {
        pkg = REG(USER_ID) & PKG;
        if (pkg == 0x00020000) {        /* 7x7 */
            gpio_id = IOID_11;
        }
        else if (pkg == 0x00010000) {   /* 5x5 */
            gpio_id = IOID_9;
        }
        else if (pkg == 0x00000000) {   /* 4x4 */
            gpio_id = IOID_7;
        }
    }
    else {
        gpio_id = Boot_alternateBackdoorIOID;
    }

    /* power PERIPH domain */
    PRCMPowerDomainOn(PRCM_DOMAIN_PERIPH);
    while(PRCMPowerDomainStatus(PRCM_DOMAIN_PERIPH) != PRCM_DOMAIN_POWER_ON){};

    /* enable GPIO clock */
    PRCMPeripheralRunEnable(PRCM_PERIPH_GPIO);
    PRCMLoadSet();
    while(!PRCMLoadGet()){};

    /* save GPIO configuration */
    savedIoConfig = IOCPortConfigureGet(gpio_id);
    savedDirection = GPIODirModeGet(1 << gpio_id);

    /* setup GPIO to check if "SELECT" key is held... */
    GPIODirModeSet(1 << gpio_id, GPIO_DIR_MODE_IN);
    IOCPortConfigureSet(gpio_id, IOC_PORT_GPIO,
        (IOC_STD_INPUT & ~(IOC_NO_IOPULL | IOC_BOTH_EDGES)) | IOC_IOPULL_UP);

    CPUdelay(16);

    /* if "SELECT" held, set flag and spin */
    if(!GPIOPinRead(1 << gpio_id)) {
        ti_sysbios_family_arm_cc26xx_Boot_backdoorActivated = 0xdead;
        while(1){};
    }

    /* restore the GPIO configuration */
    GPIODirModeSet(1 << gpio_id, savedDirection);
    IOCPortConfigureSet(gpio_id, IOC_PORT_GPIO, savedIoConfig);

    /* disable the GPIO clock */
    PRCMPeripheralRunDisable(PRCM_PERIPH_GPIO);
    PRCMLoadSet();
    while(!PRCMLoadGet()){};

    /* power off PERIPH domain */
    PRCMPowerDomainOff(PRCM_DOMAIN_PERIPH);
    while(PRCMPowerDomainStatus(PRCM_DOMAIN_PERIPH) != PRCM_DOMAIN_POWER_OFF){};
}

/*
 *  ======== Boot_getBootReason ========
 */
UInt32 Boot_getBootReason()
{
    return (SysCtrlResetSourceGet());
}
