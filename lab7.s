	AREA interrupts, CODE, READWRITE
	EXPORT lab7
	EXPORT FIQ_Handler
	EXTERN output_string
	EXTERN output_character
	EXTERN read_character
	EXTERN uart_init
	EXTERN div_and_mod
	EXTERN set_board_hardware
	EXTERN pin_connect_block_setup
	EXTERN interrupt_init
	EXTERN set_lives
	EXTERN set_RGB_led

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
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------	
start = 0xA,0xD,"Press the return key to initialize the program... ",0

row0 = 0xD,"           _____                                   ",0
row1 = 0xD,"          /***Q/|                                  ",0
row2 = 0xD,"         /****/ |_____                             ",0
row3 = 0xD,"         |¯¯¯¯| /****/|                            ",0
row4 = 0xD,"         |____|/****/ |_____                       ",0
row5 = 0xD,"         /****/|¯¯¯¯| /****/|                      ",0
row6 = 0xD,"        /****/ |____|/****/ |_____                 ",0
row7 = 0xD,"        |¯¯¯¯| /****/|¯¯¯¯| /****/|                ",0
row8 = 0xD,"        |____|/****/ |____|/****/ |_____           ",0
row9 = 0xD,"        /****/|¯¯¯¯| /****/|¯¯¯¯| /****/|          ",0
row10 = 0xD,"       /****/ |____|/****/ |____|/****/ |_____     ",0
row11 = 0xD,"       |¯¯¯¯| /****/|¯¯¯¯| /****/|¯¯¯¯| /****/|    ",0
row12 = 0xD,"       |____|/****/ |____|/****/ |____|/****/ |    ",0
row13 = 0xD,"       /****/|¯¯¯¯| /****/|¯¯¯¯| /****/|¯¯¯¯| /    ",0
row14 = 0xD,"      /****/ |____|/****/ |____|/****/ |____|/     ",0
row15 = 0xD,"      |¯¯¯¯| /****/|¯¯¯¯| /****/|¯¯¯¯| /           ",0
row16 = 0xD,"      |____|/****/ |____|/****/ |____|/            ",0
row17 = 0xD,"      /****/|¯¯¯¯| /****/|¯¯¯¯| /                  ",0
row18 = 0xD,"     /****/ |____|/****/ |____|/                   ",0
row19 = 0xD,"     |¯¯¯¯| /****/|¯¯¯¯| /                         ",0
row20 = 0xD,"     |____|/****/ |____|/                          ",0
row21 = 0xD,"     /****/|¯¯¯¯| /                                ",0
row22 = 0xD,"    /****/ |____|/                                 ",0
row23 = 0xD,"    |¯¯¯¯| /                                       ",0
row24 = 0xD,"    |____|/                                        ",0
		ALIGN
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------			
gamestate DCB 0x00								; Used for determining the current game state.
	ALIGN										; --> Current game state values:	0 = Not Initialized.
												;									1 = Game is running.
												; 									2 = Game has ended.
												;									3 = Game is paused.

currentenemy 		DCB	0x00					; Used for determining the next enemy type to place on the board.
	ALIGN
currentlevel 		DCB 0x00					; Used for determining the current level the user is on.
	ALIGN
currentlives 		DCB 0x04					; Used for determining the number of lives the user has left.
	ALIGN
currentpoints		DCD 0x00000000				; Used for determining how many points the player current has.
	ALIGN
flashRGBred 		DCB 0x00					; Flag used for detecting whether or not we need to flash the RGB
	ALIGN										; led RED because a life was lost.

programinitialized 	DCB 0x00					; Used for detecting whether the program is initialized or not.
	ALIGN
firstscreenprinted	DCB 0x00					; Used for detecting whether the screen has been printed a first time or not.
	ALIGN
randomtimer 		DCD	0x00000000				; Used for storing a random timer value.
	ALIGN
ledblinkercounter	DCB 0x00					;used for determining and displaying a life lost blinker
	ALIGN
spawnenemycounter	DCB 0x00					; Used for detecting whether an enemy should be spawned.
	ALIGN										; --> If it reaches 3, then an enemy should spawn.
												; --> Increases everytime timer 0 resets.
;Q-Bert's Coordinates
qbertdirection 		DCB 0x04					; Used for storing the current direction.
												; --> 0 = Up
												; --> 1 = Down
												; --> 2 = Left
												; --> 3 = Right
												; --> 4 = IMMOBILE.
	ALIGN
qbertcurrentx 		DCB 0x0E					; Used for determing the current x position of qbert.
	ALIGN
qbertcurrenty 		DCB 0x01					; Used for determining the current y position of qbert.
	ALIGN
qbertpreviousx		DCB 0x0E					; Used for determining the previous x position of qbert.
	ALIGN
qbertpreviousy 		DCB 0x01					; Used for determining the previous y position of qbert.
	ALIGN

;Snake's Coordinates
snakedirection		DCB 0x00					; Used for storing the current direction of the snake.
												; --> 0 = Up
												; --> 1 = Down
												; --> 2 = Left
												; --> 3 = Right
												; --> 4 = IMMOBILE.
	ALIGN
snakecurrentx 		DCB 0x00					; Used for determing the current x position of the snake.
	ALIGN
snakecurrenty 		DCB 0x00					; Used for determining the current y position of the snake.
	ALIGN
snakepreviousx 		DCB 0x00					; Used for determining the previous x position of the snake.
	ALIGN
snakepreviousy 		DCB 0x00					; Used for determining the previous y position of the snake.
	ALIGN
snaketransformflag	DCB 0x01					; Used for determining whether the direction of the snake has to stay
												; immobile for one refresh.
	ALIGN
;Snake ball's Coordinates
sballdirection		DCB 0x00					; Used for storing the current direction of the snake ball.
												; --> 0 = Up
												; --> 1 = Down
												; --> 2 = Left
												; --> 3 = Right
												; --> 4 = IMMOBILE.
	ALIGN
sballcurrentx 		DCB 0x00					; Used for determing the current x position of the snake ball.
	ALIGN
sballcurrenty 		DCB 0x00					; Used for determining the current y position of the snake ball.
	ALIGN
sballpreviousx 		DCB 0x00					; Used for determining the previous x position of the snake ball.
	ALIGN
sballpreviousy 		DCB 0x00					; Used for determining the previous y position of the snake ball.
	ALIGN

;Normal ball #1's Coordinates
nball1direction		DCB 0x00					; Used for storing the current direction of the normal ball #1.
												; --> 0 = Up
												; --> 1 = Down
												; --> 2 = Left
												; --> 3 = Right
												; --> 4 = IMMOBILE.
	ALIGN
nball1currentx 		DCB 0x00					; Used for determing the current x position of the normal ball #1.
	ALIGN
nball1currenty 		DCB 0x00					; Used for determining the current y position of the normal ball #1.
	ALIGN
nball1previousx 	DCB 0x00					; Used for determining the previous x position of the normal ball #1.
	ALIGN
nball1previousy 	DCB 0x00					; Used for determining the previous y position of the normal ball #1.
	ALIGN
	
;Normal ball #2's Coordinates
nball2direction		DCB 0x00					; Used for storing the current direction of the normal ball #2.
												; --> 0 = Up
												; --> 1 = Down
												; --> 2 = Left
												; --> 3 = Right
												; --> 4 = IMMOBILE.
	ALIGN
nball2currentx 		DCB 0x00					; Used for determing the current x position of the normal ball #2.
	ALIGN
nball2currenty 		DCB 0x00					; Used for determining the current y position of the normal ball #2.
	ALIGN
nball2previousx 	DCB 0x00					; Used for determining the previous x position of the normal ball #2.
	ALIGN
