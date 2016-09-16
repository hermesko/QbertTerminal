	AREA	Library, CODE, READWRITE
	EXPORT set_board_hardware
	EXPORT output_character
	EXPORT read_character
	EXPORT output_string
	EXPORT read_string
	EXPORT uart_init
	EXPORT div_and_mod
	EXPORT pin_connect_block_setup
	EXPORT interrupt_init
	EXPORT set_lives
	EXPORT set_RGB_led
		
PIODATA	EQU	0x8 		; Offset to parallel I/O data register
PINSEL0 EQU 0xE002C000	; Base address for PINSEL0
PINSEL1 EQU	0xE002C004	; Base address for PINSEL1

IO0PIN	EQU 0xE0028000	; Base address for IO0PIN
IO0SET	EQU 0xE0028004	; Base address for IO0SET
IO0DIR	EQU	0xE0028008	; Base address for IO0DIR
IO0CLR	EQU 0xE002800C	; Base address for IO0CLR

IO1PIN 	EQU	0xE0028010	; Base address for IO1PIN
IO1SET	EQU 0xE0028014	; Base address for IO1SET
IO1DIR	EQU 0xE0028018	; Base address for IO1DIR
IO1CLR 	EQU 0xE002801C	; Base address for IO1CLR
	ALIGN
		
digits_SET	
		DCD 0x00001F80  ; 0
 		DCD 0x00000300  ; 1 
		DCD 0x00002D80	; 2
		DCD 0x00002780	; 3
		DCD	0x00003300	; 4
		DCD 0x00003680	; 5
		DCD 0x00003E80	; 6
		DCD 0x00000380	; 7
		DCD 0x00003F80	; 8
		DCD 0x00003780	; 9
		DCD 0x00003B80	; A
		DCD 0x00003E00	; B
		DCD 0x00002C00	; C
		DCD 0x00002F00	; D
		DCD 0x00003C80	; E
		DCD 0x00003880  ; F

	ALIGN
										
set_level_on_7_seg

		; Used to set the 7 segment display to the current level.
		; Pass in the current level to r1.
		
		STMFD sp!, {r4-r9,lr}
		
		; Load the required addresses.
		LDR r4, =IO0SET
		LDR r5, =IO0CLR
		LDR r6, =digits_SET
		
		; Clear pins 7-13 in the GPIO
		ORR r7, r7, #0x00003F80					; Turn off pins 7-13 in the GPIO.
		STR r7, [r5]							; Store r6 back into IO0CLR.
		
		; Get the value from the lookup table corresponding to the current level.
		MOV r7, #4								; Set r6 to hold value 0x4 as the base for offset.
		MUL	r8, r1, r7							; Multiply the offset base by the current level to get the correct offset.
		LDR r9, [r6, r8]						; r7 contains the value from the lookup table corresponding
												; to the desired output on the 7 segment display.
	
		; Set pins 7-13 in the GPIO	to the desired output.
		LDR r7, [r4]							; Load the contents of IO0SET into r6.
		ORR r7, r7, r9							; Set bits 7-13 to the value from the lookup table.
		STR r7, [r4]							; Store r6 back into IO0SET.

		LDMFD sp!, {r4-r9,lr}
		BX lr
		
set_lives
		
		; Used to set the LEDs on the board to the current number of lives.
		; Pass in the current number of lives into r2.
		
		STMFD sp!, {r4-r6,lr}
		
		; Load the required addresses.
		LDR r4, =IO1SET
		LDR r5, =IO1CLR
		
		; 1) Turn off all LEDs (write 1's to P1.16 to P1.19 in IO1SET)
		LDR r6, [r4]							; Load contents of IO1SET.
		ORR r6, r6, #0x000F0000					; Write 1's to bits 16-19 in IO1SET to turn off those pins.
		STR r6, [r4]							; Store contents of IO1SET.
		
		; 2) Check the number of lives.
		; --> If zero lives, all LEDs are off so branch to LSET.
		; --> If more than zero lives, set LEDs to number of lives.
		CMP r2, #0x0							; Current number of lives is zero.
		BEQ LDONE								; All LEDs are off, exit the subroutine.
		
		CMP r2, #0x1							; Current number of lives is 1.
		BEQ LONE								; If equal, branch to ONE.
		
		CMP r2, #0x2							; Current number of lives is 2.
		BEQ LTWO								; If equal, branch to TWO.
		
		CMP r2, #0x3							; Current number of lives is 3.
		BEQ LTHREE								; If equal, branch to THREE.
		
		CMP r2, #0x4							; Current number of lives is 4.
		BEQ LFOUR								; If equal, branch to FOUR.

