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
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
/*
 *  ======== Mmu.c ========
 */

#include <xdc/std.h>
#include <string.h>
#include <xdc/runtime/Assert.h>
#include <xdc/runtime/Startup.h>
#include <ti/sysbios/hal/Hwi.h>
#include <ti/sysbios/family/c66/Cache.h>

#include "package/internal/Mmu.xdc.h"

#define DSP_SYSTEM_REGS     0x01D00000
#define DSP_SYS_MMU_CONFIG  (DSP_SYSTEM_REGS + 0x18)
#define DSP_MMU0_BASEADDR   (DSP_SYSTEM_REGS + 0x1000)

#define REG32(X)            (*(volatile UInt32*)(X))

/*
 *  ======== Mmu_Module_startup ========
 */
Int Mmu_Module_startup(Int phase)
{
    if (Mmu_baseAddr) {
        Mmu_module->regs = Mmu_baseAddr;
    }
    else {
        Mmu_module->regs = (Mmu_Regs *)DSP_MMU0_BASEADDR;
    }

    /* disable the MMU */
    Mmu_disable();

    /* zero out the descriptor table entries */
    memset(Mmu_module->tableBuf, 0, 0x4000);

    /*
     *  Initialize the descriptor table based upon static config
     *  This function is generated by the Mmu.xdt file.
     */
    Mmu_initTableBuf(Mmu_module->tableBuf);

    Mmu_init();

    if (Mmu_enableMMU) {
        /* enable the MMU */
        Mmu_enable();
    }

    return (Startup_DONE);
}

/*
 *  ======== Mmu_disable ========
 *  Function to disable the MMU.
 *
 *  Algorithm:
 *   - Disable all caches
 *   - Disable the MMU
 *   - Disable table walking logic
 *   - Flush all TLB entries
 *   - Re-enable all caches that were enabled when we entered this function
 *
 *  Note:
 *   -  No need to flush the TLB. It will be flushed before enabling the MMU.
 *   -  If interrupts are pending when the MMU is disabled, the MMU will
 *      generate an error.
 */
Void Mmu_disable()
{
    UInt        key;
    Cache_Size  restoreSize;
    Cache_Size  disableSize = {
                                Cache_L1Size_0K,
                                Cache_L1Size_0K,
                                Cache_L2Size_0K
                              };

    /* if MMU is alreay disabled, just return */
    if (!(Mmu_isEnabled())) {
        return;
    }

    key = Hwi_disable();

    /* disable all caches */
    Cache_getSize(&restoreSize);
    Cache_setSize(&disableSize);
    Cache_wait();

    /* disable the MMU */
    (Mmu_module->regs)->CNTL &= (~0x2);

    /* disable the table walking logic */
    (Mmu_module->regs)->CNTL &= (~0x4);

    /* flush all unprotected TLB entries */
    (Mmu_module->regs)->GFLUSH |= 0x1;

    /* set cache back to initial settings */
    Cache_setSize(&restoreSize);

    Hwi_restore(key);
}

/*
 *  ======== Mmu_enable ========
 *  Function to enable the MMU.
 *
 *  Algorithm:
 *   - Disable all caches
 *   - Flush all unprotected TLB entries
 *   - Enable table walking logic
 *   - Enable the MMU
 *   - Re-enable the caches that were enabled when we entered this function
 */
Void Mmu_enable()
{
    UInt   key;
    Cache_Size  restoreSize;
    Cache_Size  disableSize = {
                                Cache_L1Size_0K,
                                Cache_L1Size_0K,
                                Cache_L2Size_0K
                              };

    /* if MMU is already enabled then just return */
    if (Mmu_isEnabled()) {
        return;
    }

    key = Hwi_disable();

    /* disable all caches */
    Cache_getSize(&restoreSize);
    Cache_setSize(&disableSize);
    Cache_wait();

    /* flush all unprotected TLB entries */
    (Mmu_module->regs)->GFLUSH |= 0x1;

    /* enable the table walking logic */
    (Mmu_module->regs)->CNTL |= 0x4;

    /* enable the MMU */
    (Mmu_module->regs)->CNTL |= 0x2;

    /* set cache back to initial settings */
    Cache_setSize(&restoreSize);

    Hwi_restore(key);
}

/*
 *  ======== Mmu_init ========
 *
 *  Algorithm:
 *   - Perform a Soft reset on MMU HW
 *   - Wait for reset to complete
 *   - If DSP MMU0, remove it from bypass
 *   - Set translation table base address
 *   - Enable table walking logic
 */
Void Mmu_init()
{
    /* Perform a MMU Software Reset */
    (Mmu_module->regs)->SYSCONFIG |= 0x2;

    /* Wait for reset to complete */
    while (!((Mmu_module->regs)->SYSSTATUS & 0x1));

    /*
     * Enable MMU0 (Remove it from bypass)
     *
     * Note: MMU0 is still disabled as it needs to be locally
     * enabled using the MMU's CNTL register.
     */
    REG32(DSP_SYS_MMU_CONFIG) |= 0x1;

    /* Set translation table base address */
    (Mmu_module->regs)->TTB = (UInt32)Mmu_module->tableBuf;

    /* Enable table walking logic */
    (Mmu_module->regs)->CNTL |= 0x4;
}

/*
 *  ======== Mmu_initDescAttrs ========
 */
Void Mmu_initDescAttrs(Mmu_FirstLevelDescAttrs *attrs)
{
    /* Assert that attrs != NULL */
    Assert_isTrue(attrs != NULL, Mmu_A_nullPointer);

    attrs->type = Mmu_defaultAttrs.type;
    attrs->supersection = Mmu_defaultAttrs.supersection;
}

