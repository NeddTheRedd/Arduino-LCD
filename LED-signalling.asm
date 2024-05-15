;
; Student author: Lee Napthine
;
; *******************************
; Code provided for Assignment #2
;
; Author: Mike Zastre (2022-Oct-15)
;
 
; This skeleton of an assembly-language program is provided to help you
; begin with the programming tasks for A#2. As with A#1, there are "DO
; NOT TOUCH" sections. You are *not* to modify the lines within these
; sections. The only exceptions are for specific changes changes
; announced on Brightspace or in written permission from the course
; instructor. *** Unapproved changes could result in incorrect code
; execution during assignment evaluation, along with an assignment grade
; of zero. ****

.include "m2560def.inc"
.cseg
.org 0

; ***************************************************
; **** BEGINNING OF FIRST "STUDENT CODE" SECTION ****
; ***************************************************

	; initializion code will need to appear in this
    ; section

; Offset for function parameters on the stack
.set PARAM_OFFSET = 4

	; Set up the stack pointer
	ldi r16, low(0x21ff)
	ldi r17, high(0x21ff)
	out SPL, r16
	out SPH, r17

	; Set data direction for PORTL and PORTB to output (0xff)
	ldi r16, 0xff
	sts DDRL, r16
	out DDRB, r16


; ***************************************************
; **** END OF FIRST "STUDENT CODE" SECTION **********
; ***************************************************

; ---------------------------------------------------
; ---- TESTING SECTIONS OF THE CODE -----------------
; ---- TO BE USED AS FUNCTIONS ARE COMPLETED. -------
; ---------------------------------------------------
; ---- YOU CAN SELECT WHICH TEST IS INVOKED ---------
; ---- BY MODIFY THE rjmp INSTRUCTION BELOW. --------
; -----------------------------------------------------

	rjmp test_part_e
	; Test code


test_part_a:
	ldi r16, 0b00100001
	rcall set_leds
	rcall delay_long

	clr r16
	rcall set_leds
	rcall delay_long

	ldi r16, 0b00111000
	rcall set_leds
	rcall delay_short

	clr r16
	rcall set_leds
	rcall delay_long

	ldi r16, 0b00100001
	rcall set_leds
	rcall delay_long

	clr r16
	rcall set_leds

	rjmp end


test_part_b:
	ldi r17, 0b00101010
	rcall slow_leds
	ldi r17, 0b00010101
	rcall slow_leds
	ldi r17, 0b00101010
	rcall slow_leds
	ldi r17, 0b00010101
	rcall slow_leds

	rcall delay_long
	rcall delay_long

	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds

	rjmp end

test_part_c:
	ldi r16, 0b11111000
	push r16
	rcall leds_with_speed
	pop r16

	ldi r16, 0b11011100
	push r16
	rcall leds_with_speed
	pop r16

	ldi r20, 0b00100000
test_part_c_loop:
	push r20
	rcall leds_with_speed
	pop r20
	lsr r20
	brne test_part_c_loop

	rjmp end


test_part_d:
	ldi r21, 'E'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	ldi r21, 'A'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long


	ldi r21, 'M'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	ldi r21, 'H'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	rjmp end


test_part_e:
	ldi r25, HIGH(WORD02 << 1)
	ldi r24, LOW(WORD02 << 1)
	rcall display_message
	rjmp end

end:
    rjmp end






; ****************************************************
; **** BEGINNING OF SECOND "STUDENT CODE" SECTION ****
; ****************************************************

; Set the specified bits in PORTL and PORTB based on the value in r16

set_leds:

	; Save registers on the stack
	push r17
	push r18
	push r19

	; Initialize r17, r18 and r19 to 0
	ldi r17, 0
	ldi r18, 0
	clr r19

	; Check each bit in r16 and update r17 and r18 accordingly, 
	; then set the corresponding bit in PORTL

	sbrc r16, 0 
	ldi r19, 0b10000000 
	eor r17, r19
	clr r19
	sbrc r16, 1
	ldi r19, 0b00100000
	eor r17, r19
	clr r19
	sbrc r16, 2
	ldi r19, 0b00001000
	eor r17, r19
	clr r19
	sbrc r16, 3
	ldi r19, 0b00000010
	eor r17, r19
	clr r19

	sts PORTL, r17

	; Check each bit in r16 and update r17 and r18 accordingly, 
	; then set the corresponding bit in PORTB

	sbrc r16, 4
	ldi r19, 0b00001000
	eor r18, r19
	clr r19
	sbrc r16, 5
	ldi r19, 0b00000010
	eor r18, r19
	clr r19

	out PORTB, r18
	
	; Restore registers from the stack
	pop r19
	pop r18
	pop r17

	ret


