/*
 * Copyright (c) 2017, Texas Instruments Incorporated
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
 *  ======== sys/time.h ========
 */

#ifndef ti_sysbios_posix_sys_time__include
#define ti_sysbios_posix_sys_time__include

#include <stdint.h>
#include <stddef.h>

#include "types.h"


#ifdef __cplusplus
extern "C" {
#endif

#if !defined(__GNUC__) || defined(__ti__)

/*
 *  Include IAR or TI toolchain's time.h for definition of time_t.
 */
#if defined(__IAR_SYSTEMS_ICC__)

#if defined(__430_CORE__) || defined(__430X_CORE__)
#include <../inc/dlib/c/time.h>
#else
#include <../inc/c/time.h>
#endif

#else
#include <../include/time.h>
#endif

struct timeval {
  time_t      tv_sec;
  suseconds_t tv_usec;
};

#else
/* Use GCC toolchain's definition of timeval */
#include <../include/sys/time.h>
#endif

#ifdef __cplusplus
}
#endif

#endif
