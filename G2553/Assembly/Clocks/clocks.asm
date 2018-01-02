;-------------------------------------------------------------------------------
; Set clocks for MSP430G2553 using Assembly
; for value line Launchpad
; (C) 2018 Manolis Kiagias
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
StopWDT     mov.w   #WDTPW|WDTHOLD, &WDTCTL ; Stop watchdog timer

			clr.b &DCOCTL 					; Select lowest DCOx
			mov.b &CALBC1_8MHZ, &BCSCTL1    ; Set range
			mov.b &CALDCO_8MHZ, &DCOCTL     ; Set DCO step + modulation
			bis.b #DIVS0, &BCSCTL2			; Set DCO for SMCLK, MCLK
;-------------------------------------------------------------------------------
;                                             Initialize outputs
;-------------------------------------------------------------------------------
            bis.b #BIT0 + BIT4 + BIT6, &P1DIR     ; make P1.0, P1.6, P1.4 outputs
            bis.b #BIT4, &P1SEL					  ; make P1.4 SMCLK out
            bic.b #BIT4, &P1SEL2				  ; as above :D
;-------------------------------------------------------------------------------
;                                             Red led off, green led on
;-------------------------------------------------------------------------------
            bic.b   #BIT0, &P1OUT       ; clear P1.0 (red led off)
            bis.b   #BIT6, &P1OUT       ; set P1.6 (green red on)
;-------------------------------------------------------------------------------
;											 Main loop here
;-------------------------------------------------------------------------------
toggle      xor.b   #BIT0+BIT6, &P1OUT      ; toggle outputs
            call    #d1						; call delay
            jmp     toggle
;-------------------------------------------------------------------------------
;                                             Delay subroutine
;-------------------------------------------------------------------------------
d1          mov.w   #10,R14					; load R14 with outer loop value
L1          mov.w   #35000,R15              ; load R15 with inner loop value
L2          dec.w   R15                     ; decrement R15
            jnz     L2						; loop till zero
            dec.w   R14						; decrement R14
            jnz     L1						; loop till zero
            ret 		                    ; Back to caller

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
