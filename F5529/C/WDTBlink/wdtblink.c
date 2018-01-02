/*
 * WDT interrupts F5529 no driverlib
 * The Efficient way to flash the LEDs!
 * (C) 2017 - 2018 Manolis Kiagias
 */

#include <msp430.h>
#define ALL_BITS  0xFF
#define NO_BITS  0x00

void flashLed(void);
void zeroAllPorts(void);

void main(void)
{
    /*
     * WDTPW = Watchdog timer password (always needed)
     * WDTCNTCL = Clear counter (automatically reset)
     * WDTTMSEL = Configure as interval timer
     * WDTSSEL_1 = Configure ACLK as source (32 KHz)
     * WDTIS_4 = Interval timer select. WDT clock / 2^15 (1 sec at 32768 Hz)
     */
    WDTCTL = WDTPW + WDTCNTCL + WDTTMSEL + WDTSSEL_1 + WDTIS_4;

    zeroAllPorts();                // Configure all ports as outputs and set to zero
                                   // to reduce power consumption

    P1DIR |= BIT0;                 // configure P1.0 as output (already done by zeroAllPorts really)
    P4DIR |= BIT7;                 // configure P4.7 as output (ditto)
    P1OUT |= BIT0;                 // Light up LED P1.0
    P4OUT &= ~BIT7;                // Turn off LED P4.7
    SFRIE1 |= WDTIE;               // Enable WDT interrupts in the status register
    __bis_SR_register(LPM3_bits + GIE);  // Enter Low Power Mode 3 with interrupts enabled
}

void zeroAllPorts(void) {
    // Intialize all ports to zero
    // outputs to minimize power consumption
    // There are 8 Ports in 5529 although the LaunchPad won't give you pins for all
    P1DIR = ALL_BITS;
    P1OUT = NO_BITS;
    P2DIR = ALL_BITS;
    P2OUT = NO_BITS;
    P3DIR = ALL_BITS;
    P3OUT = NO_BITS;
    P4DIR = ALL_BITS;
    P4OUT = NO_BITS;
    P5DIR = ALL_BITS;
    P5OUT = NO_BITS;
    P6DIR = ALL_BITS;
    P6OUT = NO_BITS;
    P7DIR = ALL_BITS;
    P7OUT = NO_BITS;
    P8DIR = ALL_BITS;
    P8OUT = NO_BITS;
}

#pragma vector = WDT_VECTOR  // Interrupt Service Routine (ISR) for Watchdog Timer
__interrupt void flashLed(void) {
    P1OUT ^= BIT0;       // toggle P1.0
    P4OUT ^= BIT7;       // toggle P4.7
}
