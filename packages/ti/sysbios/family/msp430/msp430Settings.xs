/*
 *  ======== msp430Settings.xs ========
 *
 */

var devices = [
    "CC430F5137",
    "CC430F6127",
    "CC430F6137",
    "MSP430BT5190",
    "MSP430F5212",
    "MSP430F5214",
    "MSP430F5217",
    "MSP430F5219",
    "MSP430F5222",
    "MSP430F5224",
    "MSP430F5227",
    "MSP430F5229",
    "MSP430F5310",
    "MSP430F5324",
    "MSP430F5325",
    "MSP430F5326",
    "MSP430F5327",
    "MSP430F5328",
    "MSP430F5329",
    "MSP430F5333",
    "MSP430F5335",
    "MSP430F5336",
    "MSP430F5338",
    "MSP430F5340",
    "MSP430F5341",
    "MSP430F5342",
    "MSP430F5358",
    "MSP430F5359",
    "MSP430F5418",
    "MSP430F5418A",
    "MSP430F5419",
    "MSP430F5419A",
    "MSP430F5435",
    "MSP430F5435A",
    "MSP430F5436",
    "MSP430F5436A",
    "MSP430F5437",
    "MSP430F5437A",
    "MSP430F5438",
    "MSP430F5438A",
    "MSP430F5503",
    "MSP430F5507",
    "MSP430F5510",
    "MSP430F5513",
    "MSP430F5514",
    "MSP430F5515",
    "MSP430F5517",
    "MSP430F5519",
    "MSP430F5521",
    "MSP430F5522",
    "MSP430F5524",
    "MSP430F5525",
    "MSP430F5526",
    "MSP430F5527",
    "MSP430F5528",
    "MSP430F5529",
    "MSP430F5630",
    "MSP430F5631",
    "MSP430F5632",
    "MSP430F5633",
    "MSP430F5634",
    "MSP430F5635",
    "MSP430F5636",
    "MSP430F5637",
    "MSP430F5638",
    "MSP430F5658",
    "MSP430F5659",
    "MSP430F6433",
    "MSP430F6435",
    "MSP430F6436",
    "MSP430F6438",
    "MSP430F6458",
    "MSP430F6459",
    "MSP430F6630",
    "MSP430F6631",
    "MSP430F6632",
    "MSP430F6633",
    "MSP430F6634",
    "MSP430F6635",
    "MSP430F6636",
    "MSP430F6637",
    "MSP430F6638",
    "MSP430F6658",
    "MSP430F6659",
    "MSP430F6723",
    "MSP430F6724",
    "MSP430F6725",
    "MSP430F6726",
    "MSP430F6733",
    "MSP430F6734",
    "MSP430F6735",
    "MSP430F6736",
    "MSP430F6745",
    "MSP430F6746",
    "MSP430F6747",
    "MSP430F6748",
    "MSP430F6749",
    "MSP430F6765",
    "MSP430F6766",
    "MSP430F6767",
    "MSP430F6768",
    "MSP430F6769",
    "MSP430F6775",
    "MSP430F6776",
    "MSP430F6777",
    "MSP430F6778",
    "MSP430F6779",
    "MSP430F67451",
    "MSP430F67461",
    "MSP430F67471",
    "MSP430F67481",
    "MSP430F67491",
    "MSP430F67621",
    "MSP430F67641",
    "MSP430F67651",
    "MSP430F67661",
    "MSP430F67671",
    "MSP430F67681",
    "MSP430F67691",
    "MSP430F67751",
    "MSP430F67761",
    "MSP430F67771",
    "MSP430F67781",
    "MSP430F67791",
    "MSP430FG6425",
    "MSP430FG6426",
    "MSP430FG6625",
    "MSP430FG6626",
    "MSP430FR5847",
    "MSP430FR5848",
    "MSP430FR5849",
    "MSP430FR5857",
    "MSP430FR5858",
    "MSP430FR5859",
    "MSP430FR5867",
    "MSP430FR5868",
    "MSP430FR5869",
    "MSP430FR5947",
    "MSP430FR5948",
    "MSP430FR5949",
    "MSP430FR5957",
    "MSP430FR5958",
    "MSP430FR5959",
    "MSP430FR5967",
    "MSP430FR5968",
    "MSP430FR5969",
];

var settings = {
    device: {}
};

for each (device in devices) {
    settings.device[device] = {
        hwiDelegate : "ti.sysbios.family.msp430.Hwi",
        timerDelegate : "ti.sysbios.family.msp430.Timer",
        timestampDelegate : "ti.sysbios.family.msp430.TimestampProvider",
        taskSupportDelegate : "ti.sysbios.family.msp430.TaskSupport",
        intrinsicsSupportDelegate : "ti.sysbios.family.msp430.IntrinsicsSupport",
        targets : [ "ti.targets.msp430.elf.MSP430X", "ti.targets.msp430.elf.MSP430X_small" ]
    }
}
