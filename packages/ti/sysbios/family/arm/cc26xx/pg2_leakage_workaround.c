#if ti_sysbios_family_arm_cc26xx_Boot_driverlibVersion == 2

#define ADI_1_SYNTH_VCOLDOCTL1_ATEST_I_EN_M 0x00000040

//*****************************************************************************
//! @file       pg2_leakage_workaround.c
//! @brief      Workarounds for PD leakage in synth on PG2.0
//!
//! Revised     $ $
//! Revision    $ $
//
//  Copyright (C) 2014 Texas Instruments Incorporated - http://www.ti.com/
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions
//  are met:
//
//    Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//
//    Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//
//    Neither the name of Texas Instruments Incorporated nor the names of
//    its contributors may be used to endorse or promote products derived
//    from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
//  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
//  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
//  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
//  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//****************************************************************************/


//*****************************************************************************
//
// Defines for TI internal memory map locations.
// These defines are only necessary for PG2.0 devices
//
//*****************************************************************************
#define TI_RFC_FSCA_BASE        0x40044000  // RF24_FSCA
#define TI_RFC_FSCA_O_ADI1CTRL  0x00000108  // ADI Interface 1 Control
#define TI_RFC_FSCA_O_ADI1CLK   0x0000010C  // ADI Interface 1 Clock
#define TI_RFC_FSCA_O_ADI1ADDWDATA \
                                0x00000114  // ADI Interface 1 Address and

/******************************************************************************
* INCLUDES
*/
#include "inc/hw_types.h"
#include "inc/hw_ints.h"
#include "inc/hw_memmap.h"
#include "inc/hw_prcm.h"
#include "inc/hw_rfc_pwr.h"
#include "inc/hw_rfc_dbell.h"
#include "inc/hw_adi_1_synth.h"
#include "driverlib/interrupt.h"

//#include "mailbox.h"
#define IRQN_MODULES_UNLOCKED       29          ///< As part of the boot process, the CM0 has opened access to RF core modules and memories
#define IRQ_MODULES_UNLOCKED        (1U << IRQN_MODULES_UNLOCKED)



// Workaround to avoid leakage in PD for PG2.0
// Stage 1: enable RF core power (takes about 12 us)
void Pg2LeakageWorkaroundStage1(void) {
    // If RF core is powered, turn it off first. 
    // [May be removed if you are positive RF core is off]
    if((HWREG(PRCM_BASE + PRCM_O_PDSTAT0) & PRCM_PDSTAT0_RFC_ON) ||
       (HWREG(PRCM_BASE + PRCM_O_PDSTAT1) & PRCM_PDSTAT1_RFC_ON))
    {
        HWREG(PRCM_BASE + PRCM_O_PDCTL0RFC) &= ~PRCM_PDCTL0RFC_ON;
        HWREG(PRCM_BASE + PRCM_O_PDCTL1RFC) &= ~PRCM_PDCTL1RFC_ON;
        while((HWREG(PRCM_BASE + PRCM_O_PDSTAT0) & PRCM_PDSTAT0_RFC_ON) ||
              (HWREG(PRCM_BASE + PRCM_O_PDSTAT1) & PRCM_PDSTAT1_RFC_ON));
              
    }
    // Turn on RF core
    HWREG(PRCM_BASE + PRCM_O_PDCTL0RFC) |= PRCM_PDCTL0RFC_ON;
    // Exit to allow other activities to take placee in the 12 us this takes
}




