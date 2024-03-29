/*
 * Copyright (c) 2017-2020, Texas Instruments Incorporated
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

#ifndef ti_sysbios_hal_MemProtect__epilogue__include
#define ti_sysbios_hal_MemProtect__epilogue__include

/* REQ_TAG(SYSBIOS-1014), REQ_TAG(SYSBIOS-1015) */
/* Access Privilege Flags */
#define ti_sysbios_hal_MemProtect_USER_READ         0x00000001U
#define ti_sysbios_hal_MemProtect_USER_WRITE        0x00000002U
#define ti_sysbios_hal_MemProtect_USER_EXEC         0x00000004U

#define ti_sysbios_hal_MemProtect_PRIV_READ         0x00000010U
#define ti_sysbios_hal_MemProtect_PRIV_WRITE        0x00000020U
#define ti_sysbios_hal_MemProtect_PRIV_EXEC         0x00000040U

/* REQ_TAG(SYSBIOS-1016) */
/* Memory Type Flags */
#define ti_sysbios_hal_MemProtect_DEVICE            0x00000100U
#define ti_sysbios_hal_MemProtect_DEVICE_UNBUFFERED 0x00001000U
#define ti_sysbios_hal_MemProtect_NONCACHEABLE      0x00010000U
#define ti_sysbios_hal_MemProtect_WRITEBACK         0x00100000U
#define ti_sysbios_hal_MemProtect_WRITETHROUGH      0x00200000U
#define ti_sysbios_hal_MemProtect_WRITEALLOCATE     0x00400000U
#define ti_sysbios_hal_MemProtect_SHAREABLE         0x01000000U

/* REQ_TAG(SYSBIOS-1011), REQ_TAG(SYSBIOS-1012), REQ_TAG(SYSBIOS-1013) */
typedef struct ti_sysbios_hal_MemProtect_Acl {
    Ptr    baseAddress;
    SizeT  length;
    UInt32 flags;
} ti_sysbios_hal_MemProtect_Acl;

/* Target specific macro and structure definitions */
#if (((defined(__TI_COMPILER_VERSION__) || defined(__ti_version__)) && defined(__ARM_ARCH) && (__ARM_ARCH == 7) && (__ARM_ARCH_PROFILE == 'M') && defined(__ARM_FEATURE_SIMD32)) || \
    (defined(__GNUC__) && (defined(gnu_targets_arm_M4) || defined(gnu_targets_arm_M4F))))

#include <ti/sysbios/family/arm/v7m/MemProtect.h>

extern UInt32 ti_sysbios_hal_MemProtect_parseFlags(UInt32 flags);

#elif (((defined(__TI_COMPILER_VERSION__) || defined(__ti_version__)) && defined(__ARM_ARCH) && (__ARM_ARCH == 7) && (__ARM_ARCH_PROFILE == 'M') && !defined(__ARM_FEATURE_SIMD32)) || \
    (defined(__GNUC__) && (defined(gnu_targets_arm_M3))))

#include <ti/sysbios/family/arm/v7m/keystone3/MemProtect.h>

extern UInt32 ti_sysbios_hal_MemProtect_parseFlags(UInt32 flags);

#elif ((defined(__TI_COMPILER_VERSION__) || defined(__ti_version__)) && defined(__ARM_ARCH) && (__ARM_ARCH == 7) && (__ARM_ARCH_PROFILE == 'R') && defined(__ARM_FEATURE_SIMD32))

#include <ti/sysbios/family/arm/v7r/MemProtect.h>

extern UInt32 ti_sysbios_hal_MemProtect_parseFlags(UInt32 flags);

#elif (defined(__TI_COMPILER_VERSION__) && defined(__C7000__) && (__C7000__ == 1))

#include <ti/sysbios/family/c7x/MemProtect.h>
#include <ti/sysbios/family/c7x/Mmu.h>

extern UInt32 ti_sysbios_hal_MemProtect_parseFlags(UInt32 flags, ti_sysbios_family_c7x_Mmu_MapAttrs *attrs);

#else

typedef Void ti_sysbios_hal_MemProtect_Struct;

#define MemProtect_Struct   ti_sysbios_hal_MemProtect_Struct

extern UInt32 ti_sysbios_hal_MemProtect_parseFlags(UInt32 flags);

#endif

typedef ti_sysbios_hal_MemProtect_Struct *ti_sysbios_hal_MemProtect_Handle;

extern Int ti_sysbios_hal_MemProtect_constructDomain(
    ti_sysbios_hal_MemProtect_Struct *obj,
    struct ti_sysbios_hal_MemProtect_Acl *acl,
    UInt16 aclLength);

extern Int ti_sysbios_hal_MemProtect_destructDomain(
    ti_sysbios_hal_MemProtect_Struct *obj);

/* REQ_TAG(SYSBIOS-571) */
extern Void ti_sysbios_hal_MemProtect_startup(Void);

extern Void ti_sysbios_hal_MemProtect_switch(
    ti_sysbios_hal_MemProtect_Struct *obj);

extern Bool ti_sysbios_hal_MemProtect_isDataInKernelSpace(Ptr obj, SizeT size);

/* module prefix */
#define MemProtect_Acl               ti_sysbios_hal_MemProtect_Acl
#define MemProtect_Handle            ti_sysbios_hal_MemProtect_Handle

/* REQ_TAG(SYSBIOS-1017) */
#define MemProtect_constructDomain   ti_sysbios_hal_MemProtect_constructDomain
/* REQ_TAG(SYSBIOS-1018) */
#define MemProtect_destructDomain    ti_sysbios_hal_MemProtect_destructDomain
#define MemProtect_parseFlags        ti_sysbios_hal_MemProtect_parseFlags
#define MemProtect_startup           ti_sysbios_hal_MemProtect_startup
#define MemProtect_switch            ti_sysbios_hal_MemProtect_switch
#define MemProtect_isDataInKernelSpace  \
    ti_sysbios_hal_MemProtect_isDataInKernelSpace

#define MemProtect_DEVICE            ti_sysbios_hal_MemProtect_DEVICE
#define MemProtect_DEVICE_UNBUFFERED ti_sysbios_hal_MemProtect_DEVICE_UNBUFFERED
#define MemProtect_NONCACHEABLE      ti_sysbios_hal_MemProtect_NONCACHEABLE
#define MemProtect_PRIV_EXEC         ti_sysbios_hal_MemProtect_PRIV_EXEC
#define MemProtect_PRIV_READ         ti_sysbios_hal_MemProtect_PRIV_READ
#define MemProtect_PRIV_WRITE        ti_sysbios_hal_MemProtect_PRIV_WRITE
#define MemProtect_SHAREABLE         ti_sysbios_hal_MemProtect_SHAREABLE
#define MemProtect_USER_EXEC         ti_sysbios_hal_MemProtect_USER_EXEC
#define MemProtect_USER_READ         ti_sysbios_hal_MemProtect_USER_READ
#define MemProtect_USER_WRITE        ti_sysbios_hal_MemProtect_USER_WRITE
#define MemProtect_WRITEALLOCATE     ti_sysbios_hal_MemProtect_WRITEALLOCATE
#define MemProtect_WRITEBACK         ti_sysbios_hal_MemProtect_WRITEBACK
#define MemProtect_WRITETHROUGH      ti_sysbios_hal_MemProtect_WRITETHROUGH

#endif