/*
 *  ======== isEnabled ========
 */
Bool Mmu_isEnabled()
{
    if ((Mmu_module->regs)->CNTL & 0x2) {
        return (TRUE);
    }
    else {
        return (FALSE);
    }
}

/*
 *  ======== Mmu_writeTLBEntry ========
 */
Bool Mmu_writeTLBEntry(Ptr virtualAddr, Ptr physicalAddr, Mmu_PageSize size)
{
    UInt   key, lockBaseVal;
    UInt32 reg;
    Bool   enabled;

    /* Disable interrupts */
    key = Hwi_disable();

    /* determine the current state of the MMU */
    enabled = Mmu_isEnabled();

    /* disable the MMU (if already disabled, does nothing) */
    Mmu_disable();

    /* Read locked entries base value */
    reg = (Mmu_module->regs)->LOCK & (~0x1F0);
    lockBaseVal = (reg >> 10) & 0x1F;
    if (lockBaseVal == 31) {
        if (enabled) {
            /* if MMU was enabled, then re-enable it */
            Mmu_enable();
        }

        /* Restore interrupts */
        Hwi_restore(key);
        return (FALSE);
    }

    /* Write CAM entry */
    (Mmu_module->regs)->CAM = ((UInt32)(virtualAddr) & 0xFFFFF000) |
                              (0x1 << 3) | (0x1 << 2) | (size & 0x3);

    /* Write RAM entry */
    (Mmu_module->regs)->RAM = ((UInt32)(physicalAddr) & 0xFFFFF000);

    /* Select TLB victim entry */
    (Mmu_module->regs)->LOCK = reg | (lockBaseVal << 4);

    /* Load the specified entry in the TLB */
    (Mmu_module->regs)->LD_TLB = 0x1;

    /* Lock the TLB entry */
    (Mmu_module->regs)->LOCK = (lockBaseVal + 1) << 10;

    if (enabled) {
        /* if MMU was enabled, then re-enable it */
        Mmu_enable();
    }

    /* Restore interrupts */
    Hwi_restore(key);

    return (TRUE);
}

/*
 *  ======== Mmu_clearTLBEntry ========
 */
Void Mmu_clearTLBEntry(Ptr virtualAddr)
{
    UInt   key;
    Bool   enabled;

    /* Disable interrupts */
    key = Hwi_disable();

    /* determine the current state of the MMU */
    enabled = Mmu_isEnabled();

    /* disable the MMU (if already disabled, does nothing) */
    Mmu_disable();

    /* Set virtual address of TLB entry to be deleted */
    (Mmu_module->regs)->CAM = (UInt32)virtualAddr & 0xFFFFF000;

    /* Flush the TLB entry */
    (Mmu_module->regs)->FLUSH_ENTRY = 0x1;

    if (enabled) {
        /* if MMU was enabled, then re-enable it */
        Mmu_enable();
    }

    /* Restore interrupts */
    Hwi_restore(key);
}

/*
 *  ======== Mmu_setTLBLockBaseValue ========
 */
Void Mmu_setTLBLockBaseValue(UInt baseValue)
{
    UInt   key;
    UInt32 reg;
    Bool   enabled;

    Assert_isTrue(baseValue <= 31, Mmu_A_baseValueOutOfRange);

    /* Disable interrupts */
    key = Hwi_disable();

    /* determine the current state of the MMU */
    enabled = Mmu_isEnabled();

    /* disable the MMU (if already disabled, does nothing) */
    Mmu_disable();

    /* Update LOCK basevalue */
    reg = (Mmu_module->regs)->LOCK & (~0x7C00);
    (Mmu_module->regs)->LOCK = reg | (baseValue << 10);

    if (enabled) {
        /* if MMU was enabled, then re-enable it */
        Mmu_enable();
    }

    /* Restore interrupts */
    Hwi_restore(key);
}

/*
 *  ======== Mmu_setFirstLevelDesc ========
 */
Void Mmu_setFirstLevelDesc(Ptr virtualAddr, Ptr phyAddr,
                           Mmu_FirstLevelDescAttrs *attrs)
{
    UInt   key;
    UInt32 index = (UInt32)virtualAddr >> 20;
    UInt32 desc = 0;
    Bool   enabled;

    /* Assert that attrs != NULL */
    Assert_isTrue(attrs != NULL, Mmu_A_nullPointer);

    /* Disable interrupts */
    key = Hwi_disable();

    /* determine the current state of the MMU */
    enabled = Mmu_isEnabled();

    /* disable the MMU (if already disabled, does nothing) */
    Mmu_disable();

    /* Determine which kind of descriptor. */
    switch (attrs->type) {
        case Mmu_FirstLevelDesc_PAGE_TABLE:
            /* Page table descriptor */
            desc = (attrs->type & 0x3) |
                   ((UInt32)phyAddr & 0xFFFFFC00);
            break;

        /* Section descriptor */
        case Mmu_FirstLevelDesc_SECTION:
            if (attrs->supersection) {
                desc = (attrs->type & 0x3) |
                       ((attrs->supersection & 0x1) << 18) |
                       ((UInt32)phyAddr & 0xFF000000);
            }
            else {
                desc = (attrs->type & 0x3) |
                       ((UInt32)phyAddr & 0xFFF00000);
            }
            break;

        default:
            Assert_isTrue(FALSE, Mmu_A_unknownDescType);
            break;
    }

    /* set the entry in the first level descriptor table */
    Mmu_module->tableBuf[index] = desc;

    if (enabled) {
        /* if MMU was enabled, then re-enable it */
        Mmu_enable();
    }

    /* Restore interrupts */
    Hwi_restore(key);
}
