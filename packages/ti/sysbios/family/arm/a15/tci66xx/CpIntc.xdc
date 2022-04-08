/*
 * Copyright (c) 2014, Texas Instruments Incorporated
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
 *  ======== CpIntc.xdc ========
 */

package ti.sysbios.family.arm.a15.tci66xx;

import xdc.runtime.Assert;
import xdc.runtime.Error;

/*!
 *  ======== CpIntc ========
 *  Chip-level Interrupt Controller Manager
 *
 *  This module manages the CP_INTC hardware.  This module supports enabling
 *  and disabling of both system and host interrupts.  This module also
 *  supports mapping system interrupts to host interrupts and host interrupts
 *  to Hwis.  These functions are supported statically and during runtime for
 *  CP_INTC connected to the ARM generic interrupt controller.  There is a
 *  dispatch function for handling ARM hardware interrupts triggered by a system
 *  interrupt.  The Global Enable Register is enabled by default in the module
 *  startup function.
 *
 *  System interrupts are those interrupts generated by a hardware module
 *  in the system.  These interrupts are inputs into CP_INTC.
 *  Host interrupts are the output interrupts of CP_INTC.
 *  There is a one-to-one mapping between channels and host interrupts
 *  therefore, the term "host interrupt" is also used for channels.
 *
 *  @p(code)
 *                          +------------+------------+
 *                  ------->|\  Channel  |   Channel  |
 *                          | \ Mapping  |     to     |
 *                  ------->|\ \         |    Host    |
 *                          | \ \        |  Interrupt |
 *                  ------->|\ \ \       |   direct   |    Host
 *                          | \ \ \      |   mapping  | Interrupts
 *                  ------->|\ \ \ \     |            |           +-------+
 *                          | \ \ \ \    |____________|___________|       |
 *     System       ------->|\ \ \ \ \  /|            |           |       |
 *   Interrupts         :   | \ \ \ \ \/ |____________|___________|       |
 *                      :   |  \ \ \ \/\/|            |           |       |
 *                      :   |   \ \ \/\/\|____________|___________|       |
 *                      :   |    \ \/\/\/|            |           |       |
 *                      :   |     \/\/\/\|____________|___________|  ARM  |
 *                      :   |     /\/\/\/|            |           |  GIC  |
 *                      :   |    / /\/\/\|____________|___________|       |
 *                      :   |   / / /\/\/|            |           |       |
 *                      :   |  / / / /\/\|____________|___________|       |
 *                      :   | / / / / /\ |            |           |       |
 *                  ------->|/ / / / /  \|____________|___________|       |
 *                          | / / / /    |            |           |       |
 *                  ------->|/ / / /     |            |           +-------+
 *                          | / / /      |            |
 *                  ------->|/ / /       |            |
 *                          | / /        |            |
 *                  ------->|/ /         |            |
 *                          | /          |            |
 *                  ------->|/           |            |
 *                          +------------+------------+
 *  @p
 *
 *  This modules does not support prioritization, nesting, and vectorization.
 *
 *  An example of using CpIntc during runtime to plug the ISR handler for
 *  System interrupt 15 mapped to Host interrupt 18.
 *
 *  @p(code)
 *
 *  Int intNum;
 *  Hwi_Params params;
 *  Error_Block eb;
 *
 *  // Initialize the error block
 *  Error_init(&eb);
 *
 *  // Map system interrupt 15 to Host interrupt 18
 *  CpIntc_mapSysIntToHostInt(15, 18);
 *
 *  // Plug the function and argument for System interrupt 15 then enable it
 *  CpIntc_dispatchPlug(15, &myEvent15Fxn, 15, TRUE);
 *
 *  // Enable Host interrupt 18
 *  CpIntc_enableHostInt(18);
 *
 *  // Get the ARM Hwi interrupt number associated with Host interrupt 18
 *  intNum = CpIntc_getIntNum(18);
 *
 *  // Initialize the Hwi parameters
 *  Hwi_Params_init(&params);
 *
 *  // The arg must be set to the key returned by CpIntc_getHostIntKey()
 *  params.arg = (UInt)CpIntc_getHostIntKey(18);
 *
 *  // Enable the interrupt vector
 *  params.enableInt = TRUE;
 *
 *  // Create the Hwi on interrupt intNum then specify 'CpIntc_dispatch'
 *  // as the handler function.
 *  Hwi_create(intNum, &CpIntc_dispatch, &params, &eb);
 *
 *  @p
 *
 *  An example of using CpIntc statically to plug the ISR handler for System
 *  interrupt 201 mapped to Host interrupt 90.
 *
 *  *.cfg code
 *  @p(code)
 *  var Hwi = xdc.useModule('ti.sysbios.family.arm.gic.Hwi');
 *  var CpIntc = xdc.useModule('ti.sysbios.family.arm.a15.tci66xx.CpIntc');
 *
 *  // Map System interrupt 201 to Host interrupt 90
 *  CpIntc.sysInts[201].fxn = "&mySysIntFxn";
 *  CpIntc.sysInts[201].arg = 90;
 *  CpIntc.sysInts[201].hostInt = 90;
 *  CpIntc.sysInts[201].enable = true;
 *
 *  var intNum = CpIntc.getIntNumMeta(90);
 *  var params = new Hwi.Params();
 *  params.arg = CpIntc.getHostIntKeyMeta(90);
 *  Hwi.create(intNum, CpIntc.dispatch, params);
 *  @p
 *
 *  @a(NOTE)
 *  If multiple system interrupts are mapped to the same host interrupt, the
 *  performance may deteriorate as the CpIntc_dispatch() function has to
 *  scan all SysInt to HostInt map registers to determine which system
 *  interrupts are mapped to the currently active host interrupt.
 *
 *  @p(html)
 *  <h3> Calling Context </h3>
 *  <table border="1" cellpadding="3">
 *    <colgroup span="1"></colgroup> <colgroup span="5" align="center"></colgroup>
 *
 *    <tr><th> Function                 </th><th>  Hwi   </th><th>  Swi   </th><th>  Task  </th><th>  Main  </th><th>  Startup  </th></tr>
 *    <!--                                                                                                                 -->
 *    <tr><td> {@link #clearSysInt}     </td><td>   Y    </td><td>   Y    </td><td>   Y    </td><td>   Y    </td><td>   Y    </td></tr>
 *    <tr><td> {@link #disableAllHostInts}      </td><td>   Y    </td><td>   Y    </td><td>   Y    </td><td>   Y    </td><td>   Y    </td></tr>
 *    <tr><td> {@link #disableHostInt}  </td><td>   Y    </td><td>   Y    </td><td>   Y    </td><td>   Y    </td><td>   Y    </td></tr>
 *    <tr><td> {@link #dispatch}        </td><td>   Y    </td><td>   N    </td><td>   N    </td><td>   N    </td><td>   N    </td></tr>
 *    <tr><td> {@link #disableHostInt}  </td><td>   Y    </td><td>   Y    </td><td>   Y    </td><td>   Y    </td><td>   Y    </td></tr>
 *    <tr><td> {@link #dispatchPlug}    </td><td>   Y    </td><td>   Y    </td><td>   Y    </td><td>   Y    </td><td>   N    </td></tr>
 *    <tr><td> {@link #enableAllHostInts}       </td><td>   Y    </td><td>   Y    </td><td>   Y    </td><td>   Y    </td><td>   Y    </td></tr>
 *    <tr><td> {@link #enableHostInt}   </td><td>   Y    </td><td>   Y    </td><td>   Y    </td><td>   Y    </td><td>   Y    </td></tr>
 *    <tr><td> {@link #enableSysInt}    </td><td>   Y    </td><td>   Y    </td><td>   Y    </td><td>   Y    </td><td>   Y    </td></tr>
 *    <tr><td> {@link #getHostInt}      </td><td>   Y    </td><td>   Y    </td><td>   Y    </td><td>   Y    </td><td>   N    </td></tr>
 *    <tr><td> {@link #getHostIntKey}      </td><td>   Y    </td><td>   Y    </td><td>   Y    </td><td>   Y    </td><td>   N    </td></tr>
 *    <tr><td> {@link #getIntNum}      </td><td>   Y    </td><td>   Y    </td><td>   Y    </td><td>   Y    </td><td>   N    </td></tr>
 *    <tr><td> {@link #mapSysIntToHostInt}      </td><td>   Y    </td><td>   Y    </td><td>   Y    </td><td>   Y    </td><td>   Y    </td></tr>
 *    <tr><td> {@link #postSysInt}      </td><td>   Y    </td><td>   Y    </td><td>   Y    </td><td>   Y    </td><td>   N    </td></tr>
 *    <tr><td colspan="6"> Definitions: <br />
 *       <ul>
 *         <li> <b>Hwi</b>: API is callable from a Hwi thread. </li>
 *         <li> <b>Swi</b>: API is callable from a Swi thread. </li>
 *         <li> <b>Task</b>: API is callable from a Task thread. </li>
 *         <li> <b>Main</b>: API is callable during any of these phases: </li>
 *           <ul>
 *             <li> In your module startup after this module is started (e.g. CpIntc_Module_startupDone() returns TRUE). </li>
 *             <li> During xdc.runtime.Startup.lastFxns. </li>
 *             <li> During main().</li>
 *             <li> During BIOS.startupFxns.</li>
 *           </ul>
 *         <li> <b>Startup</b>: API is callable during any of these phases:</li>
 *           <ul>
 *             <li> During xdc.runtime.Startup.firstFxns.</li>
 *             <li> In your module startup before this module is started (e.g. CpIntc_Module_startupDone() returns FALSE).</li>
 *           </ul>
 *       </ul>
 *    </td></tr>
 *
 *  </table>
 *  @p
 */

