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
 *  ======== hwi.h ========
 *
 */

#include <ti/bios/include/std.h>
#include <ti/bios/include/swi.h>

#if defined(_64P_)  || defined(_674_) || defined(_66_)
#include <ti/bios/include/hwi_c64p.h>

#elif defined(_64T_)
#include <ti/bios/include/hwi_c64t.h>

#elif defined(_64_)
#include <ti/bios/include/hwi_c64.h>

#elif defined(_67P_)
#include <ti/bios/include/hwi_c67p.h>

#elif defined(_28_)
#include <ti/bios/include/hwi_c28.h>

#else
#error "target not supported by legacy HWI module"
#endif

#ifndef DSPBIOSSUPPORTWARNING
#define DSPBIOSSUPPORTWARNING

#warn The DSP/BIOS compatibility APIs are no longer supported. The ti/bios/include files and library can be used as-is but they will not be supported in this or future releases. We recommend that you use the native SYS/BIOS APIs.

#endif
