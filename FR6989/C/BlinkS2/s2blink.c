/* Toggle the 6989 LaunchPad P1.0 LED when
 * the P1.1 switch is pressed. This uses
 * the P1.1 interrupt to clear the flag and temporarily
 * reactivate the CPU
 * (C) 2015 - 2018 Manolis Kiagias
 */

#include <msp430.h>

int main(void)
{
  WDTCTL = WDTPW | WDTHOLD;                 // Stop watchdog timer

  // Configure GPIO

  P1DIR |= BIT0;                            // Set P1.0 as output direction
  P1DIR &= ~BIT1;							// Set P1.1 as input
  P1OUT |= BIT0;                            // Turn P1.0 on
  P1REN |= BIT1;                            // Select pull-up mode for P1.1
  P1IES |= BIT1;                            // P1.1 Hi/Lo edge interrupt (High to Low transition)
  P1IFG &= ~BIT1;                           // Clear P1.1 interrupt flags
  P1IE |= BIT1;                             // P1.1 interrupt enabled

  // Disable the GPIO power-on default high-impedance mode to activate
  // previously configured port settings

  PM5CTL0 &= ~LOCKLPM5;

  while(1)
  {
    __bis_SR_register(LPM4_bits | GIE);     // Enter LPM4 w/interrupt enabled
    __no_operation();                       // For debugger
    P1OUT ^= BIT0;                          // Toggle P1.0
  }
}

// Port 1 interrupt service routine
#if defined(__TI_COMPILER_VERSION__) || defined(__IAR_SYSTEMS_ICC__)
#pragma vector=PORT1_VECTOR
__interrupt void Port_1(void)
#elif defined(__GNUC__)
void __attribute__ ((interrupt(PORT1_VECTOR))) Port_1 (void)
#else
#error Compiler not supported!
#endif
{
  P1IFG &= ~BIT1;							// Clear P1.1 Interrupt flag
  __bic_SR_register_on_exit(LPM4_bits);     // Exit LPM4 on return
}