@DirectCall
@ModuleStartup

module CpIntc
{
    /*!
     *  ======== SysIntsView ========
     *  @_nodoc
     */
    metaonly struct SysIntsView {
        UInt         systemInt;
        UInt16       hostInt;
        String       fxn;
        UArg         arg;
        Bool         enabled;
    };

    /*!
     *  ======== rovViewInfo ========
     *  @_nodoc
     */
    @Facet
    metaonly config xdc.rov.ViewInfo.Instance rovViewInfo =
        xdc.rov.ViewInfo.create({
            viewMap: [
                ['SysInts',
                    {
                        type: xdc.rov.ViewInfo.MODULE_DATA,
                        viewInitFxn: 'viewInitSystemInts',
                        structName: 'SysIntsView'
                    }
                ]
            ]
        });

    /*! CpIntc dispatcher function type definition. */
    typedef Void (*FuncPtr)(UArg);

    /*!
     *  Common Platform Interrupt Controller.
     */
    struct RegisterMap {
        UInt32 REV;         /*! 0x00 Revision Register */
        UInt32 CR;          /*! 0x04 Control Register */
        UInt32 RES_08;      /*! 0x08 reserved */
        UInt32 HCR;         /*! 0x0C Host Control Register */
        UInt32 GER;         /*! 0x10 Global Enable Register */
        UInt32 RES_14;      /*! 0x14 reserved */
        UInt32 RES_18;      /*! 0x18 reserved */
        UInt32 GNLR;        /*! 0x1C Global Nesting Level Register */
        UInt32 SISR;        /*! 0x20 Status Index Set Register */
        UInt32 SICR;        /*! 0x24 Status Index Clear Register */
        UInt32 EISR;        /*! 0x28 Enable Index Set Register */
        UInt32 EICR;        /*! 0x2C Enable Index Clear Register */
        UInt32 GWER;        /*! 0x30 Global Wakeup Enable Register */
        UInt32 HIEISR;      /*! 0x34 Host Int Enable Index Set Register */
        UInt32 HIDISR;      /*! 0x38 Host Int Disable Index Set Register */
        UInt32 RES_3C;      /*! 0x3C reserved */
        UInt32 PPR;         /*! 0x40 Pacer Prescale Register */
        UInt32 RES_44;      /*! 0x44 reserved */
        UInt32 RES_48;      /*! 0x48 reserved */
        UInt32 RES_4C;      /*! 0x4C reserved */
        Ptr   *VBR;         /*! 0x50 Vector Base Register */
        UInt32 VSR;         /*! 0x54 Vector Size Register */
        Ptr    VNR;         /*! 0x58 Vector Null Register */
        UInt32 RES_5C[9];   /*! 0x5C-0x7C reserved */
        Int32  GPIR;        /*! 0x80 Global Prioritized Index Register */
        Ptr   *GPVR;        /*! 0x84 Global Prioritized Vector Register */
        UInt32 RES_88;      /*! 0x88 reserved */
        UInt32 RES_8C;      /*! 0x8C reserved */
        UInt32 GSIER;       /*! 0x90 Global Secure Interrupt Enable Register */
        UInt32 SPIR;        /*! 0x94 Secure Prioritized Index Register */
        UInt32 RES_98[26];  /*! 0x98-0xFC reserved */
        UInt32 PPMR[64];    /*! 0x100-0x1FC Pacer Parameter/Map Registers */
        UInt32 SRSR[32];    /*! 0x200-0x27C Status Raw/Set Registers */
        UInt32 SECR[32];    /*! 0x280-0x2FC Status Enabled/Clear Registers */
        UInt32 ESR[32];     /*! 0x300-0x37C Enable Set Registers */
        UInt32 ECR[32];     /*! 0x380-0x3FC Enable Clear Registers */
        UInt8  CMR[1024];   /*! 0x400-0x7FC Channel Map Registers */
        UInt8  HIMR[256];   /*! 0x800-0x8FC Host Interrupt Map Registers */
        UInt32 HIPIR[256];  /*! 0x900-0xCFC Host Interrupt Pri Index
                                Registers */
        UInt32 PR[32];      /*! 0xD00-0xD7C Polarity Registers */
        UInt32 TR[32];      /*! 0xD80-0xDFC Type Registers */
        UInt32 WER[64];     /*! 0xE00-0xEFC Wakeup Enable Registers */
        UInt32 DSR[64];     /*! 0xF00-0xFFC Debug Select Registers */
        UInt32 SER[32];     /*! 0x1000-0x107C Secure Enable Registers */
        UInt32 SDR[32];     /*! 0x1080-0x10FC Secure Disable Registers */
        UInt32 HINLR[256];  /*! 0x1100-0x14FC Host Interrupt Nesting Level
                                Registers */
        UInt32 HIER[8];     /*! 0x1500-0x151F Host Interrupt Enable Registers */
        UInt32 RES1520[56]; /*! 0x1520-0x15FC Reserved */
        Ptr   *HIPVR[256];  /*! 0x1600-0x19FC Host Interrupt Prioritized
                                Vector */
        UInt32 RES1A00[384];/*! 0x1A00-0x1FFC Reserved */
    };