nball2previousy 	DCB 0x00					; Used for determining the previous y position of the normal ball #2.
	ALIGN
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------		
lab7	 	
		STMFD sp!, {lr}
		
		;begin test for 5.4
		MOV r0, #0
		ADD r0, r0, #0x7F000000
		ADD r0, r0, #0x00A30000
		ADD r0, r0, #0x0000FC00
		ADD r0, r0, #0x000000FF
		LDR r1, =randomtimer
		STR r0, [r1]
		LDRSH r2, [r1, #2]
		;end test for 5.4
		
		BL pin_connect_block_setup				; Initialize PINSEL0 for UART0 I/O
		BL uart_init							; Initialize the UART
		
		BL interrupt_init						; Initialize the timers and interrupts.
		
		; Load arguments for set_board_hardware
		LDR r0, =currentlevel
		LDRB r1, [r0]							; Load currentlevel into r1
		
		LDR r0, =currentlives
		LDRB r2, [r0]							; Load currentlives into r2
		
		LDR r0, =gamestate
		LDRB r3, [r0]							; Load gamestate into r3
		
		BL set_board_hardware					; Set the hardware on the board to their initial states.
		
		LDR r4, =start
		BL output_string
		B DONE
		
EXIT	; Used for quitting the program.
		; Disable interrupts.
		MOV r2, #0x8000
		ADD r2, r2, #0x0070
		LDR r0, =0xFFFFF000
		LDR r1, [r0, #0x10]
		BIC r1, r1, r2 							; External Interrupt 1, UART0, Timer 0, Timer 1
		STR r1, [r0, #0x10]	
		
		LDMFD sp!, {r0-r12,lr}					; Restore registers (2)		
		LDMFD sp!, {r0-r12,lr}					; Restore registers (1)
		BX lr
		
DONE	LDMFD sp!,{lr}
		BX lr 
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------
FIQ_Handler
		STMFD SP!, {r0-r12, lr}   				; Save registers (1)
		
		; Check for EINT1 interrupt
		LDR r0, =0xE01FC140						; Load EINT1 address.
		LDR r1, [r0]							; Load EINT1 contents into r1.
		TST r1, #2								; Test bit 1 to see if it's set.
		BEQ UART0								; If bit 1 is set, then Z flag is set (interrupt pending).
												; If bit 1 is not set, then Z flag is not set (no interrupt).
			
		; Push button EINT1 Handling Code
		;BL eint1_handle
		; End push button EINT1 Handling Code
		
		; Check for UART0 interrupt
UART0	LDR r0, =0xE000C008						; Load UART0 Interrupt Identification Register address.
		LDR r1, [r0]							; Load UART0 Interrupt Identification Register contents into r1.
		TST r1, #0x00000001						; Test bit 1 to see if it's set.
	   	BNE T0IR								; If bit 1 is set, then Z flag is set (no interrupt).
												; If bit 1 is not set, then Z flag is not set (interrupt pending.).

		; Keyboard input UART0 Handling Code
		BL uart0_handle		
		; End keyboard input UART0 Handling Code
		
		; Check for T0IR Interrupt
T0IR	LDR r0, =0xE0004000						; Load T0IR address.
		LDR r1, [r0]							; Load T0IR contents into r1.
		TST r1, #2								; Test bit 1 to see if it's set.
		BEQ T1IR								; If bit 1 is set, then Z flag is set (interrupt pending).
												; If bit 1 is not set, then Z flag is not set (no interrupt).
		
		; Timer 0 T0IR Handling Code
		BL t0ir_handle
		; End Timer 0 T0IR Handling Code
		
		; Check for T1IR Interrupt
T1IR	LDR r0, =0xE0008000						; Load T1IR address.
		LDR r1, [r0]							; Load T1IR contents into r1.
		TST r1, #2								; Test bit 1 to see if it's set.
		BEQ FIQ_EXIT							; If bit 1 is set, then Z flag is set (interrupt pending).
												; If bit 1 is not set, then Z flag is not set (no interrupt).
									
		; Timer 1 T1IR Handling Code
		BL t1ir_handle
		; End Timer 1 T1IR Handling Code

FIQ_EXIT
		LDMFD SP!, {r0-r12, lr}					; Restore registers (1)
		SUBS pc, lr, #4
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------		
uart0_handle
		STMFD SP!, {r0-r12, lr}				; Save registers (2)
		
		; Store a random value used for various purposes (timing of uart interrupt is most random of all interrupts).
		LDR r0, =randomtimer
		LDR r1, =0xE0008008
		LDR r2, [r1]
		STR r2, [r0]
		
		; Check programinitialized.
		LDR r0, =programinitialized			
		LDRB r1, [r0]
		CMP r1, #0x1
		
		; If programinitialized is set, jump to RUNNING (Case 2).
		BEQ RUNNING
		
		; Otherwise, handle the interrupt (check for a spacebar, or return key, ignore all other input).
		BL read_character
		CMP r0, #0x20						; Check if the input is a space.
		BEQ EXIT							; If so, terminate the program
		
		CMP r0, #0xD						; Check if the input is a carriage return
		BNE UART0_HANDLED					; If input is a carriage return, update the character/direction/position
											; for the timer interrupt.
		
		; Set programinitialized
		LDR r0, =programinitialized
		MOV r1, #0x1
		STRB r1, [r0]
		
		; Reset timers 0 and 1 so that we are measuring the proper values for 0.5s and 2m respectively.
		; Reset Timer 0
		LDR r0, =0xE0004004						; Timer 0 Timer Control Register (T0TCR).
		LDR r1, [r0]							; Load contents of T0TCR into r1.
		ORR r1, r1, #0x2						; Set bit 1 to 1 to reset Timer 1.
		STR r1, [r0]							; Store r1 into contents of T0TCR.
		
		; Reset Timer 1
		LDR r0, =0xE0008004						; Timer 1 Timer Control Register (T1TCR).
		LDR r1, [r0]							; Load contents of T1TCR into r1.
		ORR r1, r1, #0x2						; Set bit 1 to 1 to reset Timer 1.
		STR r1, [r0]							; Store r1 into contents of T1TCR.
		
		; Reset Timer 0
		LDR r0, =0xE0004004						; Timer 0 Timer Control Register (T0TCR).
		LDR r1, [r0]							; Load contents of T0TCR into r1.
		BIC r1, r1, #0x2					    ; Set bit 1 to 0 to reset Timer 1.
		STR r1, [r0]							; Store r1 into contents of T0TCR.
		
		; Reset Timer 1
		LDR r0, =0xE0008004						; Timer 1 Timer Control Register (T1TCR).
		LDR r1, [r0]							; Load contents of T1TCR into r1.
		BIC r1, r1, #0x2					    ; Set bit 1 to 0 to reset Timer 1.
		STR r1, [r0]							; Store r1 into contents of T1TCR.
		
		B UART0_HANDLED

RUNNING	; Case 2: programinitialized is set.
		; --> Check for SPACEBAR/W/A/S/D.
		; Ignore other inputs.
		
		BL read_character					; Read the input character.
		LDR r1, =qbertdirection				; Load the qbertdirection address
		
		CMP r0, #0x20						; Check if the input is a space.
		BEQ EXIT							; If so, terminate the program.
		
		CMP r0, #0x77						; Check if the input is a 'w'
		BNE ONE								; If not, check if the input is 'W'
		MOV r2, #0x0						; Otherwise, store a 0 (up) in direction.
		STRB r2, [r1]						; ...
		B UART0_HANDLED

ONE		CMP r0, #0x57						; Check if the input is a 'W'
		BNE TWO								; If not, check if the input is 'a'
		MOV r2, #0x0						; Otherwise, store a 0 (up) in direction.
		STRB r2, [r1]						; ...
		B UART0_HANDLED
		
TWO		CMP r0, #0x61						; Check if the input is a 'a'
		BNE THREE							; If not, check if the input is 'A'
		MOV r2, #0x2						; Otherwise, store a 2 (left) in direction.
		STRB r2, [r1]						; ...
		B UART0_HANDLED
		
THREE	CMP r0, #0x41						; Check if the input is a 'A'
		BNE FOUR							; If not, check if the input is 's'
		MOV r2, #0x2						; Otherwise, store a 2 (left) in direction.
		STRB r2, [r1]						; ...
		B UART0_HANDLED
		
FOUR	CMP r0, #0x73						; Check if the input is a 's'
		BNE FIVE							; If not, check if the input is 'S'
		MOV r2, #0x1						; Otherwise, store a 1 (down) in direction.
		STRB r2, [r1]						; ...
		B UART0_HANDLED
		
FIVE	CMP r0, #0x53						; Check if the input is a 'S'
		BNE SIX								; If not, check if the input is 'd'
		MOV r2, #0x1						; Otherwise, store a 1 (down) in direction.
		STRB r2, [r1]						; ...
		B UART0_HANDLED
		
SIX		CMP r0, #0x64						; Check if the input is a 'd'
		BNE SEVEN							; If not, check if the input is 'D'
		MOV r2, #0x3						; Otherwise, store a 3 (right) in direction.
		STRB r2, [r1]						; ...
		B UART0_HANDLED
		
SEVEN	CMP r0, #0x44						; Check if the input is a 'D'
		BNE UART0_HANDLED					; If not, the input is invalid. ignore.
		MOV r2, #0x3						; Otherwise, store a 3 (right) in direction.
		STRB r2, [r1]						; ...
		
UART0_HANDLED ; uart0 interrupt automatically resets.
		LDMFD SP!, {r0-r12, lr}	
		BX lr
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------		
t0ir_handle
		STMFD SP!, {r0-r12, lr}

		; Check programinitialized.
		LDR r0, =programinitialized				; Load programinitialized address.
		LDRB r1, [r0]							; Load contents at address programinitialized.
		CMP r1, #0x1							; Check if r1 != 1.
		BNE T0IR_HANDLED						; If so, user hasn't initialized the program, ignore the interrupt.
												; Otherwise, handle the interrupt.
		
		; Add 1 to spawnenemycounter to keep track of when to spawn an enemy.
		LDR r0, =spawnenemycounter				; Load the address of spawnenemycounter.
		LDRB r1, [r0]							; Load the contents of spawnenemycounter.
		CMP r1, #0x3							; Check if spawnenemycounter is 3.
		BNE ADDSPAWN							; If not, add 1 to the counter.
												; Otherwise, spawn an enemy.
		
		; Choose enemy
		BL choose_enemy							; Returns the chosen enemy type in r9.
												; --> 0x1 = Normal Ball 1
												; --> 0x2 = Normal Ball 2
												; --> 0x3 = Snake Ball
		
		; Choose direction
		BL choose_direction						; Use the enemy type in r9 to set the proper direction.
		
		; Spawn the enemy at the top block. NOTE: may seem counterintuitive, but the enemy will not be placed until after the position is updated!
		; --> Spawn the enemy at the top block
		; --> Update the position of the enemy (now the enemy will be at the second row)
		; --> Set the position (THIS IS WHERE THE ENEMY GETS PLACED ON THE BOARD! Thus at this point the enemy is physically on the board).
		BL spawn_enemy							; Use the enemy type in r9 to set the proper enemy to spawn.
		
		; Reset spawnenemycounter
		LDR r0, =spawnenemycounter				; Load the address of spawnenemycounter
		MOV r1, #0x0							; Set r1 to 0x0.
		STRB r1, [r0]							; Store r1 into the contents of addres spawnenemycounter
		B CHECK									
		
ADDSPAWN
		ADD r1, r1, #0x1
		STRB r1, [r0]
		
		; Check firstscreenprinted.
CHECK	LDR r0, =firstscreenprinted				; Load firstscreenprinted address.
		LDRB r1, [r0]							; Load contents at address firstscreenprinted.
		CMP r1, #0x1							; Check if r1 != 1.
		BNE PRINT								; If so, the first screen hasn't been printed yet. Skip updating the
												; position before printing the box out.
												; Otherwise, the initial box has been printed already. Update the position
												; before printing.
		LDR r0, =ledblinkercounter
		LDRB r1, [r0]
		CMP r1, #0x0
		BEQ NO_LED_BLINKS_NEEDED
		BIC r2, r1, #0xFFFFFFFE
		SUB r1, r1, #0x00000001
		STRB r1, [r0]
		CMP r2, #0x1
		BEQ TURN_OFF_LED
		BL turn_on_led_red
		B LED_HANDLED
TURN_OFF_LED
		BL turn_off_led
		B LED_HANDLED
NO_LED_BLINKS_NEEDED
		LDR r0, =gamestate
		LDRB r3, [r0]
		BL set_RGB_led
LED_HANDLED
		
		; Update the position of qbert.
		LDR r4, =qbertdirection					; Load address of qbertdirection.
		LDR r5, =qbertcurrentx					; Load address of qbertcurrentx.
		LDR r6, =qbertpreviousx					; Load address of qbertpreviousx.
		LDR r7, =qbertcurrenty					; Load address of qbertcurrenty.
		LDR r8, =qbertpreviousy					; Load address of qbertpreviousy.
		MOV r9, #0x0							; Set r9 to qbert.
		BL update_position						; Update the position of qbert.
		
												;do blinker status for the loss of lives

		; Update the position of nball1.
		; --> Check to see if nball1 exists (currentx is not 0x00)
		;	  --> If so, update the position.
		;     --> Otherwise, SKIP.
		
		; Check to see if nball1exists (currentx is not 0x00)
		LDR r5, =nball1currentx					; Load address of nball1currentx.
		LDRB r9, [r5]							; Load contents of nball1currentx into r9.
		CMP r9, #0x0							; Check to see if nball1currentx is 0x00.
		BEQ UPDATE2
		
		LDR r4, =nball1direction				; Load address of nball1direction.
		LDR r6, =nball1previousx				; Load address of nball1previousx.
		LDR r7, =nball1currenty					; Load address of nball1currenty.
		LDR r8, =nball1previousy				; Load address of nball1previousy.
		MOV r9, #0x1							; Set r9 to nball1.
		BL choose_direction
		BL update_position
		
		; Check to see if nball2exists (currentx is not 0x00)
UPDATE2	LDR r5, =nball2currentx					; Load address of nball2currentx.
		LDRB r9, [r5]							; Load contents of nball2currentx into r9.
		CMP r9, #0x0							; Check to see if nball2currentx is 0x00.
		BEQ UPDATE3
		
		LDR r4, =nball2direction				; Load address of nball2direction.
		LDR r6, =nball2previousx				; Load address of nball2previousx.
		LDR r7, =nball2currenty					; Load address of nball2currenty.
		LDR r8, =nball2previousy				; Load address of nball2previousy.
		MOV r9, #0x2							; Set r9 to nball2.
		BL choose_direction
		BL update_position
		
		; Check to see if sballexists (currentx is not 0x00)
UPDATE3	LDR r5, =sballcurrentx					; Load address of sballcurrentx.
		LDRB r9, [r5]							; Load contents of sballcurrentx into r9.
		CMP r9, #0x0							; Check to see if sballcurrentx is 0x00.
		BEQ UPDATE4
		
		LDR r4, =sballdirection					; Load address of sballdirection.
		LDR r6, =sballpreviousx					; Load address of sballpreviousx.
		LDR r7, =sballcurrenty					; Load address of sballcurrenty.
		LDR r8, =sballpreviousy					; Load address of sballpreviousy.
		MOV r9, #0x3							; Set r9 to sball.
		BL choose_direction
		BL update_position
		
		; Check to see if snake exists (currentx is not 0x00)
UPDATE4	LDR r5, =snakecurrentx					; Load address of sballcurrentx.
		LDRB r9, [r5]							; Load contents of sballcurrentx into r9.
		CMP r9, #0x0							; Check to see if sballcurrentx is 0x00.
		BEQ PRINT
		
		LDR r4, =snakedirection					; Load address of sballdirection.
		LDR r6, =snakepreviousx					; Load address of sballpreviousx.
		LDR r7, =snakecurrenty					; Load address of sballcurrenty.
		LDR r8, =snakepreviousy					; Load address of sballpreviousy.
		MOV r9, #0x4							; Set r9 to snake.
		BL choose_snake_direction
		BL update_position
		
		; Print the box out.
PRINT	BL print_screen						
		
		; The box has been printed out at least once. Set the flag to 1.
		LDR r0, =firstscreenprinted				; Load firstscreenprinted address.
		MOV r1, #0x1							; Set the firstscreenprinted flag to 1.
		STR r1, [r0]							; ...
		
T0IR_HANDLED
		; Clear the interrupt
		LDR r0, =0xE0004000						; Load address of T0IR
		LDR r1, [r0]							; Load contents of T0IR
		ORR r1, r1, #2							; Set bit 1 to 1.
		STR r1, [r0]							; Write a 1 to bit 1 in order to clear the timer 0 interrupt.
		
		LDMFD SP!, {r0-r12, lr}
		BX lr
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------
choose_snake_direction

		; Chooses a direction for the snake such that the snake will head towards qbert.
		; Algorithm: 1) Take qbertcurrentx - snakecurrentx = differencex
		;			 2) Take qbertcurrenty - snakecurrenty = differencey
		;            3) Go up if differencex is positive and differencey is negative.
		;            4) Go down if differencex is negative and differencey is positive.
		;			 5) Go left if both differencex and differencey are negative.
		;            6) Go right if both differencex and differencey are positive.
		
		STMFD sp!, {r0-r7,lr}
		
		LDR r6, =snaketransformflag
		LDRB r7, [r6]
		CMP r7, #0x1
		BEQ TRANSF
		LDR r5, =snakedirection
		
		LDR r0, =qbertcurrentx
		LDRB r1, [r0]
		LDR r0, =snakecurrentx
		LDRB r2, [r0]
		LDR r0, =qbertcurrenty
		LDRB r3, [r0]
		LDR r0, =snakecurrenty
		LDRB r4, [r0]
		
		; At this point, r1 = qbertcurrentx, r2 = snakecurrentx, r3 = qbertcurrenty, r4 = snakecurrenty
		
		SUB r1, r1, r2							; r1 = differencex = qbertcurrentx - snakecurrentx
		SUB r3, r3, r4							; r3 = differencey = qbertcurrenty - snakecurrenty
		
		CMP r1, #0x0
		BLT LFTDN								; differencex is negative, the snake has to either go left or down
		BEQ IMM									; differencex is zero, the snake has eaten qbert (immobile)
		BGT UPRGT								; differencex is positive, the snake has to either go up or right
		
