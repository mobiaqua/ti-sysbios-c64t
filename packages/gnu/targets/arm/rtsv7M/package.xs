/*
 *  Copyright 2020 by Texas Instruments Incorporated.
 *
 */

/*
 * Copyright (c) 2015-2020 Texas Instruments Incorporated - http://www.ti.com
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
 *  ======== Package.getLibs ========
 */
function getLibs(prog)
{
    var libs = "lib/boot.a" + Program.build.target.suffix;

    if (prog.targetModules().length > 0 && this.Settings.bootOnly == false) {
        libs = "lib/" + this.$name + ".a" + Program.build.target.suffix + ";"
            + libs;
    }
    return (libs);
}

/*
 *  ======== Package.close ========
 */
function close()
{
    if (xdc.om.$name != 'cfg') {
        return;
    }

    if ((Program.build.target.isa == "v6M") ||
        (Program.build.target.isa == "v7M") ||
        (Program.build.target.isa == "v7M4")) {
        if (Program.sectMap[".bootVecs"] === undefined) {
            Program.sectMap[".intvecs (0) : AT(0) { KEEP(*(.bootVecs)) }"] = new Program.SectionSpec();
            Program.sectMap[".intvecs (0) : AT(0) { KEEP(*(.bootVecs)) }"].runSegment = Program.platform.codeMemory;
        }
    }
}
/*

 */