LONE	MOV	r6, #0x00080000						; Set bit 19 in r6 to 1 to turn on P1.19.
		B LSET									; Branch to store r6 into IO1CLR.
		
LTWO 	MOV r6, #0x000C0000						; Set bits 18-19 in r6 to 1 to turn on P1.18-P1.19.
		B LSET									; Branch to store r6 into IO1CLR.
		
LTHREE	MOV r6, #0x000E0000						; Set bits 17-19 in r6 to 1 to turn on P1.17-P1.19.
		B LSET									; Branch to store r6 into IO1CLR.
		
LFOUR	MOV r6, #0x000F0000						; Set bits 16-19 in r6 to 1 to turn on P1.16-P1.19.
		
		; 3) Set the LEDs to the current amount of lives (write 1's to P1.16 to P1.19 in IO1CLR corresponding to lives).
LSET	STR r6, [r5]							; Store r6 into IO1CLR.

LDONE	LDMFD sp!, {r4-r6,lr}
		BX lr

set_RGB_led
		
		; Used to set the RGB LED on the board to reflect the current game state.
		; Pass in the current game state into r3.
		
		STMFD sp!, {r4-r6,lr}
		
		; Load the required addresses.
		LDR r4, =IO0SET
		LDR r5, =IO0CLR
		
		LDR r6, [r4]							; Load contents of IO0SET.
		ORR r6, r6, #0x00260000					; Set bits 17/18/21 in r9 to turn off the RGB LED.
		STR r6, [r4]							; Store contents of IO0SET.
		
		CMP r3, #0x0							; Current game state is 0 (Not initialized).
		BEQ RZERO								; Branch to set the RGB LED to WHITE.
		
		CMP r3, #0x1							; Current game state is 1 (Running).
		BEQ RONE								; Branch to set the RGB LED to GREEN.
		
		CMP r3, #0x2							; Current game state is 2 (Ended).
		BEQ RTWO								; Branch to set the RGB LED to PURPLE.
		
		CMP r3, #0x3							; Current game state is 3 (Paused).
		BEQ RTHREE								; Branch to set the RGB LED to BLUE.
		
RZERO	MOV r6, #0x00260000						; Set bits 17/18/21 in r6 to turn on the RGB LED to WHITE.
		BEQ RSET								; Branch to store r6 into IO0CLR.
		
RONE	MOV r6, #0x00200000						; Set bit 21 in r6 to turn on the RGB LED to GREEN.
		BEQ RSET								; Branch to store r6 into IO0CLR.
		
RTWO	MOV r6, #0x00060000						; Set bits 17/18 in r6 to turn on the RGB LED to PURPLE.
		BEQ RSET								; Branch to store r6, into IO0CLR.
		
RTHREE
		MOV r6, #0x00040000						; Set bit 18 in r6 to turn on the RGB LED to BLUE.
		
RSET	STR r6, [r5]							; Store r6 into IO0CLR.
		
		LDMFD sp!, {r4-r6,lr}
		BX lr

set_board_hardware
		
		; Used to set the LEDs, RGB LED, and the 7-segment display to their current states.
		; Pass in the current level into r1.
		; Pass in the current number of lives into r2.
		; Pass in the current game state into r3.
		; --> Current game state values:	0 = Not Initialized.
		;									1 = Game is running.
		; 									2 = Game has ended.
		;									3 = Game is paused.
		
		STMFD sp!, {lr}
		
		; Branch to set_level_on_7_seg (current level passed into r1).
		BL set_level_on_7_seg
		
		; Branch to set_lives (number of lives passed into r2).
		BL set_lives
		
		; Branch to set_RGB_LED (current game state passed into r3).
		BL set_RGB_led
	
		LDMFD sp!, {lr}
		BX lr
		
div_and_mod 
		STMFD sp!, {r2-r6,lr}
		
		; Your code for the signed division/mod routine goes here.   
		; The dividend is passed in r0 and the divisor in r1. 
		; The quotient is returned in r0 and the remainder in r1.
		
		MOV r5, #0			; Initialize flag for negative Dividend
		MOV r6, #0			; Initialize flag for negative Divisor

		CMP r0, #0			; Check if Dividend is Negative
		BGT DIVPOS			; If not, jump to check if Divisor is positive
		MVN r0, r0			; Else, 1's complement of Dividend
		ADD r0, r0, #1		; Add 1 to make 2's complement
		MOV r5, #1			; Set flag for negative Dividend

DIVPOS	CMP r1, #0			; Check if Divisor is Positive
		BGT INIT			; If not, jump to DIVIDE
		MVN r1, r1			; Else, 1's complement of Divisor
		ADD r1, r1, #1		; Add 1 to make 2's complement
		MOV r6, #1			; Set flag for negative Divisor

INIT	MOV r4, #15			; Initialize Counter to 15
		MOV r3, #0			; Initialize Quotient to 0
		MOV r2, r0			; Initialize Remainder to Dividend
		LSL r1, #15			; Logical Left Shift Divisor 15 Places
	    B DIVIDE

DECRE	SUB r4, r4, #1		; Decrement Counter

DIVIDE	SUB r2, r2, r1		; Remainder := Remainder - Divisor
		CMP r2, #0			; Is Remainder < 0?
		BLT NEGREM			; If Yes, branch to NEGREM
		LSL r3, #1			; Left Shift Quotient							
		ADD r3, r3, #0x1	; Else, LSB = 1
		B SHIFT				; Branch to SHIFT

NEGREM	ADD r2, r2, r1		; Remainder := Remainder + Divisor
		LSL r3, #1			; Left Shift Quotient

SHIFT	LSR r1, #1			; Right Shift Divisor MSB = 0			
		CMP r4, #0			; Is Counter > 0?
		BGT DECRE			; If Yes, branch to DECRE

		CMP r5, r6			; Compare Divisor and Dividend flags
		BEQ STOP			; If equal, branch to STOP
		MVN r3, r3			; Else, 1's complement of Quotient
		ADD r3, r3, #1			; Add 1 to make 2's complement
	
STOP	MOV r1, r2			; Store Remainder into r1 
		MOV r0, r3			; Store Quotient into r0
		
		LDMFD sp!, {r2-r6,lr} 
		BX lr      ; Return to the C program

output_character	 ; output_character
			STMFD sp!, {r2-r4,lr}
	
LOOP		LDR 	r2, =0xE000C014	; r2 has the ULSR loaded into it
			LDRB 	r3, [r2]		; load contents from address into r3
			LSR 	r3, #5			; right shift 5 bits to read THRE bits
			AND 	r3, r3, #1		; AND r3 bits with 1 to see if THRE is 1

			CMP 	r3,	#1			; if THRE is 1, proceed
			BNE 	LOOP			; else, loop

			LDR 	r4, =0xE000C000	; set r4 to base address of transmit register
			CMP 	r0, #0xD		; Compare r0 to carriage ret.
			BEQ 	NEWLINE			; If r0 is the carriage ret. character, branch to NEWLINE

			STRB 	r0, [r4]		; Stores the character from read_character into
									; the address at r4.
			B 		RETURN		 	; Branch to RETURN when done outputting character.
							
NEWLINE		MOV 	r0, #0xA		; In the case of return key, change read character
									; to new line
			STRB 	r0, [r4]		; Output the new line character
		
LOOP2		LDR 	r2, =0xE000C014	; r2 has the ULSR loaded into it
			LDRB 	r3, [r2]		; load contents from address into r3
			LSR 	r3, #5			; right shift 5 bits to read THRE bits
			AND 	r3, r3, #1		; AND r3 bits with 1 to see if THRE is 1

			CMP 	r3,	#1			; if THRE is 1, proceed
			BNE 	LOOP2			; else, loop
		
			MOV 	r0, #0xD		; Change the read character to carriage return
			STRB 	r0, [r4]		; Output the carriage return character.

RETURN		LDMFD sp!, {r2-r4,lr}
			BX lr

read_character	; read_character
			STMFD sp!, {r2-r4,lr}
	
			; Enter a character before entering the subroutine!
			; Otherwise, it continues looping until a character is entered.
			
REPEAT		LDR r2, =0xE000C014			; Load UART Line Status Register into r2
			LDRB r3, [r2]				; Load contents from address into r3
			AND r3, r3, #0x1			; AND r3 with #0x1 as a check to see if RDR is #0x1.

			CMP r3, #0x1				; Compare r2, #0x1
			BNE REPEAT					; If r2 != #0x1, RDR isn't 1, so loop back to INIT

			LDR r4, =0xE000C000			; Load UART Transmit & Receive Register into r4
			LDRB r0, [r4]				; Load contents from address
										; (i.e. the character entered) into r5
			BL output_character			; Output the read character
	
			LDMFD sp!, {r2-r4,lr}
			BX lr
			
output_string
			STMFD sp!, {lr,r0,r4}
		
NULL		LDRB 	r0, [r4], #0x1	   	; Read the character in the string, then
										; increment to the next character.
			BL 		output_character	; Branch to output_character.
			CMP 	r0, #0x0			; Compare the output character to null.
			BNE 	NULL				; If it isn't null, loop to read the next character.
										; If the output character was a null, done.
	
			LDMFD sp!, {lr,r0,r4}
			BX lr
			
read_string 	; read_string
 			STMFD sp!, {lr,r4}
	
READ		BL 		read_character		; Branch to read_character.
COMPARE		CMP 	r0, #0xD			; Compare read character in r0 to carriage ret.
			BEQ 	EOL					; If read character is enter, branch to ENTER.
			STRB 	r0, [r4], #0x1 		; Else store read character in r0 into the contents
										; at the address pointed to by r4, and increment
										; the base address by 0x1.
			B 		READ				; Loop to read another character.
		
EOL			MOV 	r0, #0x0			; Change the read character (return) to NULL char.
			STRB 	r0, [r4]			; Store NULL char. from r0 into the contents at
										; the address pointed to by r4.
			LDMFD sp!, {lr,r4}							
			BX lr

pin_connect_block_setup							; pinsel and iodir
		STMFD sp!, {r0-r2, lr}

		; Set up PINSEL0:
		; --> 1) Set P0.0 to 01 for UART0 Transmitter Output.
		; --> 2) Set P0.1 to 01 for UART0 Receiver Input.
		; --> 3) Set P0.7-P0.13 for GPIO.
		LDR r0, =PINSEL0						; r0 -> 0xE002C000
		LDR r1, [r0]							; Load contents of PINSEL0 into r1
		ORR r1, r1, #5							; Set bits 0 and 2 of PINSEL0
		BIC r1, r1, #0xA						; Clear bits 1 and 3 of PINSEL0
		MOV r2, #0x000000FF		   				; r2 = 0x0FFFC000
		MOV r2, r2, LSL #8						; ...
		ADD r2, r2, #0x000000FC					; ...
		MOV r2, r2, LSL #12						; ...
		BIC r1, r1, r2							; Set pins 7-13 to 00 for GPIO
		STR r1, [r0]							; Store r1 into contents of PINSEL0

		; Set direction for each pin configured for GPIO
		LDR r0, =IO0DIR							; r0 -> 0xE0028008
		LDR r1, [r0]							; Load contents of IO0DIR into r1
		MOV r2, #0x00000026						; r2 = #0x00263F80
		MOV r2, r2, LSL #8						; ...
		ADD r2, r2, #0x0000003F					; ...
		MOV r2, r2, LSL #8						; ...
		ADD r2, r2, #0x00000080					; ...
		ORR r1, r1, r2							; Set IO0DIR pins 7 to 13, 17, 18, 21 for output
		STR r1, [r0]							; Store r1 into contents of IO0DIR

		LDR r0, =IO1DIR							; r1 -> 0xE00280018
		LDR r1, [r0]							; Load contents of IO1DIR into r1
		MOV r2, #0x0000000F						; r2 = 0x000F0000
		MOV r2, r2, LSL #16						; ...
		ORR r1, r1, r2							; Set IO1DIR pins 16-19 for output
		
		STR r1, [r0]							; Store r1 into contents of IO1DIR 

		LDMFD sp!, {r0-r2, lr}
		BX lr
		
