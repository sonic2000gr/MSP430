;-------------------------------------------------------------------------------
; MSP430F5529 Timer A in Assembly. Includes also Watchdog interrupt
; (C) 2015 - 2018 Manolis Kiagias
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file

;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section
            .retainrefs                     ; Additionally retain any sections
                                            ; that have references to current
                                            ; section
			.global RESET
;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END, SP        ; Initialize stackpointer
			mov.w   #WDT_ADLY_1000, &WDTCTL ; WDT 1000ms, ACLK, interval timer

;-------------------------------------------------------------------------------
                                            ; Main loop here
;-------------------------------------------------------------------------------
			bis.w #BIT2+BIT3, &P1DIR		; Make P1.2 P1.3 outputs
			bis.w #BIT2+BIT3, &P1SEL		; Select peripheral function
			bis.w #BIT0, &P1DIR				; Make P1.0 output

			mov.w #511, &TA0CCR0
	        mov.w #OUTMOD_7, &TA0CCTL1
			mov.w #256, &TA0CCR1
			mov.w #OUTMOD_7, &TA0CCTL2
			mov.w #256, &TA0CCR2
			mov.w #TASSEL_2 + MC_1 + TACLR + TAIE, &TA0CTL
			nop
			bis.w   #WDTIE, &SFRIE1          ; Enable WDT interrupt
			bis.w   #LPM3 + GIE, SR
			nop

;-------------------------------------------------------------------------------
; 											  Interrupt Service Routines
;-------------------------------------------------------------------------------
WDT_ISR		xor.b #BIT0, &P1OUT				; Blink led once per second
			reti

TA0_ISR		nop								; CCR0 value reached
			reti

TA0_IV		nop								; Timer overflow, blink led and clear interrupt
			mov.w #0, &TA0IV
			reti


;-------------------------------------------------------------------------------
;           Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect 	.stack

;-------------------------------------------------------------------------------
;           Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            .sect ".int57"
            .short WDT_ISR
            .sect ".int53"
            .short TA0_ISR
            .sect ".int52"
            .short TA0_IV