; slow_leds: Set LEDs based on r17, then introduce a delay, and turn off the LEDs

slow_leds:

    ; Copy the LED pattern from r17 to r16
	mov r16, r17

	; Save r19 on the stack
	push r19 			

	; Set the LEDs based on the pattern in r16
	rcall set_leds

	; Delay for a longer period
	rcall delay_long

	; Turn off the LEDs by loading 0x00 into r19 and writing to PORTL and PORTB
	ldi r19, 0x00
	sts PORTL, r19
	out PORTB, r19

	; Restore r19 from the stack
	pop r19

	ret


; fast_leds: Set LEDs based on r17, then introduce a shorter delay, and turn off the LEDs

fast_leds:

	; Copy the LED pattern from r17 to r16
	mov r16, r17

	; Save r19 on the stack
	push r19
	
	; Set the LEDs based on the pattern in r16
	rcall set_leds

	; Introduce a shorter delay
	rcall delay_short

	; Turn off the LEDs by loading 0x00 into mask and writing to PORTL and PORTB
	ldi r19, 0x00
	sts PORTL, r19
	out PORTB, r19

	; Restore r19 from the stack
	pop r19

	ret


; leds_with_speed: Set LED speed and introduce the corresponding delay

leds_with_speed:

	; Load the stack pointer into Y
	in YH, SPH
	in YL, SPL

	; Load r17 from the stack at PARAM_OFFSET
	ldd r17, Y + PARAM_OFFSET

	; Make a copy of r17 in r18
	mov r18, r17

	; load a mask into r19, and the mask with r18, then check if the LED speed in temp matches r19
	ldi r19, 0b11000000
	and r18, r19
	cp r18, r19

	; If the LED speed matches, branch to the 'slow' label
	breq slow

	fast:
		; If the LED speed bits match, call the 'fast_leds' function
		rcall fast_leds
	ret

	slow:
		; If the LED speed bits do not match, call the 'slow_leds' function
		rcall slow_leds
	ret


; Note -- this function will only ever be tested
; with upper-case letters, but it is a good idea
; to anticipate some errors when programming (i.e. by
; accidentally putting in lower-case letters). Therefore
; the loop does explicitly check if the hyphen/dash occurs,
; in which case it terminates with a code not found
; for any legal letter.


; encode_letter: Encode a letter's LED pattern and duration based on input

encode_letter:
	
	; Register definitions
	.def srcH=r1 				; High byte register for data tables
	.def srcL=r0 				; Low byte register for data tables
	.def n=r17 					; Loop counter or index register
	.def temp=r18 				; Temporary register for general use

	; Load the stack pointer into Y
	in YH, SPH
	in YL, SPL

	; Load r21 from the stack at PARAM_OFFSET
	ldd r21, Y + PARAM_OFFSET


	ldi r25, 0 					; Initialize r25 to 0 to store the LED pattern
  	ldi r19, 0 					; Initialize r19 to store duration

    ldi temp, high(PATTERNS<<1) ;get the high byte of the byte address of PATTERNS into register temp
	mov srcH, temp ;store the high byte of the byte address of PATTERNS to register srcH
    ldi temp, low(PATTERNS<<1) ;get the low byte of the byte address of PATTERNS into register temp
	mov srcL, temp ;store the low byte of the byte address of PATTERNS to register srcL

	str_length:

		; Set Z register to point to the current pattern in PATTERNS
		mov ZH, srcH
		mov ZL, srcL

		; Clear n and set it to -1
		clr n
		ldi n, -1

	loop:

		; Check if it's the end of the patterns section
    	cpi temp, '-'
    	breq pattern_not_found

		; iterate through PATTERNS until you identify letter in r25
		inc n
		lpm temp, Z+
		cp temp, r21
		brne loop
	

	find_pattern:

		continue_pattern:

    		; Parse the LED pattern in r18
			lpm temp, Z+

    		cpi temp, '.'
    		breq dot_found
    		cpi temp, 'o'
    		breq o_found
			cpi temp, 1
			breq duration_is_1
			cpi temp, 2
    		breq duration_is_2

			; Combine the LED pattern and duration in r25 and r19
			or r25, r19
			ret

  		dot_found:
    		lsl r25     			; Shift left to add '0' (zero bit)
    		rjmp continue_pattern

  		o_found:
    		lsl r25     			; Shift left to add '0' (zero bit)
    		ori r25, 0b00000001  	; Set the lowest bit to '1'
    		rjmp continue_pattern

    	duration_is_1:
    		ldi r19, 0b11000000 	; Set duration to '1' 
    		rjmp continue_pattern

  		duration_is_2:
    		ldi r19, 0b00000000 	; Set duration to '2' 
    		rjmp continue_pattern

    	pattern_not_found:
			
			; Pattern not found. 
			; Display pattern for '-'
			ldi r25, 0b11100011
			ret