    /*!
     *  System Interrupt Object.
     */
    metaonly struct SysIntObj {
        FuncPtr fxn;            // Handler function for this event
        UArg    arg;            // Function argument
        UInt16  hostInt;        // Host interrupt this event maps to
        Bool    enable;         // Enable the system interrupt ?
    };

    /*!
     *  ======== A_sysIntOutOfRange ========
     *  Assert raised when system interrupt is out of range.
     */
    config Assert.Id A_sysIntOutOfRange = {
        msg: "A_sysIntOutOfRange: Sys Int number passed is invalid."
    };

    /*!
     *  Error raised when an unplugged system interrupt is executed.
     */
    config Error.Id E_unpluggedSysInt = {
        msg: "E_unpluggedSysInt: System Interrupt# %d is unplugged"
    };

    /*!
     *  ======== sysInts ========
     *  Used for configuring the system interrupts.
     *
     *  During static configuration this array can be used to configure
     *  the function to execute when a system interrupt is triggered,
     *  the arg to the function, the host interrupt to which the system
     *  interrupt is mapped too, and whether to enable the system interrupt.
     */
    metaonly config SysIntObj sysInts[];

    /*!
     *  ======== getHostIntKeyMeta ========
     *  Returns a key that should be passed as an argument to CpIntc_dispatch()
     *
     *  If invalid host interrupt number is passed, the value -1 will be
     *  returned.
     *
     *  @param(intNum)  Host interrupt number
     *  @b(returns)     Key
     */
    metaonly Int getHostIntKeyMeta(UInt hostInt);

