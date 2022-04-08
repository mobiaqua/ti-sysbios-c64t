/*----------------------------------------------------------------------------*/
/* RM57D843ZWTT.cmd                                                           */
/*                                                                            */
/* (c) Texas Instruments 2015, All rights reserved.                           */
/*                                                                            */

/* USER CODE BEGIN (0) */
/* USER CODE END */


/*----------------------------------------------------------------------------*/
/* Linker Settings                                                            */
--retain="*(.intvecs)"

/*----------------------------------------------------------------------------*/
/* Memory Map                                                                 */
MEMORY{
    VECTORS (X)  : origin=0x00000000 length=0x00000040 fill=0xFFFFFFFF
    FLASH0  (RX) : origin=0x00000040 length=0x001FFFC0 vfill=0xFFFFFFFF
    FLASH1  (RX) : origin=0x00200000 length=0x00200000 vfill=0xFFFFFFFF
    STACKS  (RW) : origin=0x08000000 length=0x00001300
    RAM     (RW) : origin=0x08001300 length=0x0007ED00

    ECC_VEC  (R) : origin=0xF0400000 length=0x00000008 ECC={input_range=VECTORS}
    ECC_FLA0 (R) : origin=0xF0400008 length=0x0003FFF8 ECC={input_range=FLASH0}
    ECC_FLA1 (R) : origin=0xF0440000 length=0x00040000 ECC={input_range=FLASH1}
}

/*----------------------------------------------------------------------------*/
/* Section Configuration                                                      */
SECTIONS{
    .intvecs          : {} > VECTORS
    .text    align(8) : {} > FLASH0 | FLASH1
    .const   align(8) : {} > FLASH0 | FLASH1
    .cinit   align(8) : {} > FLASH0 | FLASH1
    .pinit   align(8) : {} > FLASH0 | FLASH1
    .bss              : {} > RAM
    .data             : {} > RAM
    .sysmem           : {} > RAM
    .args             : {} > RAM
    .stack            : {} > STACKS
}
/*----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*/
/* Misc                                                                       */
ECC{
    algo_name : address_mask = 0xFFFFFFF8
    hamming_mask = R4
    parity_mask = 0x0C
    mirroring = F021
}
/*----------------------------------------------------------------------------*/
