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
 *  ======== genTimerHtml.xs ========
 *
 *  This script is used to generate the html code for the Timer mapping tables
 *  found in the Timer module's cdoc.
 *
 */

/*
 *  ======== createTable ========
 *  Create a HTML table that has the timer ID mappings for each device
 *  in DeviceTable
 *
 *  The result of this code is actually a JS script, which is called from within
 *  the cdoc comments of Timer.xdc (search for html code: <script ... /script>)
 */
function createTable(deviceTable, fileBase)
{
    // create a hash to track duplicates.  There are dups between C6000 and ARM.
    // e.g. OMAPL137 has a timer entry for both arm and c6000.  However, the timer
    // addrs are the same for these, so don't generate a table for OMAPL137 twice.
    var dupTracker = new Array();

    var scriptStart = "\nvar m_count = 0;\nm_items = new Array(\n";

    // these variables will contain the html code to generate
    var tableStart = "";
    var tableRows  = "";
    var tableEnd   = "";

    // create the output file.
    // We will generate the contents of this javascript script
    var outputFile =
         java.io.File(fileBase + "/doc-files/TimerTables.js");

    /* Delete the HTML file first if it exists. */
    if (outputFile.exists()) {
        outputFile["delete"]();
    }

    var fos = java.io.FileWriter(outputFile);

    // insert the beginning of the script
    fos.write(scriptStart);

    //
    // cycle thru the entire deviceArray from Timer.xs.  Goal is to grab all
    // mappings of timer id to actual timer name and address, then use these
    // values to generate the html tables.
    //

    //for each catalog (e.g. arm.nda)
    for (var catalog in deviceTable) {

        // skip all NDA catalogs
        if (catalog == "ti.catalog.c7000" ||
            catalog == "ti.catalog.arm.cortexa53") {
            continue;
        }

        // print out the catalog
        var catalogStart = "\"<h3>" + catalog + "</h3>\",\n";
        fos.write(catalogStart);

        // for each device in catalog
        var sortedDeviceArray = new Array();
        for (var device in deviceTable[catalog]) {
            // create sorted array of device names
            sortedDeviceArray.push(device);
        }
        // sort it!
        sortedDeviceArray.sort();

        for (var y = 0; y < sortedDeviceArray.length; y++) {
            var device = sortedDeviceArray[y];

            var numCores = 0;
            for (var coreId in deviceTable[catalog][device]) {
                numCores++;
            }
            for (var coreId in deviceTable[catalog][device]) {
                var deviceTitle;
                if (numCores > 1) {
                    deviceTitle = device + " " + coreId;
                }
                else {
                    deviceTitle = device;
                }

                // This is the beginning of the HTML table. Write this out *once*
                // for each device
                var tableStart =
                  "\"<h5>" + deviceTitle + "</h5>\",\n" +
                  "\"<table border=1 cellpadding=3>\",\n" +
                  " \"<colgroup span=1></colgroup> <colgroup span=5 align=center></colgroup>\",\n" +
                  "   \"<tr><th> Timer ID </th><th> Timer Interrupt Number </th></tr>\",\n";
                fos.write(tableStart);

                // get the current device's timer interrupt array
                var timerIntArray = deviceTable[catalog][device][coreId].timerIntNums;

                for (var i = 0; i < timerIntArray.length; i++) {
                    // write out a row for each timer in the device, substituting
                    // values from the timer array into the html table
                    tableRows += "   \"<tr><td> " + i +
                        "        </td><td> " +
                        timerIntArray[i] +
                        "         </td></tr>\",\n";
                }

                // write out all of the rows we just generated for this device
                fos.write(tableRows);

                // reset the rows for the next device
                tableRows = "";

                // This is the end of the HTML table. Write this out *once* for each
                // device
                var tableEnd = " \"</table>\",\n";
                // write out this device's table to the script file
                fos.write(tableEnd);

                // now we're done with this device's table, loop on to the next
                // device
            }

        } // for (var device in deviceTable) ...
    }

    // write out the closing code of the script
    // insert comment as last array elem (in order to ensure last elem does not
    // have a "," as this causes the script to fail)
    var scriptEnd =
      "\"<!-- -->\"\n" +
      ");\n\n// gen below code only 1 time\nwhile (m_count < m_items.length) {\n\ \ \ \ document.write(m_items[m_count]);\n\ \ \ \ m_count++;\n}";
    fos.write(scriptEnd);

    // close the file, the script is complete
    fos.close();
}

/* ======== MAIN ======== */

/* This is the entry point into the benchmarks */

/* Get the canonical path */
var path = arguments[0];
path = String(java.io.File(path).getCanonicalPath());

/* this flag is needed in order to access Timer.xs deviceTable */
var genCdoc = true;

/*
 * This variable must be defined or else the processing of Timer.xs will fail.
 * Since this script is run prior to the "real processing of Timer.xs (during
 * which 'Program' will be defined by XDC), it should be ok to assign a dummy
 * value to 'Program.cpu.clockRate' here.
 */
var Program     = {};
var cpu = {};
var clockRate = 0;
cpu.clockRate = clockRate;
Program.cpu = cpu;

// load the Timer.xs file.  All of the timer mapping info comes from the
// deviceTable structure that's defined in this file:
var TimerXs = xdc.loadCapsule(path + "/Timer.xs");

// generate the HTML and javascript code based on timer values in deviceTable
createTable(TimerXs.deviceTable, path);