    /*!
     *  ======== getIntNumMeta ========
     *  Returns the Hwi interrupt number associated with the host
     *  interrupt
     *
     *  If no ARM interrupt is associated with the host interrupt, the value
     *  -1 will be returned.
     *
     *  @param(hostInt)  host interrupt number
     *  @b(returns)      ARM interrupt number
     *
     *  @a(Note)
     *  ARM CorePac interrupt number 0 to N in Keystone2 reference manual
     *  maps to ARM GIC interrupt number 32 to (N + 32).
     *
     *  This function returns the ARM GIC interrupt number.
     */
    metaonly Int getIntNumMeta(UInt hostInt);

    /*!
     *  ======== clearSystInt ========
     *  Clears the system interrupt.
     *
     *  Writes the system interrupt number to the System Interrupt
     *  Status Indexed Clear Register.
     *
     *  @param(sysInt)  system interrupt number
     */
    Void clearSysInt(UInt sysInt);

    /*!
     *  ======== disableAllHostInts ========
     *  Disables all host interrupts.
     *
     *  Writes a 0 to the Global Enable Register.  It does not
     *  override the individual host interrupt enable/disable bits.
     */
    Void disableAllHostInts();

    /*!
     *  ======== disableHostInt ========
     *  Disables the host interrupt.
     *
     *  Writes the host interrupt number to the Host Interrupt
     *  Enable Index Clear Register.
     *
     *  @param(hostInt) host interrupt number
     */
    Void disableHostInt(UInt hostInt);

