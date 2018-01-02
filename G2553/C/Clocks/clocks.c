/*
 * Set clocks for G2553 in C
 * Includes (inefficient) LED blinking to test different clock speeds
 * SMCLK is also output in Port 1.4 where a scope or
 * frequency meter may be attached
 * (C) 2018 Manolis Kiagias
 */

#include <msp430.h>				

void main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	   // stop watchdog timer
	P1DIR |= BIT0 + BIT4 + BIT6;   // configure P1.0, 4, 6 as outputs
	P1SEL |= BIT4;                 // configure P1.4 as SMCLK (primary peripheral module function)
	P1SEL2 &= ~BIT4;               // configure P1.4 as SMCLK
    DCOCTL = 0;                    // Start with lowest DCO
    BCSCTL1 = CALBC1_8MHZ;         // Set Range
    DCOCTL = CALDCO_8MHZ;          // Set DCO step + modulation
    BCSCTL2 |= DIVS0;              // Set output P1.4 to SMCLK
    P1OUT |= BIT0;                 // Turn on LED 1.0
    P1OUT &= ~BIT6;                // Turn off LED 1.6
	while(1)
	{
		P1OUT ^= BIT0 + BIT6;		// toggle P1.0, P1.6
		__delay_cycles(1000000);    // delay. Leave this value unchanged and change clock frequencies
	}
}
