;-------------------------------------------------------------------------------
; MSP430 Assembly Blink LED using the Watchdog Timer Interrupt
; for MSP430G2553 (value line launchpad)
; This is the efficient way to blink the LED!
; Default MCLK of 1 MHz used
; (C) 2015-2017 Manolis Kiagias
; Licensed under the BSD License
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
			mov.w   #WDT_ADLY_1000, &WDTCTL ; WDT 1000ms, ACLK, interval timer
											; In this example the WDT interrupt
											; is used to blink LED efficiently
			bis.w   #WDTIE, &IE1            ; Enable WDT interrupt

;-------------------------------------------------------------------------------
;-                                             Initialize outputs
;------------------------------------------------------------------------------
            bis.b   #BIT0, &P1DIR	        ; make P1.0 output
            bic.b   #BIT0, &P1OUT			; clear P1.0 (red led off)
            nop
            bis.w   #LPM3 + GIE,SR          ; Enter LPM3 w/interrupts enabled
            nop								; Required for debugger

WDT_ISR		xor.b #BIT0, &P1OUT				; Blink led once per second
			reti


;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            .sect ".int10"					; MSP430 WDT Interrupt Vector
            .short WDT_ISR