    /*!
     *  ======== disableSysInt ========
     *  Disables the system interrupt.
     *
     *  Writes the system interrupt number to the System Interrupt
     *  Enable Indexed Clear Register.
     *
     *  @param(sysInt)  system interrupt number
     */
    Void disableSysInt(UInt sysInt);

    /*!
     *  ======== dispatch ========
     *  The Interrupt service routine handler for CP_INTC events.
     *
     *  It is used internally, but can also be used by the user.
     *
     *  @param(hostInt)  host interrupt number
     */
    Void dispatch(UArg hostInt);

    /*!
     *  ======== dispatchPlug ========
     *  Configures a CpIntc ISR dispatch entry.
     *
     *  Plugs the function and argument for the specified system interrupt.
     *  Also enables the system interrupt if 'unmask' is set to 'true'.
     *  Function does not map the system interrupt to a Hwi interrupt.
     *
     *  @param(sysInt)  system interrupt number
     *  @param(fxn)     function
     *  @param(arg)     argument to function
     *  @param(unmask)  bool to unmask interrupt
     */
    Void dispatchPlug(UInt sysInt, FuncPtr fxn, UArg arg, Bool unmask);

    /*!
     *  ======== enableAllHostInts ========
     *  Enables all host interrupts.
     *
     *  Writes a 1 to the Global Enable Register.  It does not
     *  override the individual host interrupt enable/disable bits.
     */
    Void enableAllHostInts();

    /*!
     *  ======== enableHostInt ========
     *  Enables the host interrupt.
     *
     *  Writes the host interrupt number to the Host Interrupt
     *  Enable Indexed Set Register.
     *
     *  @param(hostInt)  host interrupt number
     */
    Void enableHostInt(UInt hostInt);

