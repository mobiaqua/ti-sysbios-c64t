/*----------------------------------------------------------------------------*/
/* AR14XX.cmd                                                                 */
/*                                                                            */
/* (c) Texas Instruments 2016, All rights reserved.                           */
/*                                                                            */

/* USER CODE BEGIN (0) */
/* USER CODE END */


/*----------------------------------------------------------------------------*/
/* Linker Settings                                                            */
--retain="*(.intvecs)"

/*----------------------------------------------------------------------------*/
/* Memory Map                                                                 */
MEMORY{
    VECTORS (X)  : origin=0x00000000 length=0x00000100
    FLASH0  (RX) : origin=0x00000100 length=0x00017F00
    FLASH1  (RX) : origin=0x00018000 length=0x00008000
    RAM     (RW) : origin=0x08000000 length=0x00030000
}

/*----------------------------------------------------------------------------*/
/* Section Configuration                                                      */
SECTIONS{
    .intvecs : {} > VECTORS
    .text    : {} > FLASH0 | FLASH1
    .const   : {} > FLASH0 | FLASH1
    .cinit   : {} > FLASH0 | FLASH1
    .pinit   : {} > FLASH0 | FLASH1
    .bss     : {} > RAM
    .data    : {} > RAM
    .stack   : {} > RAM
}
/*----------------------------------------------------------------------------*/