LFTDN	CMP r3, #0x0
		BLT LFT									; differencex is negative, and differencey is negative, the snake goes left
		BGT	DN									; differencex is negative, and differencey is positive, the snake goes down
		
		; Otherwise, same row, can go left or down.
		LDR r1, =0xE0008008
		LDR r0, [r1]
		MOV r2, #0xFF000000
		ADD r2, r2, #0xFF0000
		BIC r0, r0, r2							; Clear bits 16-23 (need to have a 16-bit value).
		MOV r1, #0x2
		BL div_and_mod
		
		CMP r1, #0x0							; If remainder is 0, we go left.
		BNE DN
LFT		MOV r3, #0x2							
		STRB r3, [r5]
		B CHSN
		
DN		MOV r3, #0x1							; Otherwise, we go down.
		STRB r3, [r5]
		B CHSN
		
UPRGT	CMP r3, #0x0
		BLT UP									; differencex is positive, and differencey is negative, the snake goes up
		BGT RGT									; differencex is positive, and differencey is positive, the snake goes right
		
		; Otherwise, same row, can go up or right.
		LDR r1, =0xE0008008
		LDR r0, [r1]
		MOV r2, #0xFF000000
		ADD r2, r2, #0xFF0000
		BIC r0, r0, r2							; Clear bits 16-23 (need to have a 16-bit value).
		MOV r1, #0x2
		BL div_and_mod
		
		CMP r1, #0x0							; If remainder is 0, we go up.
		BNE RGT