    /*!
     *  ======== enableSysInt ========
     *  Enables the system interrupt.
     *
     *  Writes the system interrupt number to the System Interrupt
     *  Enable Indexed Set Register.
     *
     *  @param(sysInt)  system interrupt number
     */
    Void enableSysInt(UInt sysInt);

    /*!
     *  ======== getIntNum ========
     *  Returns the Hwi interrupt number associated with the host
     *  interrupt
     *
     *  If no ARM interrupt is associated with the host interrupt, the value
     *  -1 will be returned.
     *
     *  @param(hostInt)  host interrupt number
     *  @b(returns)      ARM interrupt number
     *
     *  @a(Note)
     *  ARM CorePac interrupt number 0 to N in Keystone2 reference manual
     *  maps to ARM GIC interrupt number 32 to (N + 32).
     *
     *  This function returns the ARM GIC interrupt number.
     */
    Int getIntNum(UInt hostInt);

    /*!
     *  ======== getHostInt ========
     *  Returns the host interrupt associated with the ARM CorePac interrupt
     *
     *  If no host interrupt is associated with the ARM interrupt, the value
     *  -1 will be returned.
     *
     *  @param(intNum)  ARM CorePac interrupt number
     *  @b(returns)     Host interrupt number
     */
    Int getHostInt(UInt intNum);

    /*!
     *  ======== getHostIntKey ========
     *  Returns a key that should be passed as an argument to CpIntc_dispatch()
     *
     *  If invalid host interrupt number is passed, the value -1 will be
     *  returned.
     *
     *  @param(intNum)  Host interrupt number
     *  @b(returns)     Key
     */
    Int getHostIntKey(UInt hostInt);

    /*!
     *  ======== mapSysIntToHostInt ========
     *  Maps a system interrupt to a host interrupt.
     *
     *  Writes the Channel Map Register to map a system interrupt to a
     *  channel.  There is a 1 to 1 mapping between channels and
     *  host interrupts.
     *
     *  @param(sysInt)  system interrupt number
     *  @param(hostInt) host interrupt number
     */
    Void mapSysIntToHostInt(UInt sysInt, UInt hostInt);

    /*!
     *  ======== postSysInt ========
     *  Triggers the system interrupt.
     *
     *  Writes the system interrupt number to the System Interrupt
     *  Status Index Set Register. Used for diagnostic and test purposes
     *  only.
     *
     *  @param(sysInt)  system interrupt number
     */
    Void postSysInt(UInt sysInt);

    /*!
     *  @_nodoc
     *  ======== unused ========
     *  Default handler function registered for all unplugged system
     *  interrupts.
     */
    Void unused(UArg arg);

internal:

    /*
     *  Host Interrupt Object.
     */
    struct HostIntObj {
        UInt16  hostInt;        // Host interrupt number this event maps to
        UInt16  sysInt;         // System interrupt number that maps to this
                                // Host interrupt
    };

    /* Base address of the cp_intc controller */
    metaonly config UInt32 baseAddr;

    /* Number of systerm interrupts */
    config UInt32 numSysInts;

    /* Number of ARM CorePac interrupts */
    config UInt32 numArmInts;

    /* Number of system interrupt status registers */
    config Int numStatusRegs;

    /* For mapping statically configured system interrupt to host interrupt */
    config UInt16 sysIntToHostInt[];

    /* For mapping host interrups to ARM CorePac interrupt */
    config UInt16 hostIntToArmIntNum[];

    /* For the ARM interrupt number table */
    config UInt16 intNum[];

    struct DispatchTabElem {
        FuncPtr fxn;            // function to execute
        UArg arg;               // arg for function
    };

    struct Module_State {
        volatile RegisterMap *controller;  // Holds CP_INTC address on device.
        Bits32          initSIER[];        // Initial Sys Int Enable Reg values
        HostIntObj      hostIntToSysInt[]; // Sys Int associated with Host Int.
        DispatchTabElem dispatchTab[];     // Dispatcher Table.
    };
}
