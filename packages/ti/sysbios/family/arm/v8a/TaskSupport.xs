/*
 * Copyright (c) 2016, Texas Instruments Incorporated
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
 *  ======== TaskSupport.xs ========
 */

/*
 * ======== getAsmFiles ========
 * return the array of assembly language files associated
 * with targetName (ie Program.build.target.$name)
 */
function getAsmFiles(targetName)
{
    switch(targetName) {
        case "gnu.targets.arm.A53F":
            return (["TaskSupport_asm_gnu.sv8A"]);
            break;

        default:
            return (null);
            break;
    }
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

    /* set fxntab default */
    this.common$.fxntab = false;

    /* provide getAsmFiles() for Build.getAsmFiles() */
    this.$private.getAsmFiles = getAsmFiles;

    var GetSet = xdc.module("xdc.services.getset.GetSet");
    GetSet.onSet(this, "defaultStackSize", _setDefaultStackSize);
}

/*
 *  ======== _setDefaultStackSize ========
 */
function _setDefaultStackSize()
{
    var TaskSupport = xdc.module('ti.sysbios.family.arm.v8a.TaskSupport');
    var align = TaskSupport.stackAlignment;
    var stackSizeBefore = TaskSupport.defaultStackSize;
    var stackSizeAfter = TaskSupport.defaultStackSize;
    if (align != 0) {
        stackSizeAfter &= (-align);
    }
    if (stackSizeBefore != stackSizeAfter) {
        TaskSupport.$logWarning("TaskSupport.defaultStackSize (" +
            stackSizeBefore + ") was adjusted to " + stackSizeAfter +
            " to guarantee proper stack alignment.", TaskSupport,
            "defaultStackSize");
        TaskSupport.defaultStackSize = stackSizeAfter;
    }
}

/*
 *  ======== stackUsedMeta ========
 */
function stackUsed$view(stackData)
{
    var size = stackData.length;
    var index = 0;
    /*
     * The stack is filled with 0xBE. Because the type is Char, not UChar,
     * ROV reads this value as signed: -66.
     */
    while(stackData[index] == -66) {
        index++;
    }

    return (size - index);
}

/*
 *  ======== getCallStack$view ========
 *  TODO fixme
 */
function getCallStack$view(taskRawView, taskState, threadType)
{
    var Program = xdc.useModule('xdc.rov.Program');
    var Task = xdc.useModule('ti.sysbios.knl.Task');

    var CallStack = xdc.useModule('xdc.rov.CallStack');

    var stackData = Program.fetchArray({type: 'xdc.rov.support.ScalarStructs.S_UInt', isScalar: true}, taskRawView.context, 40, false);
    
    var sp = 0;
    var pc = 0;
    var lr = 0;

    /*
     * PC should be within TaskSupport_swap() but the debugger can't do call stack for
     * assembly coded functions. So, we set the PC to the saved LR.
     */
    switch (Program.build.target.name) {
        case "A53F":
        default:
            var contextStackOffset = 0;   /* only floating point target is supported so there is no "contextStackOffset" */
            break;
    }

    pc = stackData[contextStackOffset + 18];  /* set pc to saved lr */
    sp = Number(taskRawView.context) + 4 * (contextStackOffset + 40);

    CallStack.fetchRegisters(["'Control Registers'.SP_EL0"]);
    var sp_el0 = CallStack.getRegister("'Control Registers'.SP_EL0");
    print(sp_el0);
    
    if (taskState == Task.Mode_RUNNING) {
        switch (threadType) {
            /* The program has called BIOS_exit(), use live registers */
            case "Main":
            /* This is the current thread, use live registers */
            case "Task":
                CallStack.fetchRegisters([
                             "SP", "PC",
                             "X0", "X1", "X2", "X3", "X4", "X5", "X6", "X7",
                             "X8", "X9", "X10", "X11", "X12", "X13", "X14", "X15",
                             "X16", "X17", "X18", "X19", "X20", "X21", "X22", "X23",
                             "X24", "X25", "X26", "X27", "X28", "X29", "X30"]);
                sp = CallStack.getRegister("SP");
                lr = CallStack.getRegister("X30");
                pc = CallStack.getRegister("PC");
                break;

            /*
             * The running task has been pre-empted by a Hwi and/or Swi.
             * Assume its a Hwi.
             */
            case "Hwi":
            case "Swi":
                /* fetch PC, LR, SP from Hwi stack */
                try {
                    var HwiProxy = Program.$modules['ti.sysbios.hal.Hwi'].HwiProxy.$name;
                    var hwiRawView = Program.scanRawView(HwiProxy);
                    pc = hwiRawView.modState.irp;
// To Do: add taskSP array to Hwi module state and have dispatchIRQC initialize it
//                    var taskSP = hwiRawView.modState.taskSP;
                    if (sp_el0 != -1) {
                        var taskSP = sp_el0;
                    }
                    else {
                        var taskSP = sp;
                    }
                    var stackTaskSP = Program.fetchArray({type: 'xdc.rov.support.ScalarStructs.S_UInt', isScalar: true}, taskSP, 512);
                }
                catch (e) {
                    return (e.toString);
                }

                /*
                 * search for saved IRP on task stack
// To Do. Determine this experimentally to be precise.
                 * pc = IRP
                 * sp = &IRP + 172 + 4 words
                 * lr = one word before saved IRP on task stack
                 */
                for (var i = 32; i < 512; i++) {
                    if (stackTaskSP[i] == pc) {
                        sp = taskSP + i*4 + 688 + 16;
                        lr = stackTaskSP[i-1];
                        break;
                    }
                }

                break;
        }
    }
    else {
        CallStack.setRegister("X28", stackData[contextStackOffset + 38]);
        CallStack.setRegister("X27", stackData[contextStackOffset + 36]);
        CallStack.setRegister("X26", stackData[contextStackOffset + 34]);
        CallStack.setRegister("X25", stackData[contextStackOffset + 32]);
        CallStack.setRegister("X24", stackData[contextStackOffset + 30]);
        CallStack.setRegister("X23", stackData[contextStackOffset + 28]);
        CallStack.setRegister("X22", stackData[contextStackOffset + 26]);
        CallStack.setRegister("X21", stackData[contextStackOffset + 24]);
        CallStack.setRegister("X20", stackData[contextStackOffset + 22]);
        CallStack.setRegister("X19", -1);
    }

    CallStack.setRegister("PC", pc);
    CallStack.setRegister("SP", sp);
    CallStack.setRegister("X29", sp);
    CallStack.setRegister("X30", lr);

    var bts = "";

    var enumStrArray = String(taskState).split(".");
    bts += "Task_" + enumStrArray[enumStrArray.length - 1];

    bts += ", PC = 0x" + pc.toString(16);
    bts += ", SP = 0x" + sp.toString(16);
    bts += ", LR = 0x" + lr.toString(16);
    bts += "\n";

    bts += CallStack.toText();
    return (bts);
}