; display_message: Display an encoded message using LEDs

display_message:

	; Set r31 and r30 to the message address (r25 and r24)
	mov r31, r25
	mov r30, r24

	; Initialize r21 to 0 (used to extract letters from the message)
	ldi r21, 0  ; Initialize r21 to 0

iterate_through:

	; Load a character from the message into r21
	lpm r21, Z+

	; Check if the character is null (end of the message)
	cpi r21, 0
	breq done

	; Save registers on the stack
	push r31
	push r30
	push r21

	; Call the 'encode_letter' function to encode the character
	rcall encode_letter

	; Restore registers from the stack
	pop r21
	pop r30
	pop r31

	; Save r25 on the stack
	push r25

	; Call 'leds_with_speed' to display the encoded letter
	rcall leds_with_speed

	; call delay_short to blink lights off between encodings for a short duration
	rcall delay_short
	rcall delay_short

	; Restore r25 from the stack
	pop r25

	; Continue to the next character in the message
	rjmp iterate_through

done:
	ret


; ****************************************************
; **** END OF SECOND "STUDENT CODE" SECTION **********
; ****************************************************




; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================

; about one second
delay_long:
	push r16

	ldi r16, 14
delay_long_loop:
	rcall delay
	dec r16
	brne delay_long_loop

	pop r16
	ret


; about 0.25 of a second
delay_short:
	push r16

	ldi r16, 4
delay_short_loop:
	rcall delay
	dec r16
	brne delay_short_loop

	pop r16
	ret

; When wanting about a 1/5th of a second delay, all other
; code must call this function
;
delay:
	rcall delay_busywait
	ret


; This function is ONLY called from "delay", and
; never directly from other code. Really this is
; nothing other than a specially-tuned triply-nested
; loop. It provides the delay it does by virtue of
; running on a mega2560 processor.
;
delay_busywait:
	push r16
	push r17
	push r18

	ldi r16, 0x08
delay_busywait_loop1:
	dec r16
	breq delay_busywait_exit

	ldi r17, 0xff
delay_busywait_loop2:
	dec r17
	breq delay_busywait_loop1

	ldi r18, 0xff
delay_busywait_loop3:
	dec r18
	breq delay_busywait_loop2
	rjmp delay_busywait_loop3

delay_busywait_exit:
	pop r18
	pop r17
	pop r16
	ret


; Some tables
.cseg
;.org 0x600

PATTERNS:
	; LED pattern shown from left to right: "." means off, "o" means
    ; on, 1 means long/slow, while 2 means short/fast.
	.db "A", "..oo..", 1
	.db "B", ".o..o.", 2
	.db "C", "o.o...", 1
	.db "D", ".....o", 1
	.db "E", "oooooo", 1
	.db "F", ".oooo.", 2
	.db "G", "oo..oo", 2
	.db "H", "..oo..", 2
	.db "I", ".o..o.", 1
	.db "J", ".....o", 2
	.db "K", "....oo", 2
	.db "L", "o.o.o.", 1
	.db "M", "oooooo", 2
	.db "N", "oo....", 1
	.db "O", ".oooo.", 1
	.db "P", "o.oo.o", 1
	.db "Q", "o.oo.o", 2
	.db "R", "oo..oo", 1
	.db "S", "....oo", 1
	.db "T", "..oo..", 1
	.db "U", "o.....", 1
	.db "V", "o.o.o.", 2
	.db "W", "o.o...", 2
	.db "X", "oo....", 2
	.db "Y", "..oo..", 2
	.db "Z", "o.....", 2
	.db "-", "o...oo", 1   ; Just in case!

WORD00: .db "HELLOWORLD", 0, 0
WORD01: .db "THE", 0
WORD02: .db "QUICK", 0
WORD03: .db "BROWN", 0
WORD04: .db "FOX", 0
WORD05: .db "JUMPED", 0, 0
WORD06: .db "OVER", 0, 0
WORD07: .db "THE", 0
WORD08: .db "LAZY", 0, 0
WORD09: .db "DOG", 0

; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================

