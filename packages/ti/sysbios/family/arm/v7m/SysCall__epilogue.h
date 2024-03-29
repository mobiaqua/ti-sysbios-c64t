/*
 * Copyright (c) 2017-2019, Texas Instruments Incorporated
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

#ifndef ti_sysbios_family_arm_v7m_SysCall__epilogue__include
#define ti_sysbios_family_arm_v7m_SysCall__epilogue__include

#ifdef __cplusplus
extern "C" {
#endif

#if defined(xdc_target__isaCompatible_v7M) || defined(xdc_target__isaCompatible_v7M4)

#if defined(__ti__)

/*
 *  ======== SysCall_enterPrivMode ========
 */
#define ti_sysbios_family_arm_v7m_SysCall_enterPrivMode() asm(" svc #0 ");

/*
 *  ======== SysCall_enterUnprivMode ========
 */
#define ti_sysbios_family_arm_v7m_SysCall_enterUnprivMode() asm(" svc #1 ");

/*
 *  ======== SysCall_restorePrivMode ========
 */
#define ti_sysbios_family_arm_v7m_SysCall_restorePrivMode() asm(" svc #2 ");

#elif defined(__GNUC__)

/*
 *  ======== SysCall_enterPrivMode ========
 */
#define ti_sysbios_family_arm_v7m_SysCall_enterPrivMode() __asm__(" svc #0 ");

/*
 *  ======== SysCall_enterUnprivMode ========
 */
#define ti_sysbios_family_arm_v7m_SysCall_enterUnprivMode() __asm__(" svc #1 ");

/*
 *  ======== SysCall_restorePrivMode ========
 */
#define ti_sysbios_family_arm_v7m_SysCall_restorePrivMode() __asm__(" svc #2 ");

#endif /* defined(__ti__) */

#endif /* defined(xdc_target__isaCompatible_v7M) || defined(xdc_target__isaCompatible_v7M4) */

#ifdef __cplusplus
}
#endif

#endif /* ti_sysbios_family_arm_v7m_SysCall__epilogue__include */
