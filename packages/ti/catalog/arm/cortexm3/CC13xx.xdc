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

/*!
 *  ======== CC13xx.xdc ========
 *  Generic CC13xx Cpu definition
 *
 *  This definition represents all CC13xx devices.
 */

metaonly module CC13xx inherits ti.catalog.ICpuDataSheet
{
instance:
    override config string   cpuCore        = "CM3";
    override config string   isa            = "v7M";
    override config string cpuCoreRevision   = "1.0";
    override config int    minProgUnitSize   = 1;
    override config int    minDataUnitSize   = 1;
    override config int    dataWordSize      = 4;
}
/*
 */

