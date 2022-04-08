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
 *  ======== Mpu.xs ========
 */

var Mpu = null;
var BIOS = null;
var Cache = null;
var device = null;
var Memory = null;

/*
 * ======== getAsmFiles ========
 * return the array of assembly language files associated
 * with targetName (ie Program.build.target.$name)
 */
function getAsmFiles(targetName)
{
    switch(targetName) {
        case "ti.targets.arm.elf.R5F":
            return (["Mpu_asm.sv7R"]);
            break;

        default:
            return (null);
	    break;
    }
}

if (xdc.om.$name == "cfg" || typeof(genCdoc) != "undefined") {
    var deviceTable = {
        "RM57D8xx": {
            isMemoryMapped  : false,
            numRegions      : 16,
            regionSettings  : [
                {
                    regionId    : 0,
                    baseAddress : 0x00000000,
                    regionSize  : 0x3E, /* Mpu.RegionSize_4G */
                    enable      : true,
                    bufferable  : false,
                    cacheable   : false,
                    shareable   : false,
                    noExecute   : false,
                    accPerm     : 0,    /* No access at PL1 and PL0 */
                    tex         : 1
                },
                {
                    regionId    : 1,
                    baseAddress : 0x00000000,
                    regionSize  : 0x2A, /* Mpu.RegionSize_4M */
                    enable      : true,
                    bufferable  : true,
                    cacheable   : true,
                    shareable   : true,
                    noExecute   : false,
                    accPerm     : 6,    /* R-only access at PL1 and PL0 */
                    tex         : 1
                },
                {
                    regionId    : 2,
                    baseAddress : 0x08000000,
                    regionSize  : 0x22, /* Mpu.RegionSize_256K */
                    enable      : true,
                    bufferable  : true,
                    cacheable   : true,
                    shareable   : false,
                    noExecute   : true,
                    accPerm     : 3,    /* RW access at PL1 and PL0 */
                    tex         : 1
                },
                {
                    regionId    : 3,
                    baseAddress : 0x08040000,
                    regionSize  : 0x22, /* Mpu.RegionSize_256K */
                    enable      : true,
                    bufferable  : true,
                    cacheable   : true,
                    shareable   : false,
                    noExecute   : true,
                    accPerm     : 0,    /* No acces at PL1 and PL0 */
                    tex         : 1
                },
                {
                    regionId    : 4,
                    baseAddress : 0x08040000,
                    regionSize  : 0x22, /* Mpu.RegionSize_256K */
                    enable      : true,
                    bufferable  : false,
                    cacheable   : false,
                    shareable   : true,
                    noExecute   : true,
                    accPerm     : 3,    /* RW access at PL1 and PL0 */
                    tex         : 1
                },
                {
                    regionId    : 5,
                    baseAddress : 0x60000000,
                    regionSize  : 0x36, /* Mpu.RegionSize_256M */
                    enable      : true,
                    bufferable  : false,
                    cacheable   : false,
                    shareable   : true,
                    noExecute   : false,
                    accPerm     : 3,    /* RW access at PL1 and PL0 */
                    tex         : 0
                },
                {
                    regionId    : 6,
                    baseAddress : 0x80000000,
                    regionSize  : 0x38, /* Mpu.RegionSize_512M */
                    enable      : true,
                    bufferable  : false,
                    cacheable   : false,
                    shareable   : false,
                    noExecute   : false,
                    accPerm     : 3,    /* RW access at PL1 and PL0 */
                    tex         : 1
                },
                {
                    regionId    : 7,
                    baseAddress : 0xF0000000,
                    regionSize  : 0x2A, /* Mpu.RegionSize_4M */
                    enable      : true,
                    bufferable  : false,
                    cacheable   : false,
                    shareable   : false,
                    noExecute   : true,
                    accPerm     : 2,    /* RW access at PL1 and R-only at PL0 */
                    tex         : 1
                },
                {
                    regionId    : 8,
                    baseAddress : 0xFB000000,
                    regionSize  : 0x2E, /* Mpu.RegionSize_16M */
                    enable      : true,
                    bufferable  : false,
                    cacheable   : false,
                    shareable   : false,
                    noExecute   : true,
                    accPerm     : 3,    /* RW access at PL1 and PL0 */
                    tex         : 2
                },
                {
                    regionId    : 9,
                    baseAddress : 0xFC000000,
                    regionSize  : 0x2E, /* Mpu.RegionSize_16M */
                    enable      : true,
                    bufferable  : false,
                    cacheable   : false,
                    shareable   : false,
                    noExecute   : true,
                    accPerm     : 2,    /* RW access at PL1 and R-only at PL0 */
                    tex         : 2
                },
                {
                    regionId    : 10,
                    baseAddress : 0xFE000000,
                    regionSize  : 0x2E, /* Mpu.RegionSize_16M */
                    enable      : true,
                    bufferable  : false,
                    cacheable   : false,
                    shareable   : false,
                    noExecute   : true,
                    accPerm     : 3,    /* RW access at PL1 and PL0 */
                    tex         : 2
                },
                {
                    regionId    : 11,
                    baseAddress : 0xFF000000,
                    regionSize  : 0x2E, /* Mpu.RegionSize_16M */
                    enable      : true,
                    bufferable  : false,
                    cacheable   : false,
                    shareable   : false,
                    noExecute   : true,
                    accPerm     : 2,    /* RW access at PL1 and R-only at PL0 */
                    tex         : 2
                },
                {
                    regionId    : 15,
                    baseAddress : 0xFFF80000,
                    regionSize  : 0x24, /* Mpu.RegionSize_512K */
                    enable      : true,
                    bufferable  : false,
                    cacheable   : false,
                    shareable   : false,
                    noExecute   : true,
                    accPerm     : 2,    /* RW access at PL1 and R-only at PL0 */
                    tex         : 2
                },
            ]
        }
    };

    deviceTable["TMS570DC.*"] = deviceTable["RM57D8xx"];
    deviceTable["RM57D8.*"] = deviceTable["RM57D8xx"];
}