UP		MOV r3, #0x0							
		STRB r3, [r5]
		B CHSN
		
RGT		MOV r3, #0x3							; Otherwise, we go right.
		STRB r3, [r5]
		B CHSN

IMM		MOV r3, #0x4
		STRB r3, [r5]
		B CHSN
		
TRANSF  MOV r7, #0x0
		STRB r7, [r6]
		
CHSN	LDMFD sp!, {r0-r7,lr}
		BX lr
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------
choose_direction

		; Chooses a direction for the ball enemy.
		
		STMFD sp!, {r0-r3,lr}
		
		; Check r9 to see which direction to change.
		CMP r9, #0x1
		BNE NOPE
		LDR r2, =nball1direction
		B DIRECT
		
NOPE	CMP r9, #0x2
		BNE NOPE2
		LDR r2, =nball2direction
		B DIRECT
		
NOPE2	LDR r2, =sballdirection
		
		; Check randomtimer to see which direction to choose.
DIRECT	LDR r1, =0xE0008008				; Load the saved random timer value from memory.
		LDR r0, [r1]						; Random timer value is set as dividend.
		MOV r3, #0xFF000000
		ADD r3, r3, #0xFF0000
		BIC r0, r0, r3						; Clear bits 16-23 (need to have a 16-bit value).
		
		MOV r1, #0x8						; 2 is set as the divisor
		BL div_and_mod						; Divide the random timer value by 2.
											; Quotient returned in r0, remainder in r1.
		
		CMP r1, #0x0						; Check if the remainder is 0.
		BNE DOWN1
		MOV r0, #0x1						; If so, the direction is down.
		STRB r0, [r2]						; Store the new direction.
		B YES
		
DOWN1	CMP r1, #0x3
		BNE DOWN2
		MOV r0, #0x1
		STRB r0, [r2]
		B YES
		
DOWN2	CMP r1, #0x4
		BNE DOWN3
		MOV r0, #0x1
		STRB r0, [r2]
		B YES
		
DOWN3	CMP r1, #0x7
		BNE RIGHT
		MOV r0, #0x1
		STRB r0, [r2]
		B YES
		
RIGHT	MOV r0, #0x3						; Otherwise, the direction is right.
		STRB r0, [r2]						; Store the new direction.
		
YES		LDMFD sp!, {r0-r3,lr}
		BX lr
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------
spawn_enemy
		
		; Spawns the enemy at the top block (14,1).
		; Note: Only sets the coordinates. Does not place the enemy on the board yet. 
		
		STMFD sp!, {r0-r1,lr}
		
		CMP r9, #0x1
		BNE NORMAL2
		
		LDR r0, =nball1currentx
		MOV r1, #0xE
		STRB r1, [r0]
		
		LDR r0, =nball1currenty
		MOV r1, #0x1
		STRB r1, [r0]
		
		B SPAWNED
		
NORMAL2	CMP r9, #0x2
		BNE SNAKE
		
		LDR r0, =nball2currentx
		MOV r1, #0xE
		STRB r1, [r0]
		
		LDR r0, =nball2currenty
		MOV r1, #0x1
		STRB r1, [r0]
		
		B SPAWNED
		
SNAKE	LDR r0, =sballcurrentx
		MOV r1, #0xE
		STRB r1, [r0]
		
		LDR r0, =sballcurrenty
		MOV r1, #0x1
		STRB r1, [r0]
		
SPAWNED	LDMFD sp!, {r0-r1,lr}
		BX lr
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------
choose_enemy
		
		; Returns an enemy type in r9.
		; --> 0x1 = Normal Ball 1
		; --> 0x2 = Normal Ball 2
		; --> 0x3 = Snake Ball
		
		STMFD sp!, {r0-r2,lr}
		
		; Check randomtimer to see which enemy to choose.
		LDR r1, =0xE0008008					; Load the saved random timer value from memory.
		LDR r0, [r1]						; Random timer value is set as dividend.
		MOV r2, #0xFF000000
		ADD r2, r2, #0xFF0000
		BIC r0, r0, r2						; Clear bits 16-23 (need to have a 16-bit value).
		
		MOV r1, #0x6						; 6 is set as the divisor
		BL div_and_mod						; Divide the random timer value by 6.
											; Quotient returned in r0, remainder in r1.
											
		; Snake Ball Case 1: Remainder is 0.
		CMP r1, #0x0						; Check if the remainder is 0.
		BNE CASE2							; If not, go to the next case.
		
		; Check if the snake exists. If so, choose a normal ball.
		LDR r1, =snakecurrentx
		LDRB r0, [r1]
		CMP r0, #0x0
		BNE NBALL
		
		; Check if the snake ball already exists. If so, choose a normal ball.
		LDR r1, =sballcurrentx				; Load the address of sballcurrentx
		LDRB r0, [r1]						; Load the contents of sballcurrentx
		CMP r0, #0x0						; Compare sballcurrentx to 0x0 to see if it exists.
		BNE NBALL							; If sballcurrentx is not 0x0, that means it is already on the board. Choose a normal ball for the enemy.
		
		MOV r9, #0x3						; Otherwise, the enemy is a snake ball.
		B ECHOSEN
		
		; Snake Ball Case 2: Remainder is 4.
CASE2	CMP r1, #0x4						; Check if the remainder is 4.
		BNE NBALL							; If not, go to the next case.
		
		; Check if the snake ball already exists. If so, choose a normal ball.
		LDR r1, =snakecurrentx
		LDRB r0, [r1]
		CMP r0, #0x0
		BNE NBALL
		
		; Check if the snake ball already exists. If so, choose a normal ball.
		LDR r1, =sballcurrentx				; Load the address of sballcurrentx
		LDRB r0, [r1]						; Load the contents of sballcurrentx
		CMP r0, #0x0						; Compare sballcurrentx to 0x0 to see if it exists.
		BNE NBALL							; If sballcurrentx is not 0x0, that means it is already on the board. Choose a normal ball for the enemy.
		
		MOV r9, #0x3						; Otherwise, the enemy is a snake ball.
		B ECHOSEN
		
		; Otherwise, the enemy is a normal ball.
		; Check if normal ball 1 exists. If so, use normal ball 2.	
NBALL	LDR r1, =nball1currentx				; Load the address of nball1currentx.
		LDRB r0, [r1]						; Load the contents of nball1currentx
		CMP r0, #0x0						; Compare nball1currentx to 0x0 to see if it exists.
		BNE NBALL2							; If nball1currentx is not 0x0, that means it is already on the board. Choose normal ball 2 for the enemy.
		
		MOV r9, #0x1						; Otherwise, the enemy is normal ball 1.
		B ECHOSEN							
		
NBALL2  MOV r9, #0x2						; Otherwise, the enemy is normal ball 2.
											
ECHOSEN	LDMFD sp!, {r0-r2,lr}
		BX lr
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------		
t1ir_handle
		STMFD SP!, {r0-r12, lr}
		
		; TODO
		; Ends the game (timer 1 only interrrupts when it reaches the 2 minute mark)
		
		LDMFD SP!, {r0-r12, lr}
		BX lr
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------		
update_position		; I) Used to update the current position of a character to a new current position.
					; 		A) Save the currentx and currenty values into previousx and previousy.
					;		B) Update the currentx and currenty values based on direction.
					;		C) Check the new positions to see if they are valid.
					; 			1) If the character falls out of bounds:
					; 				i) Check to see if the character is qbert, or an enemy
					;					--> 0 = qbert, 1 = normal ball #1, 2 = normal ball #2, 3 = snake ball, 4 = snake enemy
					; 					a) qbert
					;						-) currentlives decreases by 1.
					; 						-) qbert gets reset to its initial positon (14, 1)
					;						-) clear the previous qbert location
					;					b) normal ball 1
					;						-) reset all properties of normal ball 1 to 0x00.
					;					c) normal ball 2: TODO
					;					d) snake ball: TODO
					;					e) snake enemy: TODO
					
		STMFD sp!, {r0-r2,r4,r6,r8,r11,lr}	

		LDRB r0, [r4]						; Load contents of direction into r0.
		
		; Check the direction of the character.
		CMP r0, #4							; Check if the direction is 4 (IMMOBILE).
		BEQ POSITION_UPDATED				; If so, exit the subroutine.
		
		CMP r0, #0							; Check if the direction is 0 (Up).
		BEQ DIRECTION_UP					; If so, branch to DIRECTION_UP.
		 
		CMP r0, #1							; Otherwise, check if the direction is 1 (Down).
		BEQ DIRECTION_DOWN					; If so, branch to DIRECTION_DOWN.
		
		CMP r0, #2							; Otherwise, check if the direction is 2 (Left).
		BEQ DIRECTION_LEFT					; If so, branch to DIRECTION_LEFT.
		
		CMP r0, #3							; Otherwise, check if the direction is 3 (Right).
		BEQ DIRECTION_RIGHT					; If so, branch to DIRECTION_RIGHT.

