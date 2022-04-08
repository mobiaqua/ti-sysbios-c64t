/*
 *  Copyright (c) 2016 by Texas Instruments and others.
 *  All rights reserved. This program and the accompanying materials
 *  are made available under the terms of the Eclipse Public License v1.0
 *  which accompanies this distribution, and is available at
 *  http://www.eclipse.org/legal/epl-v10.html
 *
 *  Contributors:
 *      Texas Instruments - initial implementation
 *
 * */

/*
 *  ======== IHimalaya.xdc ========
 *
 */
package ti.catalog.c6000;

/*!
 *  ======== IHimalaya ========
 *  An interface implemented by all Himalaya devices
 *
 *  This interface is defined to factor common data about all Himalaya devices
 *  into a single place; they are all the same from the configuration point of
 *  view.
 */
metaonly interface IHimalaya inherits ti.catalog.ICpuDataSheet
{

    config long cacheSizeL1[string] = [
        ["0k",  0x0000],
        ["4k",  0x1000],
        ["8k",  0x2000],
        ["16k", 0x4000],
        ["32k", 0x8000],
    ];

    config long cacheSizeL2[string] = [
        ["0k",   0x00000],
        ["32k",  0x08000],
        ["64k",  0x10000],
        ["128k", 0x20000],
        ["256k", 0x40000]
    ];

    readonly config ti.catalog.c6000.ICacheInfo.CacheDesc cacheMap[string] =  [
             ['l1PMode',{desc:"L1P Cache",
                         base:0xE00000,
                         map : [["0k",0x0000],
                                ["4k",0x1000],
                                ["8k",0x2000],
                                ["16k",0x4000],
                                ["32k",0x8000]],
                         defaultValue: "32k",
                         memorySection: "L1PSRAM"}],
         
                 ['l1DMode',{desc:"L1D Cache",
                         base:0xF00000,
                         map : [["0k",0x0000],
                                ["4k",0x1000],
                                ["8k",0x2000],
                                ["16k",0x4000],
                                ["32k",0x8000]],
                         defaultValue: "32k",
                         memorySection: "L1DSRAM"}],
                     
             ['l2Mode',{desc:"L2 Cache",
                         base:0x800000,
                         map : [["0k",0x0000],
                                ["32k",0x8000],
                                ["64k",0x10000],
                                ["128k", 0x20000],
                            ["256k", 0x40000]],
                         defaultValue: "0k",
                         memorySection: "IRAM"}], 

    ];  

instance:

    override config string   cpuCore         = "64x+";
    override config string   isa = "64P";
    override config string   cpuCoreRevision = "1.0";

    override config int     minProgUnitSize = 1;
    override config int     minDataUnitSize = 1;    
    override config int     dataWordSize    = 4;

    /*!
     *  ======== memMap ========
     *  The default memory map for this device
     */
    config xdc.platform.IPlatform.Memory memMap[string]  = [
        ["IRAM", {
            comment:    "Internal 2MB UMAP0 memory",
            name:       "IRAM",
            base:       0x800000,
            len:        0x200000,
            space:      "code/data",
            access:     "RWX"
        }],

        ["L1PSRAM", {
            comment:    "Internal 32KB RAM/CACHE L1 program memory",
            name:       "L1PSRAM",
            base:       0xE00000,
            len:        0x008000,
            space:      "code",
            access:     "RWX"
        }],

        ["L1DSRAM", {
            comment:    "Internal 32KB RAM/CACHE L1 data memory",
            name:       "L1DSRAM",
            base:       0xF00000,
            len:        0x008000,
            space:      "data",
            access:     "RW"
        }],

    ];
};
/*
 */

