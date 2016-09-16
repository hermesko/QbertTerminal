	AREA Movement, CODE, READWRITE
	EXPORT set_position
	EXPORT seek_row
	EXPORT update_position
	EXPORT qbert_oob_handler
	EXPORT print_screen
	EXTERN set_qbert
	EXTERN output_string
	EXTERN output_character
	EXTERN read_character
	EXTERN uart_init
	EXTERN div_and_mod
	EXTERN set_board_hardware
	EXTERN pin_connect_block_setup
	
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
		
set_position	; Sets a specified position to a specified character. Can be used to clear a position by use of the space character (0x20).
				; --> Parameters/Arguments: r5 = character value, r6 = x coordinate address, r8 = y coordinate address, r11 = clear flag (1 for clear, 0 for set)
				; --> Variables: r7 = x coordinate value (loaded from r6), r9 = y coordinate value (loaded from r8)
		STMFD sp!, {r5-r10, lr}
		
		; Load the x coordinate.
		LDR r7, [r6]						; Load the contents of the x coordinate (r6) into r7.
		ADD r7, r7, #1						; Add 1 to r7 to offset for 0x7C at the base address.
		
		; Check the clear flag.
		CMP r10, #0x1						; Compare r11 to 0x1.
		BNE SET								; If r11 is not 0x1, jump to use the character in r5.
		MOV r5, #0x20						; Otherwise, set r5 to the space character.
		
		
SET		; Load the y coordinate.
		LDR r9, [r8]						; Load the contents of the y coordinate (r8) into r9.
		BL seek_row							; Find the correct row to place the character in.
		STRB r5, [r0, r7]					; Store the character in r5 to the base address of the row in r0, offset by r7 (x coordinate + 1).
		
		SUB r7, r7, #1
		LDRB r5, [r0, r7]
		CMP r5, #0x2A
		BNE FINISH
		
		MOV r5, #0x20
		STRB r5, [r0, r7]
		SUB r7, r7, #1
		STRB r5, [r0, r7]
		SUB r7, r7, #1
		STRB r5, [r0, r7]
		
FINISH	LDMFD sp!, {r5-r10, lr}				; The previous position has been set. Return to the subroutine.
		BX lr

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
		
update_position		; I) Used to update the current position of a character to a new current position.
					; 		A) Save the currentx and currenty values into previousx and previousy.
					;		B) Update the currentx and currenty values based on direction.
					;		C) Check the new positions to see if they are valid.
					; 			1) If the character falls out of bounds:
					; 				i) Check to see if the character is qbert, or an enemy
					;					--> 0 = qbert, 1 = normal ball, 2 = snake ball, 3 = snake enemy
					; 					a) qbert
					;						-) currentlives decreases by 1.
					; 						-) qbert gets reset to its initial positon (14, 1)
					;						-) clear the previous qbert location
					;					b) normal ball: TODO
					;					c) snake ball: TODO
					;					d) snake enemy: TODO
					
		STMFD sp!, {r0-r2,r4,r6,r8,r11,lr}	

		LDRB r0, [r3]						; Load contents of direction into r0.
		
		; Check the direction of the character.
		CMP r0, #4							; Check if the direction is 4 (IMMOBILE).
		BEQ POSITION_UPDATED				; If so, exit the subroutine.
		
		CMP r0, #0							; Check if the direction is 0 (Up).
		BEQ DIRECTION_UP					; If so, branch to DIRECTION_UP.
		 
		CMP r0, #1							; Otherwise, check if the direction is 1 (Down).
		BEQ DIRECTION_DOWN					; If so, branch to DIECTION_DOWN.
		
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
		BLEQ qbert_oob_handler
		B POSITION_UPDATED
		
		; TODO								; Check to see if the character position updated is a normal ball's.
		
		; TODO								; Check to see if the character position updated is a snake ball's.
		
		; TODO								; Check to see if the character position updated is a snake enemy's.
		
POSITION_UPDATED

		; Clear the previous position.
		MOV r11, #0x1						; Set clear flag to 1 in order to set the character to space (0x20).
		BL	set_position					; Clear the previous position.
		
		LDMFD sp!, {r0-r2,r4,r6,r8,r11,lr}
		BX lr

qbert_oob_handler
		STMFD SP!, {r0,r4,r5,r7,r8,lr}
		
		STRB r0, [r5]						; Store qbertcurrentx as qbertpreviousx.
		
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
		
		LDMFD SP!, {r0,r4,r5,r7,r8,lr}
		BX lr
		
print_screen
		STMFD sp!, {r0-r4,r6,r8,r11,lr}
		
		; Set the current qbert position.
		BL set_qbert
		
		; Set the current normal ball position.
		; TODO
		
		; Set the current snake ball position.
		; TODO
		
		; Set the current snake position.
		; TODO
		
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

		END