DIRECTION_UP

		; Check the x position to see if we can go up:
		; --> If x is in the set {14, 20, 26, 32, 38, 45}, then the character will fall off the board. 
		;		1) Check to see what the character is.
		;			a) qbert: reset qbert to (14,1).
		; Otherwise:
		; --> The current direction is up. Subtract 4 from the y coordinate, and add 1 to the x coordinate.
		
		LDRB r0, [r5]						; Load the contents of currentx into r0.
		
		CMP r0, #0xE						; Check if currentx is currently 14 (0xE).
		BEQ OOB								; If so, jump to OOB.
		
		CMP r0, #0x14						; Check if currentx is currently 20 (0x14).
		BEQ OOB								; If so, jump to OOB.
		
		CMP r0, #0x1A						; Check if currentx is currently 26 (0x1A).
		BEQ OOB								; If so, jump to OOB.
		
		CMP r0, #0x20						; Check if currentx is currently 32 (0x20).
		BEQ OOB								; If so, jump to OOB.
		
		CMP r0, #0x26						; Check if currentx is currently 38 (0x26).
		BEQ OOB								; If so, jump to OOB.
		
		CMP r0, #0x2C						; Check if currentx is currently 45 (0x2D).
		BEQ	OOB								; If so, jump to OOB.
		
		STRB r0, [r6]						; Store currentx as previousx.
		ADD r0, r0, #1						; Add 1 to currentx to move up 1 position.
		STRB r0, [r5]						; Store the new currentx value.
		
		LDRB r0, [r7]						; Load contents of currenty into r0.
		STRB r0, [r8]						; Store currenty as previousy.
		SUB r0, r0, #4						; Subtract 4 from currenty to move up 1 position.
		STRB r0, [r7]						; Store the new currenty value.
		
		B POSITION_UPDATED
	
DIRECTION_DOWN

		; Check the x position to see if we can go down:
		; --> If x is in the set {9, 16, 23, 30, 37, 45}, then the character will fall off the board. 
		;		1) Check to see what the character is.
		;			a) qbert: reset qbert to (14,1).
		; Otherwise:
		; --> The current direction is down. Add 4 to the y coordinate, and subtract 1 from the x coordinate.
		
		LDRB r0, [r5]						; Load the contents of qbertcurrentx into r0.
		
		CMP r0, #0x9						; Check if currentx is currently 9 (0x9).
		BEQ OOB								; If so, jump to OOB.
		
		CMP r0, #0x10						; Check if currentx is currently 16 (0x10).
		BEQ OOB								; If so, jump to OOB.
		
		CMP r0, #0x17						; Check if currentx is currently 23 (0x17).
		BEQ OOB								; If so, jump to OOB.
		
		CMP r0, #0x1E						; Check if currentx is currently 30 (0x1E).
		BEQ OOB								; If so, jump to OOB.
		
		CMP r0, #0x25						; Check if currentx is currently 37 (0x25).
		BEQ OOB								; If so, jump to OOB.
		
		CMP r0, #0x2C						; Check if currentx is currently 45 (0x2C).
		BEQ	OOB								; If so, jump to OOB.
		
		STRB r0, [r6]						; Store currentx as previousx.
		SUB r0, r0, #1						; Subtract 1 from currentx to move down 1 positino.
		STRB r0, [r5]						; Store the new currentx value.
		
		LDRB r0, [r7]						; Load the contents of currenty into r0.
		STRB r0, [r8]						; Store currenty as previousy.
		ADD r0, r0, #4						; Add 4 to currenty to move down 1 position.
		STRB r0, [r7]						; Store the new currenty value.
		
		B POSITION_UPDATED

DIRECTION_LEFT
		
		; Check the x position to see if we can go left:
		; --> If x is in the set {9, 10, 11, 12, 13, 14}, then the character will fall off the board. 
		;		1) Check to see what the character is.
		;			a) qbert: reset qbert to (14,1).
		; Otherwise:
		; --> The current direction is left. Subtract 6 from the x coordinate, and subtract 2 from the y coordinate.
		
		LDRB r0, [r5]						; Load the contents of currentx into r0.
		
		CMP r0, #0x9						; Check if currentx is currently 9 (0x9).
		BEQ OOB								; If so, jump to OOB.
		
		CMP r0, #0xA						; Check if currentx is currently 10 (0xA).
		BEQ OOB								; If so, jump to OOB.
		
		CMP r0, #0xB						; Check if currentx is currently 11 (0xB).
		BEQ OOB								; If so, jump to OOB.
		
		CMP r0, #0xC						; Check if currentx is currently 12 (0xC).
		BEQ OOB								; If so, jump to OOB.
		
		CMP r0, #0xD						; Check if currentx is currently 13 (0xD).
		BEQ OOB								; If so, jump to OOB.
		
		CMP r0, #0xE						; Check if currentx is currently 14 (0xE).
		BEQ	OOB								; If so, jump to OOB.
		
		STRB r0, [r6]						; Store currentx as previousx.
		SUB r0, r0, #6						; Subtract 6 from currentx to move left 1 position.
		STRB r0, [r5]						; Store the new currentx value.
		
		LDRB r0, [r7]						; Load the contents of currenty into r0.
		STRB r0, [r8]						; Store currenty as previousy.
		SUB r0, r0, #2						; Subtract 2 from currenty to move left 1 position.
		STRB r0, [r7]						; Store the new currenty value.
		
		B POSITION_UPDATED

DIRECTION_RIGHT

		; Check the x position to see if we can go left:
		; --> If x is in the set {9, 16, 23, 30, 37, 45}, then the character will fall off the board. 
		;		1) Check to see what the character is.
		;			a) qbert: reset qbert to (14,1).
		; Otherwise:
		; --> The current direction is right. Add 6 to the x coordinate, and add 2 to the y coordinate.
		
		LDRB r0, [r5]						; Load the contents of currentx into r0.
		
		CMP r0, #0x9						; Check if currentx is currently 9 (0x9).
		BEQ OOB								; If so, jump to OOB.
		
		CMP r0, #0x10						; Check if currentx is currently 16 (0x10).
		BEQ OOB								; If so, jump to OOB.
		
		CMP r0, #0x17						; Check if currentx is currently 23 (0x17).
		BEQ OOB								; If so, jump to OOB.
		
		CMP r0, #0x1E						; Check if currentx is currently 30 (0x1E).
		BEQ OOB								; If so, jump to OOB.
		
		CMP r0, #0x25						; Check if currentx is currently 37 (0x25).
		BEQ OOB								; If so, jump to OOB.
		
		CMP r0, #0x2C						; Check if currentx is currently 45 (0x2C).
		BEQ	OOB								; If so, jump to OOB.
		
		STRB r0, [r6]						; Store currentx as previousx.
		ADD r0, r0, #6						; Add 1 to currentx to move right 1 position.
		STRB r0, [r5]						; Store the new currentx value.
		
		LDRB r0, [r7]						; Load the contents of currenty into r0.
		STRB r0, [r8]						; Store currenty as previousy.
		ADD r0, r0, #2						; Add 2 to currenty to move right 1 position.
		STRB r0, [r7]						; Store the new currenty value.
		
		B POSITION_UPDATED
		
OOB		; Check to see what character is being updated.
		CMP r9, #0x0						; Check to see if the character position updated is qbert's.
		BNE NB1
		BL qbert_oob_handler
		B POSITION_UPDATED
		
NB1		CMP r9, #0x1						; Check to see if the character position updated is a normal ball 1's.
		BNE NB2
		BL nball1_oob_handler 			
		B POSITION_UPDATED
		
NB2		CMP r9, #0x2						; Check to see if the character position updated is a normal ball 2's.
		BNE SBA
		BL nball2_oob_handler
		B POSITION_UPDATED
		
SBA		CMP r9, #0x3						; Check to see if the character position updated is a snake ball's.
		BL sball_oob_handler
		B POSITION_UPDATED
		
