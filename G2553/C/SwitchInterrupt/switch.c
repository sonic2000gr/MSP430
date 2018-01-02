/*
 * Switch interrupt test - G2553
 */

#include <msp430.h>
int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
	P1DIR |= BIT0;              // Set P1.0 as output
	P1OUT |= BIT0;              // Turn P1.0 on
	P1IE |= BIT3;               // Enable interrupt for P1.3
	P1REN |= BIT3;              // Enable pull up resistor for P1.3
	P1IES |= BIT3;              // Select High to Low Edge Interrupt for P1.3
	P1IFG &= ~BIT3;             // Clear the interuupt flag for P1.3
	__bis_SR_register(LPM3_bits + GIE);  // Enter Low Power Mode 3 with Interrupts enabled
	__no_operation();           // Required
	return 0;                   // Will never execute :D
}

#pragma vector = PORT1_VECTOR  // Interrupt Service Routine for PORT1
__interrupt void flashLed(void) {
    P1OUT ^= BIT0;              // toggle led when P1.3 button is pressed
    P1IFG &= ~BIT3;             // Clear the interrupt flag before returning to LPM3
}
