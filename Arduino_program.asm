;
; a3part-D.asm
;
; Part D of assignment #3
;
;
; Student name:
; Student ID:
; Date of completed work:
;
; **********************************
; Code provided for Assignment #3
;
; Author: Mike Zastre (2022-Nov-05)
;
; This skeleton of an assembly-language program is provided to help you 
; begin with the programming tasks for A#3. As with A#2 and A#1, there are
; "DO NOT TOUCH" sections. You are *not* to modify the lines within these
; sections. The only exceptions are for specific changes announced on
; Brightspace or in written permission from the course instruction.
; *** Unapproved changes could result in incorrect code execution
; during assignment evaluation, along with an assignment grade of zero. ***
;


; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================
;
; In this "DO NOT TOUCH" section are:
; 
; (1) assembler direction setting up the interrupt-vector table
;
; (2) "includes" for the LCD display
;
; (3) some definitions of constants that may be used later in
;     the program
;
; (4) code for initial setup of the Analog-to-Digital Converter
;     (in the same manner in which it was set up for Lab #4)
;
; (5) Code for setting up three timers (timers 1, 3, and 4).
;
; After all this initial code, your own solutions's code may start
;

.cseg
.org 0
	jmp reset

; Actual .org details for this an other interrupt vectors can be
; obtained from main ATmega2560 data sheet
;
.org 0x22
	jmp timer1

; This included for completeness. Because timer3 is used to
; drive updates of the LCD display, and because LCD routines
; *cannot* be called from within an interrupt handler, we
; will need to use a polling loop for timer3.
;
; .org 0x40
;	jmp timer3

.org 0x54
	jmp timer4

.include "m2560def.inc"
.include "lcd.asm"

.cseg
#define CLOCK 16.0e6
#define DELAY1 0.01
#define DELAY3 0.1
#define DELAY4 0.5

#define BUTTON_RIGHT_MASK 0b00000001	
#define BUTTON_UP_MASK    0b00000010
#define BUTTON_DOWN_MASK  0b00000100
#define BUTTON_LEFT_MASK  0b00001000

#define BUTTON_RIGHT_ADC  0x032
#define BUTTON_UP_ADC     0x0b0   ; was 0x0c3
#define BUTTON_DOWN_ADC   0x160   ; was 0x17c
#define BUTTON_LEFT_ADC   0x22b
#define BUTTON_SELECT_ADC 0x316

.equ PRESCALE_DIV=1024   ; w.r.t. clock, CS[2:0] = 0b101

; TIMER1 is a 16-bit timer. If the Output Compare value is
; larger than what can be stored in 16 bits, then either
; the PRESCALE needs to be larger, or the DELAY has to be
; shorter, or both.
.equ TOP1=int(0.5+(CLOCK/PRESCALE_DIV*DELAY1))
.if TOP1>65535
.error "TOP1 is out of range"
.endif

; TIMER3 is a 16-bit timer. If the Output Compare value is
; larger than what can be stored in 16 bits, then either
; the PRESCALE needs to be larger, or the DELAY has to be
; shorter, or both.
.equ TOP3=int(0.5+(CLOCK/PRESCALE_DIV*DELAY3))
.if TOP3>65535
.error "TOP3 is out of range"
.endif

; TIMER4 is a 16-bit timer. If the Output Compare value is
; larger than what can be stored in 16 bits, then either
; the PRESCALE needs to be larger, or the DELAY has to be
; shorter, or both.
.equ TOP4=int(0.5+(CLOCK/PRESCALE_DIV*DELAY4))
.if TOP4>65535
.error "TOP4 is out of range"
.endif

reset:
; ***************************************************
; **** BEGINNING OF FIRST "STUDENT CODE" SECTION ****
; ***************************************************

; Anything that needs initialization before interrupts
; start must be placed here.

; symbonic names for registers
.def DATAH=r25  	;DATAH:DATAL  store 10 bits data from ADC
.def DATAL=r24
.def BOUNDARY_H=r1  ;hold high byte value of the threshold for button
.def BOUNDARY_L=r0  ;hold low byte value of the threshold for button, r1:r0

; Set temp registers
.def templow=r20		; initalizie temp word low
.def temphigh=r21		; initalizie temp word high

	; initialize the stack
	ldi templow, low(RAMEND)
	out SPL, templow
	ldi temphigh, high(RAMEND)
	out SPH, temphigh

rcall lcd_init ; call lcd_init to Initialize the LCD (line 689 in lcd.asm)

; ***************************************************
; ******* END OF FIRST "STUDENT CODE" SECTION *******
; ***************************************************

; =============================================
; ====  START OF "DO NOT TOUCH" SECTION    ====
; =============================================

	; initialize the ADC converter (which is needed
	; to read buttons on shield). Note that we'll
	; use the interrupt handler for timer 1 to
	; read the buttons (i.e., every 10 ms)
	;
	ldi temp, (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0)
	sts ADCSRA, temp
	ldi temp, (1 << REFS0)
	sts ADMUX, r16

	; Timer 1 is for sampling the buttons at 10 ms intervals.
	; We will use an interrupt handler for this timer.
	ldi r17, high(TOP1)
	ldi r16, low(TOP1)
	sts OCR1AH, r17
	sts OCR1AL, r16
	clr r16
	sts TCCR1A, r16
	ldi r16, (1 << WGM12) | (1 << CS12) | (1 << CS10)
	sts TCCR1B, r16
	ldi r16, (1 << OCIE1A)
	sts TIMSK1, r16

	; Timer 3 is for updating the LCD display. We are
	; *not* able to call LCD routines from within an 
	; interrupt handler, so this timer must be used
	; in a polling loop.
	ldi r17, high(TOP3)
	ldi r16, low(TOP3)
	sts OCR3AH, r17
	sts OCR3AL, r16
	clr r16
	sts TCCR3A, r16
	ldi r16, (1 << WGM32) | (1 << CS32) | (1 << CS30)
	sts TCCR3B, r16
	; Notice that the code for enabling the Timer 3
	; interrupt is missing at this point.

	; Timer 4 is for updating the contents to be displayed
	; on the top line of the LCD.
	ldi r17, high(TOP4)
	ldi r16, low(TOP4)
	sts OCR4AH, r17
	sts OCR4AL, r16
	clr r16
	sts TCCR4A, r16
	ldi r16, (1 << WGM42) | (1 << CS42) | (1 << CS40)
	sts TCCR4B, r16
	ldi r16, (1 << OCIE4A)
	sts TIMSK4, r16

	sei

; =============================================
; ====    END OF "DO NOT TOUCH" SECTION    ====
; =============================================

; ****************************************************
; **** BEGINNING OF SECOND "STUDENT CODE" SECTION ****
; ****************************************************

start:

	;check if timer 3 has reached TOP3
	in temp, TIFR3			; assign timer to register r16
	sbrs temp, OCF3A		; skip if overflow flag is set
	rjmp start

	ldi temp, 1<<OCF3A		; reset overflow flag			
	out TIFR3, temp 		; write temp to TIFR3 to clear flag

	; Set cursor position to bottom right using lcd_gotoxy
	ldi r16, 1 				;row
	ldi r17, 15 			;column
	push r16
	push r17
	rcall lcd_gotoxy 		; call lcd.asm function to write char
	pop r17
	pop r16

	lds r17, BUTTON_IS_PRESSED
	cpi r17, 1              ; check if BUTTON_IS_PRESSED pressed
	brne set_default        ; Jump to set_default if the button is not pressed
			    
	; Change the following code so that displays “*"
	ldi r16, '*'
	push r16
	rcall lcd_putchar		; call lcd.asm function to write char
	pop r16

	; Code for updating the LCD display when the button is pressed
	lds r16, LAST_BUTTON_PRESSED
	cpi r16, 'L'
	breq LEFT
	cpi r16, 'D'
	breq DOWN
	cpi r16, 'U'
	breq UP
	cpi r16, 'R'
	breq RIGHT

	rjmp start 		; No valid button presses

; set rows and columns for button chars
LEFT:
	ldi r16, 1
	ldi r17, 0
	rjmp set_xy

DOWN:
	ldi r16, 1
	ldi r17, 1
	rjmp set_xy

UP:
	ldi r16, 1
	ldi r17, 2
	rjmp set_xy

RIGHT:
	ldi r16, 1
	ldi r17, 3
	rjmp set_xy
		    
set_xy:
	; Set cursor position to bottom right using lcd_gotoxy
	push r17
	push r16
	call lcd_gotoxy		; Call lcd.asm function to set position
	pop r16
	pop r17

	; Write the character to the LCD
	ldi r16, LAST_BUTTON_PRESSED
	push r16
	call lcd_putchar		; call lcd.asm function to write char
	pop r16

	; Write TOP_LINE_CONTENT to top line of the LCD
	; set xy
	ldi r16, 0
	lds r17, CURRENT_CHAR_INDEX
	push r17
	push r16
	call lcd_gotoxy			; Call lcd.asm function to set position
	pop r16
	pop r17

	; write character to LCD
	ldi r16, TOP_LINE_CONTENT
	push r16
	call lcd_putchar		; call lcd.asm function to write char
	pop r16

	jmp start        		; jmp back to the main loop


; Set default char value, "-"
set_default:
	;now display some characters
	;change the following code so that it starts at row 1, column 15.
	ldi r16, 1 ;row
	ldi r17, 15 ;column

	; save register to stack
	push r16
	push r17
	rcall lcd_gotoxy  		; call lcd.asm function to set position

	; retrieve registers
	pop r17
	pop r16

	;change the following code so that displays “-”
	ldi r16, '-'
	push r16
	rcall lcd_putchar 		; call lcd.asm function to write char
	pop r16


stop:
	jmp start				; jump back to start


check_button:
	; start a2d
	lds	r16, ADCSRA

	; bit 6 =1 ADSC (ADC Start Conversion bit), remain 1 if conversion not done
	; ADSC changed to 0 if conversion is done
	ori r16, 0x40 			; 0x40 = 0b01000000
	sts	ADCSRA, r16

; wait for it to complete, check for bit 6, the ADSC bit
wait:	lds r16, ADCSRA
		andi r16, 0x40
		brne wait

		; read the value, use XH:XL to store the 10-bit result
		lds DATAL, ADCL
		lds DATAH, ADCH

		; detect if "Any button is pressed" button is pressed r1:r0 <- 0x0x384
		ldi r16, low(0x384); 
		mov BOUNDARY_L, r16
		ldi r16, high(0x384)
		mov BOUNDARY_H, 
		call compare_boundary
		brcs button_not_pressed

		; detect if "BUTTON_SELECT_ADC" button is pressed r1:r0 
		ldi r16, low(0x22B);
		mov BOUNDARY_L, r16
		ldi r16, high(0x22B)
		mov BOUNDARY_H, r16
		call compare_boundary
		brcs button_select

		; detect if "BUTTON_LEFT_ADC" button is pressed r1:r0 
		ldi r16, low(0x160);
		mov BOUNDARY_L, r16
		ldi r16, high(0x160)
		mov BOUNDARY_H, r16
		call compare_boundary
		brcs button_left

		; detect if "BUTTON_DOWN_ADC" button is pressed r1:r0 
		ldi r16, low(0xB0);
		mov BOUNDARY_L, r16
		ldi r16, high(0xB0)
		mov BOUNDARY_H, r16
		call compare_boundary
		brcs button_down 

		; detect if "BUTTON_UP_ADC" button is pressed r1:r0 
		ldi r16, low(0x32);
		mov BOUNDARY_L, r16
		ldi r16, high(0x32)
		mov BOUNDARY_H, r16
		call compare_boundary
		brcs button_up 

		; detect if "BUTTON_RIGHT_ADC" button is pressed r1:r0 
		ldi r16, low(0x32);
		mov BOUNDARY_L, r16
		ldi r16, high(0x32)
		mov BOUNDARY_H, r16
		call compare_boundary
		brcs button_right

; check if carry flag in set when comparing DATA : BOUNDARY
compare_boundary:
	cp DATAL, BOUNDARY_L
	cpc DATAH, BOUNDARY_H
	ret

; timer 1 interrupt handler
timer1:
	; save registers to the stack
	push r16
	push r17
	lds r16, SREG 	; save status register
	push r16

	rcall check_button

	; retrieve registers
	pop r16
	sts SREG, r16  	
	pop r17
	pop r16

	reti

; Determing which (if any) button was pressed
; Then assign value to BUTTON_IS_PRESSED and LAST_BUTTON_PRESSED
; Then return to the call check_button

button_not_pressed:
	; Set BUTTON_IS_PRESSED to 0
    ldi r20, 0x00
    sts BUTTON_IS_PRESSED, r20
    ret

button_select:
	; Set BUTTON_IS_PRESSED to 1
    ldi r20, 0x01
    sts BUTTON_IS_PRESSED, r20
    ret
    
button_left:
	; Set BUTTON_IS_PRESSED to 1
    ldi r20, 0x01
    sts BUTTON_IS_PRESSED, r20
    ; Set LAST_BUTTON_PRESSED to L
    ldi r20, 'L'
   	sts LAST_BUTTON_PRESSED, r20
    ret

button_down:
	; Set BUTTON_IS_PRESSED to 1
    ldi r20, 0x01
    sts BUTTON_IS_PRESSED, r20
    ; Set LAST_BUTTON_PRESSED to D
    ldi r20, 'D'
   	sts LAST_BUTTON_PRESSED, r20
    ret

button_up:
	; Set BUTTON_IS_PRESSED to 1
    ldi r20, 0x01
    sts BUTTON_IS_PRESSED, r20
    ; Set LAST_BUTTON_PRESSED to U
    ldi r20, 'U'
   	sts LAST_BUTTON_PRESSED, r20
    ret

button_right:
    ; Set BUTTON_IS_PRESSED to 1
    ldi r20, 0x01
    sts BUTTON_IS_PRESSED, r20
    ; Set LAST_BUTTON_PRESSED to R
    ldi r20, 'R'
   	sts LAST_BUTTON_PRESSED, r20
    ret


timer4:
	; check if button is pressed
	lds r16, BUTTON_IS_PRESSED
	cpi r16, 1
	brne timer4_end

	; check value is U or D
	lds r16, LAST_BUTTON_PRESSED
	cpi r16, 'U'
	breq inc_indx
	cpi r16, 'D'
	breq dec_indx
	cpi r16, 'L'
	breq shift_left
	cpi r16, 'R'
	breq shift_right

	; if it is neither end timer4
	rjmp timer4_end

; CURRENT_CHARSET_INDEX increments
inc_indx:
	lds r16, CURRENT_CHARSET_INDEX
	inc r16
	lds r17, AVAILABLE_CHARSET + r16
	cpi r17, '_'

	; CURRENT_CHARSET_INDEX is at the bounds
	breq timer4_end

	sts CURRENT_CHARSET_INDEX, r16
	rjmp set_top_line

; CURRENT_CHARSET_INDEX decrements
dec_indx:
	lds r16, CURRENT_CHARSET_INDEX
	cpi r16, 0

	; CURRENT_CHARSET_INDEX is at the bounds
	breq timer4_end

	dec r16
	sts CURRENT_CHARSET_INDEX, r16
	rjmp set_top_line

set_top_line:
	; Update TOP_LINE_CONTENT at the appropriate index
    lds r17, AVAILABLE_CHARSET + r16
    sts TOP_LINE_CONTENT, r17

; Shift left along top row of LCD
shift_left:
	lds r16, CURRENT_CHAR_INDEX
	cpi r16, 0

	; CURRENT_CHAR_INDEX is at the bounds
	breq timer4_end

	dec r16
	sts CURRENT_CHAR_INDEX, r16

; Shift right along top row of LCD
shift_right:
	lds r16, CURRENT_CHAR_INDEX
	cpi r16, 15

	; CURRENT_CHAR_INDEX is at the bounds
	breq timer4_end

	inc r16
	sts CURRENT_CHAR_INDEX, r16

timer4_end:
	reti


; ****************************************************
; ******* END OF SECOND "STUDENT CODE" SECTION *******
; ****************************************************


; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================

; r17:r16 -- word 1
; r19:r18 -- word 2
; word 1 < word 2? return -1 in r25
; word 1 > word 2? return 1 in r25
; word 1 == word 2? return 0 in r25
;
compare_words:
	; if high bytes are different, look at lower bytes
	cp r17, r19
	breq compare_words_lower_byte

	; since high bytes are different, use these to
	; determine result
	;
	; if C is set from previous cp, it means r17 < r19
	; 
	; preload r25 with 1 with the assume r17 > r19
	ldi r25, 1
	brcs compare_words_is_less_than
	rjmp compare_words_exit

compare_words_is_less_than:
	ldi r25, -1
	rjmp compare_words_exit

compare_words_lower_byte:
	clr r25
	cp r16, r18
	breq compare_words_exit

	ldi r25, 1
	brcs compare_words_is_less_than  ; re-use what we already wrote...

compare_words_exit:
	ret

.cseg
AVAILABLE_CHARSET: .db "0123456789abcdef_", 0


.dseg

BUTTON_IS_PRESSED: .byte 1			; updated by timer1 interrupt, used by LCD update loop
LAST_BUTTON_PRESSED: .byte 1        ; updated by timer1 interrupt, used by LCD update loop

TOP_LINE_CONTENT: .byte 16			; updated by timer4 interrupt, used by LCD update loop
CURRENT_CHARSET_INDEX: .byte 16		; updated by timer4 interrupt, used by LCD update loop
CURRENT_CHAR_INDEX: .byte 1			; ; updated by timer4 interrupt, used by LCD update loop


; =============================================
; ======= END OF "DO NOT TOUCH" SECTION =======
; =============================================


; ***************************************************
; **** BEGINNING OF THIRD "STUDENT CODE" SECTION ****
; ***************************************************

.dseg

; If you should need additional memory for storage of state,
; then place it within the section. However, the items here
; must not be simply a way to replace or ignore the memory
; locations provided up above.


; ***************************************************
; ******* END OF THIRD "STUDENT CODE" SECTION *******
; ***************************************************