POSITION_UPDATED

		; Clear the previous position.
		MOV r10, #0x1						; Set clear flag to 1 in order to set the character to space (0x20).
		BL	set_position					; Clear the previous position.
		
		LDMFD sp!, {r0-r2,r4,r6,r8,r11,lr}
		BX lr
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------		
qbert_oob_handler
		STMFD SP!, {r0,r4,r5,r7,r8,lr}
		
		STRB r0, [r6]						; Store qbertcurrentx as qbertpreviousx.
		
		LDRB r0, [r7]						; Load the contents of qbertcurrenty into r0.
		STRB r0, [r8]						; Store qbertcurrenty as qbertpreviousy.
		
		; Reset qbertcurrentx to 14.
		MOV r0, #0xE						; Set qbertcurrentx to 14 (E hex).
		STRB r0, [r5]						; Store the new qbertcurrentx value.
		
		; Reset qbertcurrenty to 1.
		MOV r0, #0x1						; Set qbertcurrenty to 1 (1 hex).
		STRB r0, [r7]						; Store the new qbertcurrenty value.

		; Set the current direction to 4 (IMMOBILE)
		MOV r0, #0x4						; Set qbertdirection to 4 (4 hex).
		STRB r0, [r4]						; Store the new qbertdirection value.
		
											;remove 1 life
		LDR r0, =currentlives
		LDRB r2, [r0]
		SUB r2, r2, #0x1
		STRB r2, [r0]
		BL set_lives
											;set up Led blinker
		LDR r0, =ledblinkercounter
		MOV r1, #0xB
		STRB r1, [r0]
		
		;set up blinker to indicate that a life was lost		
		LDMFD SP!, {r0,r4,r5,r7,r8,lr}
		BX lr
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------
nball1_oob_handler
		STMFD sp!, {r0,r4-r8,r10,lr}
		
		STRB r0, [r6]						; Store nball1currentx as nball1previousx.
		
		LDRB r0, [r7]						; Load the contents of nball1currenty into r0.
		STRB r0, [r8]						; Store nball1currenty as nball1previousy.
		
		MOV r10, #0x1						; Set clear flag to 1 in order to set the character to space (0x20).
		BL	set_position					; Clear the previous position.
		
		; Reset nball1currentx to 0x00.
		MOV r0, #0x00						; Set nball1currentx to 0x00.
		STRB r0, [r5]						; Store the new nball1currentx value.
		
		; Reset nball1previousx to 0x00.
		MOV r0, #0x00						; Set nball1previousx to 0x00.
		STRB r0, [r6]						; Store the new nball1previousx value.
		
		; Reset nball1currenty to 0x00.
		MOV r0, #0x00						; Set nball1currenty to 0x00.
		STRB r0, [r7]						; Store the new nball1currenty value.
		
		; Reset nball1previousy to 0x00.
		MOV r0, #0x00						; Set nball1previousy to 0x00.
		STRB r0, [r8]						; Store the new nball1previousy value.

		; Set the nball1direction to 0x4.
		MOV r0, #0x4						; Set nball1direction to 0x4.
		STRB r0, [r4]						; Store the new nball1direction value.
		
		LDMFD sp!, {r0,r4-r8,r10,lr}
		BX lr
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------
nball2_oob_handler
		STMFD sp!, {r0,r4-r8,r10,lr}
		
		STRB r0, [r6]						; Store nball2currentx as nball2previousx.
		
		LDRB r0, [r7]						; Load the contents of nball2currenty into r0.
		STRB r0, [r8]						; Store nball2currenty as nball2previousy.
		
		MOV r10, #0x1						; Set clear flag to 1 in order to set the character to space (0x20).
		BL	set_position					; Clear the previous position.
		
		; Reset nball2currentx to 0x00.
		MOV r0, #0x00						; Set nball2currentx to 0x00.
		STRB r0, [r5]						; Store the new nball2currentx value.
		
		; Reset nball2previousx to 0x00.
		MOV r0, #0x00						; Set nball2previousx to 0x00.
		STRB r0, [r6]						; Store the new nball2previousx value.
		
		; Reset nball2currenty to 0x00.
		MOV r0, #0x00						; Set nball2currenty to 0x00.
		STRB r0, [r7]						; Store the new nball2currenty value.
		
		; Reset nball2previousy to 0x00.
		MOV r0, #0x00						; Set nball2previousy to 0x00.
		STRB r0, [r8]						; Store the new nball2previousy value.

		; Set the nball2direction to 0x4.
		MOV r0, #0x4						; Set nball2direction to 0x4.
		STRB r0, [r4]						; Store the new nball2direction value.
		
		LDMFD sp!, {r0,r4-r8,r10,lr}
		BX lr
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------
sball_oob_handler	; The snake ball turns into a snake when it goes out of bounds!
		STMFD sp!, {r0,r4-r9,lr}
		
		STRB r0, [r6]						; Store sballcurrentx as sballpreviousx.
		
		LDR r9, =snakecurrentx				; Load the address of snakecurrentx into r9.
		STRB r0, [r9]						; Store sballcurrentx as snakecurrentx.
		
		LDRB r0, [r7]						; Load the contents of sballcurrenty into r0.
		
		STRB r0, [r8]						; Store sballcurrenty as sballpreviousy.
		
		LDR r9, =snakecurrenty				; Load the address of snakecurrenty into r9.
		STRB r0, [r9]						; Store sballcurrenty as snakecurrenty.
		
		MOV r10, #0x1						; Set clear flag to 1 in order to set the character to space (0x20).
		BL	set_position					; Clear the previous position.
		
		; Reset sballcurrentx to 0x00.
		MOV r0, #0x00						; Set sballcurrentx to 0x00.
		STRB r0, [r5]						; Store the new sballcurrentx value.
		
		; Reset sballpreviousx to 0x00.
		MOV r0, #0x00						; Set sballpreviousx to 0x00.
		STRB r0, [r6]						; Store the new sballpreviousx value.
		
		; Reset sballcurrenty to 0x00.
		MOV r0, #0x00						; Set sballcurrenty to 0x00.
		STRB r0, [r7]						; Store the new sballcurrenty value.
		
		; Reset sballpreviousy to 0x00.
		MOV r0, #0x00						; Set sballpreviousy to 0x00.
		STRB r0, [r8]						; Store the new sballpreviousy value.

		; Set the sballdirection to 0x4.
		MOV r0, #0x4						; Set sballdirection to 0x4.
		STRB r0, [r4]						; Store the new sballdirection value.
		
		; Set the snake direction to 0x4.
		LDR r9, =snakedirection
		STRB r0, [r9]
		
		LDMFD sp!, {r0,r4-r9,lr}
		BX lr
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------				
print_screen
		STMFD sp!, {r0-r4,r6,r8,r11,lr}
		
		; Set the current qbert position.
		BL set_qbert
		
		; Set the current normal ball 1 position.
		LDR r5, =nball1currentx
		LDRB r4, [r5]
		CMP r4, #0x0
		BLNE set_nball1
		
		; Set the current normal ball 2 position.
		LDR r5, =nball2currentx
		LDRB r4, [r5]
		CMP r4, #0x0
		BLNE set_nball2
		
		; Set the current snake ball position.
		LDR r5, =sballcurrentx
		LDRB r4, [r5]
		CMP r4, #0x0
		BLNE set_sball
		
		; Set the current snake position.
		LDR r5, =snakecurrentx
		LDRB r4, [r5]
		CMP r4, #0x0
		BLNE set_snake
		
		; Check if qbert collided with enemy
		BL collision_detection
		
		; Clear the PuTTy screen.
		MOV r0, #0xC							; Load the new page character (0xC) into r0.
		BL output_character						; Output the new page character.
		
		; Output the new screen
		LDR r4, =row0
		BL output_string
		LDR r4, =row1
		BL output_string
		LDR r4, =row2
		BL output_string
		LDR r4, =row3
		BL output_string
		LDR r4, =row4
		BL output_string
		LDR r4, =row5
		BL output_string
		LDR r4, =row6
		BL output_string
		LDR r4, =row7
		BL output_string
		LDR r4, =row8
		BL output_string
		LDR r4, =row9
		BL output_string
		LDR r4, =row10
		BL output_string
		LDR r4, =row11
		BL output_string
		LDR r4, =row12
		BL output_string
		LDR r4, =row13
		BL output_string
		LDR r4, =row14
		BL output_string
		LDR r4, =row15
		BL output_string
		LDR r4, =row16
		BL output_string
		LDR r4, =row17
		BL output_string
		LDR r4, =row18
		BL output_string
		LDR r4, =row19
		BL output_string
		LDR r4, =row20
		BL output_string
		LDR r4, =row21
		BL output_string
		LDR r4, =row22
		BL output_string
		LDR r4, =row23
		BL output_string
		LDR r4, =row24
		BL output_string
		
		; Make sure everything is printed out.
		MOV r0, #0xA							; Make sure all characters printed using new line char and carriage return
		BL output_character						; ...
		MOV r0, #0xD							; ...
		BL output_character						; Clear the buffer
		
		LDMFD sp!, {r0-r4,r6,r8,r11,lr}
		BX lr
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------		
set_qbert
		STMFD sp!, {r0,r4-r6,r8,r11,lr}
		
		LDR r4, =qbertdirection
		MOV r5, #0x51							; Pass in a 'Q' for the character.
		LDR r6, =qbertcurrentx					; Pass in the qbert x coordinate address
		LDR r8, =qbertcurrenty					; Pass in the qbert y coordinate address
		MOV r10, #0x0							; Set clear flag to 0 in order to utilize the character from r5.
		BL	set_position						; Set the current position to the character in r5.
		
		; Reset qbert's direction to immobile so it stops moving.
		;LDR r4, =qbertdirection					; Load the address of qbertdirection
		MOV r0, #0x4							; Set qbertdirection to 4 (IMMOBILE).
		STRB r0, [r4]							; Store the new qbertdirection.
		
		LDMFD sp!, {r0,r4-r6,r8,r11,lr}
		BX lr
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------
set_nball1
		STMFD sp!, {r5-r6,r8,r11,lr}
		
		LDR r4, =nball1direction
		MOV r5, #0x4F							; Pass in a 'O' for the character.
		LDR r6, =nball1currentx					; Pass in the nball1 x coordinate address
		LDR r8, =nball1currenty					; Pass in the nball1 y coordinate address
		MOV r10, #0x0							; Set clear flag to 0 in order to utilize the character from r5.
		BL	set_position						; Set the current position to the character in r5.
		
		LDMFD sp!, {r5-r6,r8,r11,lr}
		BX lr
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------
set_nball2
		STMFD sp!, {r5-r6,r8,r11,lr}
		
		LDR r4, =nball2direction
		MOV r5, #0x4F							; Pass in a 'O' for the character.
		LDR r6, =nball2currentx					; Pass in the nball2 x coordinate address
		LDR r8, =nball2currenty					; Pass in the nball2 y coordinate address
		MOV r10, #0x0							; Set clear flag to 0 in order to utilize the character from r5.
		BL	set_position						; Set the current position to the character in r5.
		
		LDMFD sp!, {r5-r6,r8,r11,lr}
		BX lr
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------
set_sball
		STMFD sp!, {r5-r6,r8,r11,lr}
		
		LDR r4, =sballdirection				
		MOV r5, #0x43							; Pass in a 'C' for the character.
		LDR r6, =sballcurrentx					; Pass in the sball x coordinate address
		LDR r8, =sballcurrenty					; Pass in the sball y coordinate address
		MOV r10, #0x0							; Set clear flag to 0 in order to utilize the character from r5.
		BL	set_position						; Set the current position to the character in r5.
		
		LDMFD sp!, {r5-r6,r8,r11,lr}
		BX lr
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------
set_snake
		STMFD sp!, {r5-r6,r8,r11,lr}
		
		LDR r4, =snakedirection
		MOV r5, #0x53							; Pass in a 'C' for the character.
		LDR r6, =snakecurrentx					; Pass in the sball x coordinate address
		LDR r8, =snakecurrenty					; Pass in the sball y coordinate address
		MOV r10, #0x0							; Set clear flag to 0 in order to utilize the character from r5.
		BL	set_position						; Set the current position to the character in r5.
		
		LDMFD sp!, {r5-r6,r8,r11,lr}
		BX lr
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------			
set_position	; Sets a specified position to a specified character. Can be used to clear a position by use of the space character (0x20).
				; --> Parameters/Arguments: r5 = character value, r6 = x coordinate address, r8 = y coordinate address, r10 = clear flag (1 for clear, 0 for set)
				; --> Variables: r7 = x coordinate value (loaded from r6), r9 = y coordinate value (loaded from r8)
				; NEW PARAMETERS: 	r4 = direction			NEW VARIABLES: x 
				;					r5 = character value
				;					r6 = x
				;					r8 = y
				;					r10 = clear flag
		STMFD sp!, {r5-r10, lr}
		
		; Load the x coordinate.
		LDR r7, [r6]						; Load the contents of the x coordinate (r6) into r7.
		ADD r7, r7, #1						; Add 1 to r7 to offset for 0x7C at the base address.
		
		; Load the y coordinate.
		LDR r9, [r8]					    ; Load the y coordinate value.
		BL seek_row							; Get the correct row, returned in r0.

		; Check the clear flag. If clearing, check if the position is unexplored. If so, set r5 to *.
		CMP r10, #0x1						; Compare r10 to 0x1.
		BNE SET								; If r10 is not 0x1, jump to use the character in r5.

		; Check if the position is unexplored
		SUB r7, r7, #1					    ; Subtract 1 from the offset to read the preceding character.
		LDRB r5, [r0, r7]		  			; Load the preceding character.
		CMP r5, #0x2A						; Check to see if the preceding character is '*'.
		BNE CLEAR							; If not, the position is explored, jump to clear the position.
		ADD r7, r7, #1						; Add 1 to the offset to get the correct offset back.
		;*********should add for unexplored here*******************************

		B SET							    ; Jump to SET

