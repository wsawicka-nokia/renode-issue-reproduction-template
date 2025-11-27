*** Variables ***
${SCRIPT}                     ${CURDIR}/test.resc
${UART}                       sysbus.usart2

*** Keywords ***
Load Script
    Execute Script            ${SCRIPT}
    Create Terminal Tester    ${UART}

*** Test Cases ***
Should Run Test Case
    Load Script
    Start Emulation
    
    Register Failing Uart String    ZEPHYR FATAL ERROR

    Wait For Line On Uart       *** Booting Zephyr OS build 076b625f2144 ***
    Wait For Line On Uart       Hello World! nucleo_h533re/stm32h533xx
