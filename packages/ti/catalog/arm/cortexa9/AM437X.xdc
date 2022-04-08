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
 *  ======== AM437X.xdc ========
 *
 */

metaonly module AM437X inherits ti.catalog.ICpuDataSheet
{
instance:
    override config string cpuCore           = "v7A9";
    override config string isa               = "v7A9";
    override config string cpuCoreRevision   = "1.0";
    override config int    minProgUnitSize   = 1;
    override config int    minDataUnitSize   = 1;
    override config int    dataWordSize      = 4;

    /*!
     *  ======== memMap ========
     *  The memory map returned be getMemoryMap().
     */
    config xdc.platform.IPlatform.Memory memMap[string]  = [
            [
            "OCMCRAM", {
                            comment:    "On-Chip SRAM",
                            name:       "OCMCRAM",
                            base:       0x40300000,
                            len:        0x00020000,
                            space:      "code/data",
                            access:     "RWX"
                        }
        ],
            [
            "L2SRAM", {
                            comment:    "L2 Cache SRAM",
                            name:       "L2SRAM",
                            base:       0x40500000,
                            len:        0x00040000,
                            space:      "code/data",
                            access:     "RWX"
                        }
        ]
    ];
}
/*
 */