CLEAR	ADD r7, r7, #1					  	; Get the correct 
		MOV r5, #0x20						; Otherwise, set r5 to the space character.
		
SET		STRB r5, [r0, r7]					; Store the character in r5 to the base address of the row in r0, offset by r7 (x coordinate + 1).
		
		; Check if the direction is 4 (IMMOBILE). If so, do not clear the position.
		; Otherwise, clear the position.
		;LDR r5, =qbertdirection			    ; Load the address of qbertdirection
		LDRB r6, [r4]						; Load the value of the character direction
		CMP r6, #0x4						; Check if the direction is 4.
		BEQ FINISH							; If so, do not clear the position.
		
		; Check the clear flag. 
		CMP r10, #0x1						; Compare r10 to 0x1.
		BEQ FINISH							; If r10 is 0x1, do not unmark (explore) the position.
		
		; Otherwise, unmark the position.
		
		;TEST THIS: CODE IS MODIFIED TO EXPLORE THE POSITION ONLY FOR QBERT!
		; Check if the character is qbert. If so, explore the position. Otherwise, DO NOT EXPLORE.
		CMP r5, #0x51
		BNE FINISH
		
		; Otherwise, explore the position.
		SUB r7, r7, #1						; Subtract 1 from the offset to get the preceding character.
		LDRB r5, [r0, r7]					; Load the preceding character into r5.
		CMP r5, #0x2A						; Check if the preceding character is a '*'.
		BNE FINISH							; If not, the position is already explored. Exit the subroutine.
		
		; Otherwise, clear the preceding positions.
		MOV r5, #0x20						
		STRB r5, [r0, r7]					 
		SUB r7, r7, #1
		STRB r5, [r0, r7]
		SUB r7, r7, #1
		STRB r5, [r0, r7]
		
		ADD r9, r9, #0x1
		BL seek_row
		SUB r7, r7, #1
		STRB r5, [r0, r7]
		ADD r7, r7, #1
		STRB r5, [r0, r7]
		ADD r7, r7, #1
		STRB r5, [r0, r7]
		ADD r7, r7, #1
		STRB r5, [r0, r7]
		
FINISH	LDMFD sp!, {r5-r10, lr}				; The previous position has been set. Return to the subroutine.
		BX lr
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------		
seek_row	; Finds the correct row to modify when placing or clearing a character.
			; --> Pass in the y coordinate value to r9.
			; --> The correct row address is returned in r0.
			
		STMFD SP!, {lr}

		CMP r9, #0x00000001					; Check if r9 is 1.
		BEQ ROW1							; If so, the character is in row1.
		
		CMP r9, #0x00000002					; Check if r9 is 2.
		BEQ ROW2							; If so, the character is in row2.
		
		CMP r9, #0x00000003					; Check if r9 is 3.
		BEQ ROW3							; If so, the character is in row3.
		
		CMP r9, #0x00000004					; Check if r9 is 4.
		BEQ ROW4							; If so, the character is in row4.
		
		CMP r9, #0x00000005					; Check if r9 is 5.
		BEQ ROW5							; If so, the character is in row5.
		
		CMP r9, #0x00000006					; Check if r9 is 6.
		BEQ ROW6							; If so, the character is in row6.
		
		CMP r9, #0x00000007					; Check if r9 is 7.
		BEQ ROW7							; If so, the character is in row7
		
		CMP r9, #0x00000008					; Check if r9 is 8.
		BEQ ROW8							; If so, the character is in row8.
		
		CMP r9, #0x00000009					; Check if r9 is 9.
		BEQ ROW9							; If so, the character is in row9.
		
		CMP r9, #0x0000000A					; Check if r9 is 10 (0xA).
		BEQ ROW10							; If so, the character is in row10.
		
		CMP r9, #0x0000000B					; Check if r9 is 11 (0xB).
		BEQ ROW11							; If so, the character is in row11.
		
		CMP r9, #0x0000000C					; Check if r9 is 12 (0xC).
		BEQ ROW12							; If so, the character is in row12.
		
		CMP r9, #0x0000000D					; Check if r9 is 13 (0xD).
		BEQ ROW13							; If so, the character is in row13.
		
		CMP r9, #0x0000000E					; Check if r9 is 14 (0xE).
		BEQ ROW14							; If so, the character is in row14.
		
		CMP r9, #0x0000000F					; Check if r9 is 15 (0xF).
		BEQ ROW15							; If so, the character is in row15.
		
		CMP r9, #0x00000010					; Check if r9 is 16 (0x10).
		BEQ ROW16							; If so, the character is in row16.
		
		CMP r9, #0x00000011					; Check if r9 is 17 (0x11).
		BEQ ROW17							; If so, the character is in row17.
		
		CMP r9, #0x00000012					; Check if r9 is 18 (0x12).
		BEQ ROW18							; If so, the character is in row18.
		
		CMP r9, #0x00000013					; Check if r9 is 19 (0x13).
		BEQ ROW19							; If so, the character is in row19.
		
		CMP r9, #0x00000014					; Check if r9 is 20 (0x14).
		BEQ ROW20							; If so, the character is in row20.
		
		CMP r9, #0x00000015					; Check if r9 is 21.
		BEQ ROW21							; If so, the character is in row21.
		
		CMP r9, #0x00000016					; Check if r9 is 22.
		BEQ ROW22							; If so, the character is in row22.
		
ROW1	LDR r0, =row1						; Load the address of row1.
		B RET
		
ROW2	LDR r0, =row2						; Load the address of row2.
		B RET
		
ROW3	LDR r0, =row3						; Load the address of row3.
		B RET
		
ROW4	LDR r0, =row4						; Load the address of row4.
		B RET
		
ROW5	LDR r0, =row5						; Load the address of row5.
		B RET
		
ROW6	LDR r0, =row6						; Load the address of row6.
		B RET	
		
ROW7	LDR r0, =row7						; Load the address of row7.
		B RET
		
ROW8	LDR r0, =row8						; Load the address of row8.
		B RET	
		