/*
 *  ======== deviceSupportCheck ========
 *  Check validity of device
 */
function deviceSupportCheck()
{
    /* look for exact match first */
    for (device in deviceTable) {
        if (device == Program.cpu.deviceName) {
            return (device);
        }
    }

    /* now look for a wildcard match */
    for (device in deviceTable) {
        if (Program.cpu.deviceName.match(device)) {
            return (device);
        }
    }

    return (null);
}

/*
 *  ======== module$meta$init ========
 */
function module$meta$init()
{
    /* Only process during "cfg" phase */
    if (xdc.om.$name != "cfg") {
        return;
    }

    this.$private.getAsmFiles = getAsmFiles;

    Mpu = this;

    /* set fxntab default */
    Mpu.common$.fxntab = false;

    device = deviceSupportCheck();

    if (device != null) {
        Mpu.isMemoryMapped = deviceTable[device].isMemoryMapped;
        Mpu.numRegions = deviceTable[device].numRegions;
        Mpu.regionEntryMeta.length = Mpu.numRegions;
        for (var i = 0; i < Mpu.numRegions; i++) {
            Mpu.regionEntryMeta[i].baseAddress = 0;
            Mpu.regionEntryMeta[i].sizeAndEnable = 0;
            Mpu.regionEntryMeta[i].regionAttrs = 0;
        }

        var attrs = new Mpu.RegionAttrs();
        initRegionAttrsMeta(attrs);
        var regionArray = deviceTable[device].regionSettings;
        for (var i = 0; i < regionArray.length; i++) {
            attrs.enable = regionArray[i].enable;
            attrs.bufferable = regionArray[i].bufferable;
            attrs.cacheable = regionArray[i].cacheable;
            attrs.shareable = regionArray[i].shareable;
            attrs.noExecute = regionArray[i].noExecute;
            attrs.accPerm = regionArray[i].accPerm;
            attrs.tex = regionArray[i].tex;
            setRegionMeta(regionArray[i].regionId, regionArray[i].baseAddress,
                regionArray[i].regionSize, attrs);
        }
    }
    else {
        Mpu.numRegions = 0;
        Mpu.isMemoryMapped = true;
        Mpu.regionEntryMeta.length = 0;
    }
}

/*
 *  ======== module$use ========
 */
function module$use()
{
    BIOS = xdc.module('ti.sysbios.BIOS');
    Memory = xdc.useModule('xdc.runtime.Memory');

    if (Program.build.target.name == "R5F") {
        Cache  = xdc.useModule('ti.sysbios.family.arm.r5.Cache');
    }

    device = deviceSupportCheck();

    if (device == null) {
        /*
         * no match, print all catalog devices supported
         * and then raise an error
         */
        var catalog = xdc.loadPackage(Program.cpu.catalogName);

        /* build associative array of supported devices */
        var supportedDevices = new Object();

        for (var i = 0; i < catalog.$modules.length; i++) {
            catalogName = catalog.$modules[i].$name.substring(
                Program.cpu.catalogName.length + 1);

            for (device in deviceTable) {
                if (catalogName.match(device)) {
                    supportedDevices[catalogName] = catalogName;
                }
            }
        }

        /* copy it into a sortable array */
        var sd = new Array();

        for (var i in supportedDevices) {
            sd[sd.length++] = i;
        }

        /* sort it for a nicer report */
        sd.sort();

        print("The " + Program.cpu.deviceName +
              " device is not currently supported.");
        print("The following devices are supported for the " +
            Program.build.target.name + " target:");

        for (var i=0; i<sd.length; i++) {
            print("\t" + sd[i]);
        }

        throw new Error ("Unsupported device!");
    }
}

