/*
 * Copyright (c) 2015, Texas Instruments Incorporated
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
 *  ======== Core.xdc ========
 */

import xdc.runtime.Error;

/*!
 *  ======== Core ========
 *  Core Identification Module.
 *
 *  The Core module is used to define which core within a dual core
 *  "R5" subsystem an application is being built for.
 *
 *  At runtime, a comparison is made between the configured Core.id
 *  and the value of MPIDR (bits 7:0). If they do not agree, an Error
 *  is raised.
 *
 *  Core 0's default vector table placement is at 0x400.
 *
 *  Core 1's default vector table placement is at 0x800.
 */

@ModuleStartup          /* to configure static timers */

module Core inherits ti.sysbios.interfaces.ICore
{
    /*!
     *  Error raised if Core.id does not match the contents
     *  of MPIDR [7:0] register.
     */
    config Error.Id E_mismatchedIds = {
        msg: "E_mismatchedIds: Core_Id: %d does not match hardware core Id: %d"
    };

    override config UInt numCores;

    /*!
     *  R5 Core ID, default is Core 0
     *
     *  Used for making static decisions based on Core ID
     */
    config UInt id = 0;

    @Macro
    override UInt hwiDisable();

    @Macro
    override UInt hwiEnable();

    @Macro
    override Void hwiRestore(UInt key);

internal:

    /*
     *  ======== resetC ========
     */
    Void resetC();
}