// Workaround to avoid leakage in PD for PG2.0
// Stage 2: enable clocks, let CPE boot and unlock RF core, write registers, turn off radio core 
// (takes about 12 us)
void Pg2LeakageWorkaroundStage2(bool bEnterPowerdown) {
    // Wait until power is on
    while(!((HWREG(PRCM_BASE + PRCM_O_PDSTAT0) & PRCM_PDSTAT0_RFC_ON) ||
            (HWREG(PRCM_BASE + PRCM_O_PDSTAT1) & PRCM_PDSTAT1_RFC_ON)));
    
    // Enable clocks inside RF Core (non-buffered reg write, to make sure)
    HWREG(RFC_PWR_NONBUF_BASE + RFC_PWR_O_PWMCLKEN) = 
        RFC_PWR_PWMCLKEN_RFC_M | RFC_PWR_PWMCLKEN_CPE_M | RFC_PWR_PWMCLKEN_CPERAM_M;

    // Wait util CPE has unlocked the necessary modules (takes about 6 us)
    while ((HWREG(RFC_DBELL_BASE + RFC_DBELL_O_RFCPEIFG) & IRQ_MODULES_UNLOCKED) == 0);

    // Enable clock to RF core and FSCA only
    HWREG(RFC_PWR_NONBUF_BASE + RFC_PWR_O_PWMCLKEN) = 
       RFC_PWR_PWMCLKEN_RFC_M | RFC_PWR_PWMCLKEN_FSCA_M;

    // Sync ANATOP:ADI_1_SYNTH bus and setup for nibble writes
    HWREG(TI_RFC_FSCA_BASE + TI_RFC_FSCA_O_ADI1CLK) = 1;
    HWREG(TI_RFC_FSCA_BASE + TI_RFC_FSCA_O_ADI1CTRL) = 3;

    uint32_t ctl0, ctl1, ctl2;
    if (bEnterPowerdown) {
        // When entering powerdown: VCOLDOCTL0.EN=1, VCOLDOCTL1.ATEST_I_EN=1
        ctl0 = (ADI_1_SYNTH_O_VCOLDOCTL0 << 9) |
               (ADI_1_SYNTH_VCOLDOCTL0_EN_M << 4) |
               (ADI_1_SYNTH_VCOLDOCTL0_EN_M);
        ctl1 = (ADI_1_SYNTH_O_VCOLDOCTL1 << 9) | (1 << 8) |
               (ADI_1_SYNTH_VCOLDOCTL1_ATEST_I_EN_M) |
               (ADI_1_SYNTH_VCOLDOCTL1_ATEST_I_EN_M >> 4);
        ctl2 = (ADI_1_SYNTH_O_SLDOCTL0 << 9) |
               (ADI_1_SYNTH_SLDOCTL0_EN_M << 4) |
               (ADI_1_SYNTH_SLDOCTL0_EN_M);
    } else {
        // When exiting powerdown: VCOLDOCTL1.ATEST_I_EN=0, VCOLDOCTL0.EN=0
        ctl0 = (ADI_1_SYNTH_O_VCOLDOCTL1 << 9) | (1 << 8) |
              (ADI_1_SYNTH_VCOLDOCTL1_ATEST_I_EN_M >> 4);
        ctl1 = (ADI_1_SYNTH_O_VCOLDOCTL0 << 9) |
               (ADI_1_SYNTH_VCOLDOCTL0_EN_M << 4);
        ctl2 = (ADI_1_SYNTH_O_SLDOCTL0 << 9) |
               (ADI_1_SYNTH_SLDOCTL0_EN_M << 4);

   }

    // Perform two masked write son ANATOP:ADI_1_SYNTH bus
    HWREG(TI_RFC_FSCA_BASE + TI_RFC_FSCA_O_ADI1ADDWDATA) = ctl0;    // address, mask, data
    HWREG(TI_RFC_FSCA_BASE + TI_RFC_FSCA_O_ADI1CLK) = 1;            // clock it
    HWREG(TI_RFC_FSCA_BASE + TI_RFC_FSCA_O_ADI1ADDWDATA) = ctl1;    // address, mask, data
    HWREG(TI_RFC_FSCA_BASE + TI_RFC_FSCA_O_ADI1CLK) = 1;            // clock it
    HWREG(TI_RFC_FSCA_BASE + TI_RFC_FSCA_O_ADI1ADDWDATA) = ctl2;    // address, mask, data
    HWREG(TI_RFC_FSCA_BASE + TI_RFC_FSCA_O_ADI1CLK) = 1;            // clock it

    // Disable clocks inside RF Core and power it off
    HWREG(RFC_PWR_NONBUF_BASE + RFC_PWR_O_PWMCLKEN) = 0x0;
    HWREG(PRCM_BASE + PRCM_O_PDCTL0RFC) &= ~PRCM_PDCTL0RFC_ON;

    // Clear any pending interrupts from RF Core
    HWREG(NVIC_UNPEND0) = ((1<<(INT_RF_CPE1-16)) |
                           (1<<(INT_RF_CPE0-16)) |
                           (1<<(INT_RF_HW-16)) |
                           (1<<(INT_RF_CMD_ACK-16)));
}

#endif