/*
 *  ======== module$static$init ========
 */
function module$static$init(mod, params)
{
    if (!Mpu.isMemoryMapped) {
        mod.regionEntry.length = Mpu.numRegions;

        for (var i = 0; i < Mpu.numRegions; i++) {
            mod.regionEntry[i].baseAddress = Mpu.regionEntryMeta[i].baseAddress;
            mod.regionEntry[i].sizeAndEnable = Mpu.regionEntryMeta[i].sizeAndEnable;
            mod.regionEntry[i].regionAttrs = Mpu.regionEntryMeta[i].regionAttrs;
        }
    }
    else {
        mod.regionEntry.length = 0;
    }
}

/*
 *  ======== initRegionAttrsMeta ========
 */
function initRegionAttrsMeta(attrs)
{
    /* Set all fields to their default value */
    attrs.enable = Mpu.defaultAttrs.enable;
    attrs.bufferable = Mpu.defaultAttrs.bufferable;
    attrs.cacheable = Mpu.defaultAttrs.cacheable;
    attrs.shareable = Mpu.defaultAttrs.shareable;
    attrs.noExecute = Mpu.defaultAttrs.noExecute;
    attrs.accPerm = Mpu.defaultAttrs.accPerm;
    attrs.tex = Mpu.defaultAttrs.tex;
}

/*
 *  ======== setiRegionMeta ========
 */
function setRegionMeta(regionId, regionBaseAddr, regionSize, attrs)
{
    var index;

    if (Mpu.numRegions == 0) {
        Mpu.$logError("Mpu_setRegionMeta: Number of MPU regions " +
              "(Mpu.numRegions) is set to 0. The number of regions must be " +
              "non-zero.", Mpu);
    }

    /* Set enable field to default if undefined */
    if (attrs.enable === undefined) {
        attrs.enable = Mpu.defaultAttrs.enable;
    }

    /* Set bufferable field to default if undefined */
    if (attrs.bufferable === undefined) {
        attrs.bufferable = Mpu.defaultAttrs.bufferable;
    }

    /* Set cacheable field to default if undefined */
    if (attrs.cacheable === undefined) {
        attrs.cacheable = Mpu.defaultAttrs.cacheable;
    }

    /* Set shareable field to default if undefined */
    if (attrs.shareable === undefined) {
        attrs.shareable = Mpu.defaultAttrs.shareable;
    }

    /* Set noExecute field to default if undefined */
    if (attrs.noExecute === undefined) {
        attrs.noExecute = Mpu.defaultAttrs.noExecute;
    }

    /* Set accPerm field to default if undefined */
    if (attrs.accPerm === undefined) {
        attrs.accPerm = Mpu.defaultAttrs.accPerm;
    }

    /* Set tex field to default if undefined */
    if (attrs.tex === undefined) {
        attrs.tex = Mpu.defaultAttrs.tex;
    }

    if ((regionId >= 0) && (regionId < Mpu.numRegions)) {
        if (regionBaseAddr & 0x3) {
            Mpu.$logWarning("Region base address not 4-byte aligned", Mpu);
        }

        Mpu.regionEntryMeta[regionId].baseAddress =
            convertToUInt32(regionBaseAddr & 0xFFFFFFFC);

        Mpu.regionEntryMeta[regionId].sizeAndEnable =
            (regionSize | attrs.enable);

        Mpu.regionEntryMeta[regionId].regionAttrs =
            convertToUInt32((attrs.noExecute << 12) | (attrs.accPerm << 8) |
            (attrs.tex << 3) | (attrs.shareable << 2) | (attrs.cacheable << 1) |
            (attrs.bufferable));
    }
    else {
        Mpu.$logError("MPU Region number (" + regionId + ") passed is " +
            "invalid.", Mpu);
    }
}

/*
 *  ======== convertToUInt32 ========
 */
function convertToUInt32(value)
{
    /*
     *  Provide this workaround here due to javascript.
     *  Note: Javascript converts numbers to 32-bit signed numbers before
     *        evaluating bitwise operators.
     */
    if (value < 0) {
        value = value + 0xffffffff + 1;
    }

    return (value);
}

/*
 *  ======== viewLevel1Page ========
 */
function viewLevel1Page(view)
{
}

/*
 *  ======== viewLevel2Page ========
 */
function viewLevel2Page()
{
}