interrupt_init 
		STMFD SP!, {r0-r2, lr}   				; Save registers 
		
		; Push button setup		 
		LDR r0, =0xE002C000
		LDR r1, [r0]
		ORR r1, r1, #0x20000000
		BIC r1, r1, #0x10000000
		STR r1, [r0]  							; PINSEL0 bits 29:28 = 10

		; Classify sources as IRQ or FIQ
		LDR r0, =0xFFFFF000
		LDR r1, [r0, #0xC]
		MOV r2, #0x8000
		ADD r2, r2, #0x0070
		ORR r1, r1, r2 							; External Interrupt 1, UART0, Timer 0
		STR r1, [r0, #0xC]

		; Enable Interrupts
		LDR r0, =0xFFFFF000
		LDR r1, [r0, #0x10] 
		ORR r1, r1, r2 							; External Interrupt 1, UART0, Timer 0
		STR r1, [r0, #0x10]

		; External Interrupt 1 setup for edge sensitive
		LDR r0, =0xE01FC148
		LDR r1, [r0]
		ORR r1, r1, #2  						; EINT1 = Edge Sensitive
		STR r1, [r0]

		; Enable FIQ's, Disable IRQ's
		MRS r0, CPSR
		BIC r0, r0, #0x40
		ORR r0, r0, #0x80
		MSR CPSR_c, r0
		
		; UART0 Enable RDA
		LDR r0, =0xE000C004						; UART0 Interrupt Enable Register
		LDR r1, [r0]							; Load contents of UART0 Interrupt Enable Register into r1
		ORR r1, r1, #0x1						; Enable RDA (bit 0)
		STR r1, [r0]							; Store r1 into contents of UART0 Interrupt Enable Register
		
		; Load value into Timer 0 Match Register 1
		LDR r0, =0xE000401C						; Match Register 1 (T0MR1)
		MOV r1, #0x00800000						; Takes 0x008CA000 counts for 0.5 secs.
		ADD r1, r1, #0x000C0000					; ...	
		ADD r1, r1, #0x0000A000					; ...
		STR r1, [r0]							; Set period of MR1 to 0.5s.
		
		; Load value into Timer 1 Match Register 2
		LDR r0, =0xE000801C						; Match Register 2 (T1MR1)
		MOV r1, #0x83000000						; Takes #0x83D60000 counts for 2 minutes.
		ADD r1, r1, #0x00D60000					; ...
		STR r1, [r0]							; Set period of MR2 to 2 minutes.
		
		; Enable Timer 0
		LDR r0, =0xE0004004						; Timer 0 Timer Control Register (T0TCR)
		LDR r1, [r0]							; Load contents of T0TCR into r1
		ORR r1, r1, #0x1						; Set bit 0 to 1 to Enable Timer 0.
		STR r1, [r0]							; Store r1 into contents of T0TCR
		
		; Enable Timer 1
		LDR r0, =0xE0008004						; Timer 1 Timer Control Register (T1TCR)
		LDR r1, [r0]							; Load contents of T1TCR into r1
		ORR r1, r1, #0x1						; Set bit 0 to 1 to Enable Timer 1
		STR r1, [r0]							; Store r1 into contents of T1TCR
		
		; Enable Match Control Register to interrupt and reset when Timer 0 Count == Match Register 1
		LDR r0, =0xE0004014						; Timer 0 Match Control Register (T0MCR)
		LDR r1, [r0]							; Load contents of T0MCR into r1
		ORR r1, r1, #0x18						; Set bits 3 and 4 to 1 to enable Timer 0 to reset and interrupt
												; when Timer Count 0 == Match Register 1
		STR r1, [r0]							; Store r1 into contents of T0MCR
		
		; Enable Match Control Register to interrupt and reset when Timer 1 Count == Match Register 2
		LDR r0, =0xE0008014						; Timer 1 Match Control Register (T1MCR)
		LDR r1, [r0]							; Load contents of T1MCR into r1.
		ORR r1, r1, #0x18						; Set bits 3 and 4 to 1 to enable Timer 1 to reset and interrupt
												; when Timer Count 1 == Match Register 2
		STR r1, [r0]							; Store r1 into contents of T1MCR
		
		LDMFD SP!, {r0-r2, lr} 					; Restore registers
		BX lr             	   					; Return
		
uart_init
	STMFD sp!, {r0,r1,lr}

	; 8-bit word length, 1 stop bit, no parity
	; Disable break control
	; Enable divisor latch access
	MOV r0, #0x83			; r0 = 1000 0011			
	LDR r1, =0xE000C00C		; r1 points to 0xE000C00C
	STRB r0, [r1]			; 0xE000C00C = 1000 0011

	; Set lower divisor latch for 115,200 baud
	MOV r0, #0xA			; r0 = 0111 1000
	LDR r1, =0xE000C000		; r1 points to 0xE000C000
	STRB r0, [r1]			; 0xE000C000 = 0111 1000

	; Set upper divisor latch for 115,200 baud
	MOV r0, #0x0			; r0 = 0000 0000
	LDR r1, =0xE000C004		; r1 points to 0xE000C004
	STRB r0, [r1]			; 0xE000C004 = 0000 0000
	
	; 8-bit word length, 1 stop bit, no parity
	; Disable break control
	; Disable divisor latch access
	MOV r0, #0x3			; r0 = 0000 0011
	LDR r1, =0xE000C00C 	; r1 points to 0xE000C00C
	STRB r0, [r1]			; 0xE000C00C = 0000 0011

	LDMFD sp!, {r0,r1,lr}
	BX lr
	
	END