;-------------------------------------------------------------------------------
; MSP430F5529 blink in assembly
; This is inefficient as it uses a software delay and the CPU is always on
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
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

;-------------------------------------------------------------------------------
                                            ; Main loop here
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;                                             Initialize outputs
;-------------------------------------------------------------------------------
            bis.b   #BIT0, &P1DIR       ; make P1.0 output
            bis.b   #BIT7, &P4DIR		; make P4.7 output
;-------------------------------------------------------------------------------
;                                             Red led off, green led on
;-------------------------------------------------------------------------------
On          bic.b   #BIT0, &P1OUT       ; clear P1.0 (red led off)
            bis.b   #BIT7, &P4OUT       ; set P4.7 (green red on)
            call    #d1						; call delay
;-------------------------------------------------------------------------------
;                                             Red led on, green led off
;-------------------------------------------------------------------------------
Off         bis.b   #BIT0, &P1OUT       ; set P1.0 (red led on)
            bic.b   #BIT7, &P4OUT       ; clear P4.7 (green led off)
            call    #d1					; call delay
            jmp     On
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
            
