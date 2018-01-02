;-------------------------------------------------------------------------------
; MSP430 Assembly Blink LED using the Watchdog Timer Interrupt
; for MSP430F5529 Launchpad
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
RESET       mov.w   #__STACK_END, SP		; Initialize stackpointer
			mov.w   #WDT_ADLY_1000, &WDTCTL	; WDT 1000ms, ACLK, interval timer
											; In this example the WDT interrupt
											; is used to blink LED efficiently
			bis.w   #WDTIE, &SFRIE1			; Enable WDT interrupt

;-------------------------------------------------------------------------------
;												Initialize outputs
;-------------------------------------------------------------------------------
            call #ZERO_PORTS
            bis.b   #BIT0, &P1DIR	        ; make P1.0 output
            bis.b   #BIT7, &P4DIR			; make P4.7 output
            bic.b   #BIT0, &P1OUT			; clear P1.0 (red led off)
            bis.b   #BIT7, &P4OUT           ; clear P4.7 (green led on)
            nop
            bis.w   #LPM3 + GIE,SR          ; Enter LPM3 w/interrupts enabled
            nop								; Required for debugger

ZERO_PORTS	mov.b #0xFF, &P1DIR				; Initalize all ports as outputs
			mov.b #0xFF, &P2DIR				; And set them to zero
			mov.b #0xFF, &P3DIR				; To minimize power consumption
			mov.b #0xFF, &P4DIR
			mov.b #0xFF, &P5DIR
			mov.b #0xFF, &P6DIR
			mov.b #0xFF, &P7DIR
			mov.b #0xFF, &P8DIR
			mov.b #0x00, &P1OUT
			mov.b #0x00, &P2OUT
			mov.b #0x00, &P3OUT
			mov.b #0x00, &P4OUT
			mov.b #0x00, &P5OUT
			mov.b #0x00, &P6OUT
			mov.b #0x00, &P7OUT
			mov.b #0x00, &P8OUT
			ret

WDT_ISR		xor.b #BIT0, &P1OUT				; Blink leds once per second
			xor.b #BIT7, &P4OUT
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
            .sect ".int57"					; MSP430 WDT Interrupt Vector
            .short WDT_ISR
