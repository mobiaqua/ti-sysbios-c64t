/*
 * Copyright (c) 2016, Texas Instruments Incorporated
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
 *  ======== IAM335x.xdc ========
 *
 */

/*!
 *  ======== IAM335x ========
 *  An interface implemented by all TI8168 devices
 *
 *  This interface is defined to factor common data about all TI8168 type devices
 *  into a single place; they all have the same internal memory.
 */
metaonly interface IAM335X inherits ti.catalog.ICpuDataSheet
{
instance:
    config ti.catalog.peripherals.hdvicp2.HDVICP2.Instance hdvicp0;
    config ti.catalog.peripherals.hdvicp2.HDVICP2.Instance hdvicp1;
    config ti.catalog.peripherals.hdvicp2.HDVICP2.Instance hdvicp2;

    override config string cpuCore           = "v7A";
    override config string isa               = "v7A";
    override config string cpuCoreRevision   = "1.0";
    override config int    minProgUnitSize   = 1;
    override config int    minDataUnitSize   = 1;
    override config int    dataWordSize      = 4;

    /*!
     *  ======== memMap ========
     *  The memory map returned be getMemoryMap().
     */
    config xdc.platform.IPlatform.Memory memMap[string]  = [
        ["SRAM_LO", {
            comment:    "Secure SRAM locked",
            name:       "SRAM_LO",
            base:       0x402F0000,
            len:        0x00000400,
            space:      "code/data",
            access:     "RWX"
        }],

        ["SRAM_HI", {
            comment:    "Secure SRAM open",
            name:       "SRAM_HI",
            base:       0x402F0400,
            len:        0x0000FC00,
            space:      "code/data",
            access:     "RWX"
        }],

        /*
         * OCMC (On-chip RAM)
         * Size is 64K
         */
        ["OCMC", {
            name:       "OCMC_SRAM",
            base:       0x40300000,
            len:        0x00010000,
            space:      "code/data",
            access:     "RWX"
        }],
    ];
}
