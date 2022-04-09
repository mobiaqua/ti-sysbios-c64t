/*----------------------------------------------------------------------------*/
/* AM64X.cmd                                                                  */
/*                                                                            */
/* (c) Texas Instruments 2019-2020, All rights reserved.                      */
/*                                                                            */

/* USER CODE BEGIN (0) */
/* USER CODE END */

/*----------------------------------------------------------------------------*/
/* Memory Map                                                                 */
MEMORY{
    VECS             : origin=0x00000000 length=0x00000100
    ATCM       (RWX) : origin=0x41000000 length=0x00008000
    BTCM       (RWX) : origin=0x41010000 length=0x00008000
    RAM0       (RW)  : origin=0x70000000 length=0x00200000
}

/*----------------------------------------------------------------------------*/
/* Section Configuration                                                      */
SECTIONS{
    .text    align(8) : {} > ATCM | BTCM | RAM0
    .const   align(8) : {} > ATCM | BTCM | RAM0
    .cinit   align(8) : {} > ATCM | BTCM | RAM0
    .pinit   align(8) : {} > ATCM | BTCM | RAM0
    .init_array align(8): {} > ATCM | BTCM | RAM0
    .bss              : {} > RAM0
    .data             : {} > BTCM | RAM0
    .sysmem           : {} > RAM0
    .args             : {} > RAM0
    .stack            : {} > ATCM | BTCM | RAM0
}
/*----------------------------------------------------------------------------*/