ROW9	LDR r0, =row9						; Load the address of row9.
		B RET	
		
ROW10	LDR r0, =row10						; Load the address of row10.
		B RET

ROW11	LDR r0, =row11						; Load the address of row11.
		B RET
		
ROW12	LDR r0, =row12						; Load the address of row12.
		B RET
		
ROW13	LDR r0, =row13						; Load the address of row13.
		B RET
		
ROW14	LDR r0, =row14						; Load the address of row14.
		B RET
		
ROW15	LDR r0, =row15						; Load the address of row15.
		B RET
		
ROW16	LDR r0, =row16						; Load the address of row16.
		B RET	
		
ROW17	LDR r0, =row17						; Load the address of row17.
		B RET
		
ROW18	LDR r0, =row18						; Load the address of row18.
		B RET	
		
ROW19	LDR r0, =row19						; Load the address of row19.
		B RET	
		
ROW20	LDR r0, =row20						; Load the address of row20.
		B RET

ROW21	LDR r0, =row21						; Load the address of row21.
		B RET
		
ROW22	LDR r0, =row22						; Load the address of row22.
		
RET		LDMFD SP!, {lr}
		BX lr
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------		
end_of_game_scoring
	STMFD sp!, {r0-r12,lr}
	
	LDR r0, =currentlives
	LDRB r1, [r0]
	ADD r1, r1, #0x19;*************for testing purposes
	LDR r2, =currentpoints
	LDR r3, [r2]
	ADD r3, r3, r1
	STR r3, [r2]
	
	LDMFD sp!, {r0-r12,lr}
	BX lr
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------
level_clear_scoring
	STMFD sp!, {r0-r12,lr}
	LDR r0, =currentpoints
	LDR r1, [r0]
	ADD r1, r1, #0x25
	STR r1, [r0]
	
	LDMFD sp!, {r0-r12,lr}
	BX lr
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------	
turn_on_led_red
	STMFD sp!, {r0-r12,lr}
	LDR r0, =IO0CLR
	LDR r1, =IO0SET	
	MOV r2, #0x20000;20000 is setting 7 to 1
	STR r2, [r0]
	LDMFD sp!, {r0-r12,lr}
	BX lr
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------	
turn_off_led
	STMFD sp!, {r0-r12,lr}
	LDR r0, =IO0CLR
	LDR r1, =IO0SET	
	MOV r2, #0x26				;set port 0, pin 18 and 21 to 1
	MOV r2, r2, LSL #16			;0x00260000
	STR r2, [r1]
	LDMFD sp!, {r0-r12,lr}
	BX lr
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------		
life_lost
	STMFD sp!, {r0-r12,lr}
	LDR r0, =ledblinkercounter
	MOV r1, #0xA
	STRB r1, [r0]
	LDR r0, =currentlives
	LDRB r1, [r0]
	SUB r1, r1, #0x1
	CMP r1, #0x0	;is game over							
	BNE GAME_KEEPS_GOING							
	LDR r3, =gamestate										
	MOV r4, #0x2
	STRB r4, [r3]																				
GAME_KEEPS_GOING
	STRB r1, [r0]
	LDMFD sp!, {r0-r12,lr}
	BX lr
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------	
collision_detection
	; Checks to see if q'bert collided with an enemy. 
	; If so, a life is lost and all enemies are reset (including spawnenemycounter).
		STMFD sp!, {r4-r10,lr}
	
		; Load the current x coordinate of q'bert
		LDR r4, =qbertcurrentx
		LDRB r5, [r4]
	
		; Load the current x coordinate of nball1
		LDR r4, =nball1currentx
		LDRB r6, [r4]
		
		; Load the previous x coordinate of q'bert
		LDR r4, =qbertpreviousx
		LDRB r7, [r4]
		
		; Load the previous x coordinate of nball1
		LDR r4, =nball1previousx
		LDRB r8, [r4]
	
		; Check to see if q'bert is in the same box as nball1
		CMP r5, r6
		BEQ COLL
		
		; Check to see if q'bert is going to previous x of nball1, AND nball1 is going to previous x of q'bert
		CMP r5, r8
		BEQ VERIFY
		
VERIFY	CMP r6, r7
		BEQ COLL
		
		; Load the x coordinate of nball2
		LDR r4, =nball2currentx
		LDRB r6, [r4]
		
		; Load the previous x coordinate of nball2
		LDR r4, =nball2previousx
		LDRB r8, [r4]
		
		; Check to see if q'bert is in the same box as nball2
		CMP r5, r6
		BEQ COLL
		
		; Check to see if q'bert is going to previous x of nball2, AND nball2 is going to previous x of q'bert
		CMP r5, r8
		BEQ VERIFY2
		
VERIFY2	CMP r6, r7
		BEQ COLL
		
		; Load the x coordinate of sball
		LDR r4, =sballcurrentx
		LDRB r6, [r4]
		
		; Load the previous x coordinate of sball
		LDR r4, =sballpreviousx
		LDRB r8, [r4]
		
		; Check to see if q'bert is in the same box as sball
		CMP r5, r6
		BEQ COLL
		
		; Check to see if q'bert is going to previous x of sball, AND sball is going to previous x of q'bert
		CMP r5, r8
		BEQ VERIFY3
		
VERIFY3	CMP r6, r7
		BEQ COLL
		
		; Load the x coordinate of snake
		LDR r4, =snakecurrentx
		LDRB r6, [r4]
		
		; Load the previous x coordinate of snake
		LDR r4, =snakepreviousx
		LDRB r8, [r4]
		
		; Check to see if q'bert is in the same box as snake
		CMP r5, r6
		BEQ COLL
		
		; Check to see if q'bert is going to previous x of snake, AND snake is going to previous x of q'bert
		CMP r5, r8
		BEQ VERIFY4
		
VERIFY4	CMP r6, r7
		BEQ COLL
		
		; No collision, continue
		B SAFE
		
COLL	; Decrement life and decrease number of LEDs
		LDR r4, =currentlives
		LDRB r2, [r4]
		SUB r2, r2, #0x1
		STRB r2, [r4]
		BL set_lives
		
		; Reset nball1
		LDR r4, =nball1direction				; Load address of nball1direction.
		LDR r5, =nball1currentx					; Load address of nball1currentx
		LDRB r0, [r5]							; Load nball1currentx into r0.
		LDR r6, =nball1previousx				; Load address of nball1previousx.
		LDR r7, =nball1currenty					; Load address of nball1currenty.
		LDR r8, =nball1previousy				; Load address of nball1previousy.
		MOV r9, #0x1							; Set r9 to nball1.
		BL nball1_oob_handler
		
		; Reset nball2
		LDR r4, =nball2direction				; Load address of nball2direction.
		LDR r5, =nball2currentx					; Load address of nball2currentx
		LDRB r0, [r5]							; Load nball2currentx into r0.
		LDR r6, =nball2previousx				; Load address of nball2previousx.
		LDR r7, =nball2currenty					; Load address of nball2currenty.
		LDR r8, =nball2previousy				; Load address of nball2previousy.
		MOV r9, #0x2							; Set r9 to nball2.
		BL nball2_oob_handler
		
		; Reset sball
		LDR r4, =sballdirection					; Load address of sballdirection
		LDR r5, =sballcurrentx					; Load address of sballcurrentx
		LDRB r0, [r5]							; Load sballcurrentx into r0.
		LDR r6, =sballpreviousx					; Load address of sballpreviousx
		LDR r7, =sballcurrenty					; Load address of sballcurrenty
		LDR r8, =sballpreviousy					; Load address of sballpreviousy
		MOV r9, #0x3							; Set r9 to sball
		BL nball2_oob_handler
		
		; Reset snake
		LDR r4, =snakedirection					; Load address of snakedirection
		LDR r5, =snakecurrentx					; Load address of snakecurrentx
		LDRB r0, [r5]							; Load snakecurrentx into r0.
		LDR r6, =snakepreviousx					; Load address of snakepreviousx
		LDR r7, =snakecurrenty					; Load address of snakecurrenty
		LDR r8, =snakepreviousy					; Load address of snakepreviousy
		MOV r9, #0x4							; Set r9 to snake
		BL nball2_oob_handler
		
		; Reset spawnenemycounter
		LDR r4, =spawnenemycounter
		MOV r5, #0x0
		STRB r5, [r4]
		
		; Keep q'bert in the same spot (make him into a Ø for notice)
		LDR r4, =qbertdirection
		MOV r5, #0xD8							; Pass in a 'Q' for the character.
		LDR r6, =qbertcurrentx					; Pass in the qbert x coordinate address
		LDR r8, =qbertcurrenty					; Pass in the qbert y coordinate address
		MOV r10, #0x0							; Set clear flag to 0 in order to utilize the character from r5.
		BL	set_position						; Set the current position to the character in r5.
		
		; Reset qbert's direction to immobile so it stops moving.
		;LDR r4, =qbertdirection				; Load the address of qbertdirection
		MOV r0, #0x4							; Set qbertdirection to 4 (IMMOBILE).
		STRB r0, [r4]							; Store the new qbertdirection.
		
SAFE	LDMFD sp!, {r4-r10,lr}
		BX lr
; ---------------------------------------------------------------------------------------------------------------------------------------------------------------	
	END