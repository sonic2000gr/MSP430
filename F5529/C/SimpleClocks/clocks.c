/*
 * Simple Clocks 5529 (using crystals)
 * This uses an (inefficient) blinking LED
 * to show the changes in clock frequency
 * (C)2018 Manolis Kiagias
 */

#include <msp430.h>
#define ALL_BITS 0xFF
#define NO_BITS 0x00

void zeroAllPorts(void);

void main(void)
{

    // stop watchdog timer

    WDTCTL = WDTPW | WDTHOLD;

    // reduce power consumption

    zeroAllPorts();

    // configure P1.0 as output

    P1DIR |= BIT0;

    // Connect XT1 to P5.5, P5.4
    // Connect XT2 to P5.3, P5.2

    P5SEL |= BIT4 + BIT5;
    P5SEL |= BIT2 + BIT3;

    // Turn on XT1
    // Turn on XT2

    UCSCTL6 &= ~XT1OFF;
    UCSCTL6 &= ~XT2OFF;

    // Internal load capacitor for XT1

    UCSCTL6 |= XCAP_3;

    // Clear XT2,XT1,DCO fault flags  (XT1 and XT2 only here really)
    // Clear fault flags
    do {
       UCSCTL7 &= ~(XT2OFFG | XT1LFOFFG | DCOFFG);
       SFRIFG1 &= ~OFIFG;
    } while ((SFRIFG1 & OFIFG));  // loop until fault is cleared

    // XT1 is now stable, reduce drive strength
    // XT2 Drive strength reduced to level 0

    UCSCTL6 &= ~XT1DRIVE_3;
    UCSCTL6 &= ~XT2DRIVE_0;

    // UCSCTL4 selects the source for every clock
    // SELA_0 = ACLK source is LF XT1
    // SELS_5 = SMCLK source is HF XT2
    // SELM_5 = MCLK source is HF XT2

    UCSCTL4 |= SELA_0 + SELS_5 + SELM_5;

	while(1)
	{
		P1OUT ^= BIT0;				// toggle P1.0
		__delay_cycles(1000000);    // delay. Leave this value unchanged and switch clock frequencies to see result
	}
}

void zeroAllPorts(void) {
    // Intialize all ports to zero
    // outputs to minimize power consumption

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
