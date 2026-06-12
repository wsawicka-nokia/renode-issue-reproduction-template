*** Variables ***
${SCRIPT}                     ${CURDIR}/test.resc

# STM32F4 RTC register addresses (base 0x40002800)
${RTC_DR}                     0x40002804
${RTC_ISR}                    0x4000280C
${RTC_WPR}                    0x40002824

*** Keywords ***
Load Machine
    Execute Script            ${SCRIPT}

Unlock RTC Write Protection
    # Write-protection key sequence: 0xCA followed by 0x53
    Execute Command           sysbus WriteDoubleWord ${RTC_WPR} 0xCA
    Execute Command           sysbus WriteDoubleWord ${RTC_WPR} 0x53

Enter RTC Init Mode
    # Set the INIT bit (bit 7) in the ISR register
    Execute Command           sysbus WriteDoubleWord ${RTC_ISR} 0x80

*** Test Cases ***
Should Set RTC Date To A Day Divisible By Ten
    [Documentation]    Setting the date to 2020-01-10 must not crash the RTC model.
    ...                The model applies the register write field-by-field, so the
    ...                day-of-month units digit is set to 0 first, transiently making
    ...                the day 0. On buggy Renode this throws ArgumentOutOfRangeException
    ...                and fails this test.
    Load Machine
    Unlock RTC Write Protection
    Enter RTC Init Mode

    # DR fields: DU=0, DT=1 (day 10), MU=1 (January), WDU=1 (Monday), YT=2 YU=0 (2020)
    Execute Command           sysbus WriteDoubleWord ${RTC_DR} 0x00202110

    ${date}=    Execute Command    sysbus ReadDoubleWord ${RTC_DR}
    Should Contain            ${date}    0x00202110
