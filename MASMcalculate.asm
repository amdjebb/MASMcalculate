TITLE MASM Calculate

; Author: Amine Kaddour-Djebbar
; Last Modified: 03/17/2023
; Email address: kaddoura@oregonstate.edu
; Description: This file is a MASM program that recieves valid signed numbers from the user, and returns the numbers
;		entered, a sum of these numbers, and the truncated average of all of these numbers.  The program achieves this
;		by using two macros, one that retrieves a string of numbers from the user, and one that displays the string of numbers to
;		the user.  The program first introduces itself, gives instruction to the user to provide a valid amount of signed
;		numbers, converts the string input to integers and saves them, retrieves these integers and turns them into strings
;		to display to the user.  The program then calculates the sum and average and returns it to the user using the macro.


INCLUDE Irvine32.inc

; Constants
AMOUNT_OF_NUMS = 10

.data
; Project data

	; string prompts
	myName					BYTE	"Written by: Amine Kaddour", 13,10,13,10, 0	
	programTitle			BYTE	"MASM Calculate: Designing low-level I/O procedures",13,10, 0		
	intro_1_one				BYTE	"Please provide ",0 
	intro_1_two				BYTE	" signed decimal integers.",13,10,0	
	intro_2					BYTE	"Each number needs to be small enough to fit inside a 32 bit register.  After you have finis",13,10 ,"hed inputting the raw numbers I will display a list of the integers, their sum, and their" ,13,10, "average value.",0	
	input_prompt			BYTE	"Please enter a signed number: ", 0
	error_prompt			BYTE	"ERROR: You did not enter a signed number or your number was too large. Please try again ", 0
	number_declaration		BYTE	"You entered the following numbers:", 0	
	sum_prompt				BYTE	"The sum of these numbers is: ", 0	
	avg_prompt				BYTE	"The truncated average is:  ", 0	
	farewell_prompt			BYTE	13,10,"Thanks for playing!", 0	
	comma_space				BYTE	", ",0

	; Arrays
	numbersArray			SDWORD	21 DUP(?)		; number array
	input_buffer			DWORD	21 DUP(?)		; input buffer
	number_string			BYTE	21 DUP(?)
	size_of_input			DWORD	?				; length of num input
	number_int				SDWORD	?				; converted number
	char_ascii				SDWORD	?	
	sum_calculation			SDWORD	?



;--------------------------------------------------------------------------------------------------------------------------------
; Name: mGetString MACRO
;
; Description:	Macro used to display a prompt, then get the user's keyboard input and store it into a memory location.  It uses
;		the mDisplayString macro to display the prompt, then use ReadString to recieve the information from the user.
;
; Preconditions:  Saves all registers, ReadString preconditions met
;
; Postconditions: Restores all registers
;
; Receives: memory OFFSETs:
;                          [EBP+24] input_prompt,
;                          [EBP+20] input_buffer,
;                          [EBP+16] number_string,
;                          [EBP+12] size_of_input
;
; Returns: Displays input prompt to user on the console, saves input string in number_string, and size into size_of_input
;-------------------------------------------------------------------------------------------------------------------------------
mGetString MACRO
	PUSHAD
	PUSH	ESI
	MOV		ESI, [EBP + 24]
	mDisplayString
	POP		ESI
	MOV		ECX, SIZEOF input_buffer
	MOV		EDX, [EBP + 20]		; buffer memory (stores the ReadString)
	CALL	ReadString
	MOV		EDI, [EBP + 12]
	MOV		[EDI], EAX		; length saved to memory
	MOV		EDI, [EBP + 16] ; memory of input
	MOV		[EDI], EDX
	POPAD
ENDM


;--------------------------------------------------------------------------------------------------------------------------------
; Name: mDisplayString MACRO
;
; Description:	Macro used to display a string to the user
;
; Preconditions: ESI contains string to be displayed.  Saves all registers
;
; Postconditions: Restores all registers
;
; Receives: ESI points to displayed string
;
; Returns: Displays string to user on the console
;-------------------------------------------------------------------------------------------------------------------------------
mDisplayString MACRO
	PUSHAD
	MOV		EDX, ESI
	CALL	WriteString
	POPAD
ENDM

.code
main PROC
	; Intorduction
	PUSH	OFFSET	programTitle
	PUSH	OFFSET	myName
	PUSH	OFFSET	intro_1_one
	PUSH	OFFSET	intro_1_two
	PUSH	OFFSET	intro_2
	CALL	introduction
	; Get number strings from user and save them as integers
	PUSH	OFFSET  numbersArray
	PUSH	OFFSET	number_int
	PUSH	OFFSET	error_prompt
	PUSH	OFFSET	input_prompt
	PUSH	OFFSET	input_buffer
	PUSH	OFFSET	number_string
	PUSH	OFFSET	size_of_input
	MOV		EDI, [ESP + 24]	
	MOV		ECX, AMOUNT_OF_NUMS
	get_10_numbers:
		PUSH	ECX
		CALL	ReadVal
		POP		ECX
		ADD		EDI, TYPE numbersArray
		LOOP	get_10_numbers
		ADD		ESP, 28
	; Display integers as number strings
	PUSH	OFFSET	comma_space
	PUSH	OFFSET	number_declaration
	PUSH	OFFSET	char_ascii
	PUSH	OFFSET	numbersArray
	PUSH	OFFSET	number_string
	MOV		ECX, AMOUNT_OF_NUMS
	CALL	CrLf
	MOV		ESI, [ESP + 12]
	mDisplayString
	CALL	CrLf
	MOV		ESI, [ESP + 4]
	MOV		EDI, [ESP]
	write_10_numbers:
		PUSH	ECX
		PUSH	ESI
		CALL	WriteVal
		POP		ESI
		ADD		ESI, 4
		POP		ECX
		CMP		ECX, 1
		JE		next_main
		PUSH	ESI
		MOV		ESI, [ESP + 20]
		mDisplayString
		POP		ESI
		LOOP	write_10_numbers
	next_main:
		CALL	CrLf
		ADD		ESP, 20
	; Calculate and display Sum
	PUSH	OFFSET sum_calculation
	PUSH	OFFSET sum_prompt
	PUSH	OFFSET numbersArray
	CALL	calculateSum
	; Calculate and display average
	PUSH	OFFSET avg_prompt
	PUSH	OFFSET sum_calculation
	CALL	calculateAvg
	; Conclude program
	PUSH	OFFSET	farewell_prompt
	CALL	farewell

	Invoke ExitProcess,0	; exit to operating system
main ENDP


;--------------------------------------------------------------------------------------------------------------------------------
; Name: introduction
;
; Description:	Prints Title, Author Name, and a description of the program along with instructions.
;
; Preconditions: mDisplayString macro and WriteVal procedure to print strings to the console.
;
; Postconditions: Restores EAX
;
; Receives: memory OFFSETs:
;                          [EBP+24] programTitle,
;                          [EBP+20] myName,
;                          [EBP+16] intro_1_one,
;                          [EBP+12] intro_1_two,
;                          [EBP+8] intro_2
;
; Returns: Prints statements to the console.
;-------------------------------------------------------------------------------------------------------------------------------
introduction PROC
	PUSH	EBP
	MOV		EBP, ESP
	MOV		ESI, [EBP + 24]
	mDisplayString
	MOV		ESI, [EBP + 20]
	mDisplayString
	MOV		ESI, [EBP + 16]
	mDisplayString
	; converts AMOUNT_OF_NUMS to string and prints it
	PUSHAD
	PUSH	OFFSET	AMOUNT_OF_NUMS		; pointed to by ESI
	PUSH	OFFSET	number_string	; pointed to by EDI
	MOV		EAX, [ESP + 4]
	MOV		[ESI], EAX
	MOV		EDI, [ESP]
	CALL	WriteVal		
	POP		EAX						; pops pushed EDI
	POP		EAX						; pops pushed ESI
	POPAD
	; continues introduction
	MOV		ESI, [EBP + 12]
	mDisplayString
	MOV		ESI, [EBP + 8]
	mDisplayString
	CALL	CrLf
	CALL	CrLf
	XOR		EAX, EAX
	POP		EBP
	RET		20
introduction ENDP


;--------------------------------------------------------------------------------------------------------------------------------
; Name: ReadVal
;
; Description:	Invokes the mGetString macro to get user input in the form of a string of digits. It then converts the string
;		of ascii digits to its numeric value representation while validating the user's input.  It then stores the value in 
;		memory.  Validity handles negative, positive values, plus and minus signs, and overflow values.
;
; Preconditions: mGetString macro and all memory offsets needed, EDI points to numbers_Array
;
; Postconditions: Restores EAX, EBX, ECX, EDX
;
; Receives: EDI points to numbers_Array
;			memory OFFSETs:
;                          [EBP+32] number_int,
;                          [EBP+28] error_prompt,
;                          [EBP+24] input_prompt,
;                          [EBP+20] input_buffer,
;                          [EBP+16] number_string,
;                          [EBP+12] size_of_input
;
; Returns: Assigns random integer values to all randArray indices.  Displays numbers and errors prompt to user on the console
;-------------------------------------------------------------------------------------------------------------------------------
ReadVal PROC
	PUSH	EBP
	MOV		EBP, ESP
	; gets user input string to start verification
	_user_input:
		mGetString
		MOV		EDX, 84					; SIZEOF numbersArray
		MOV		ESI, [EBP + 12]
		MOV		ECX, [ESI]
		MOV		ESI, [EBP + 16]
		SUB		ESI, EDX				; ESI now contains string input
		MOV		EBX, 0
		CLD
		; test_string will test each byte in string input for validity until end of string
		_test_string_of_positive_int:
			PUSH	ECX
			LODSB
			CMP		AL, 45				; tests minus sign
			JE		_handle_minus_sign
			CMP		AL, 43				; tests plus sign
			JE		_handle_plus_sign
			CMP		AL, 48				; tests low range of ascii number
			JL		_invalidNum
			CMP		AL, 57				; tests high range of ascii number
			JG		_invalidNum
			SUB		AL, 48
			MOV		CL, AL
			MOV		EAX, EBX
			MOV		EDX, 10
			MUL		EDX
			JO		_invalidNum			; tests for overflow (too high or too low)
			ADD		EAX, ECX
			MOV		EBX, EAX			; EBX contains calculated int number
			POP		ECX
			LOOP	_test_string_of_positive_int
		; saves calculated EBX value of POSITIVE int into memory and exits PROC
		_save_int:
			MOV		ESI, EBX		
			MOV		[EDI], EBX
			XOR		EAX, EAX
			XOR		EBX, EBX
			XOR		ECX, ECX
			XOR		EDX, EDX
			POP		EBP
			RET							
		; handles any invalid inputs by the user by printing error message and sending user back to input new string
		_invalidNum:
			PUSH	ESI
			MOV		ESI, [EBP + 28]
			mDisplayString
			POP		ESI
			CALL	CrLf
			POP		ECX
			JMP		_user_input
		; handles if byte contains (+) ASCII
		_handle_plus_sign:
			POP		ECX
			LOOP	_test_string_of_positive_int
		; handles if byte contains (-) ASCII
		_handle_minus_sign:
			LOOP	_test_string_of_negative_int
		; same as test_string above but for negative numbers
		_test_string_of_negative_int:
			PUSH	ECX
			LODSB
			CMP		AL, 45				
			JE		_handle_minus_sign
			CMP		AL, 43				
			JE		_handle_plus_sign
			CMP		AL, 48				
			JL		_invalidNum
			CMP		AL, 57				
			JG		_invalidNum
			SUB		AL, 48
			MOV		CL, AL
			MOV		EAX, EBX
			MOV		EDX, 10
			MUL		EDX
			JO		_get_neg_ready			; tests for overflow (too high or too low)
			ADD		EAX, ECX
			MOV		EBX, EAX			
			POP		ECX
			LOOP	_test_string_of_negative_int
		; saves calculated EBX value of NEGATIVE int into memory and exits PROC
		_save_neg_int:
			NEG		EBX
			POP		ECX
			JMP		_save_int
		_get_neg_ready:
			POP		ECX
			JMP		_invalidNum
ReadVal	ENDP


;--------------------------------------------------------------------------------------------------------------------------------
; Name: WriteVal
;
; Description:	Converts a numeric SDWORD value to a string of ASCII digits.  It achieves this by invoking the mDisplayString
;		macro to print the ASCII representation of the SDWORD value to the console.  
;
; Preconditions: mDisplayString macro and all memory offsets needed, ESI points to integer number (numbersArray),
;		EDI points to number_string.
;
; Postconditions: Restores EAX, EBX, ECX, EDX
;
; Receives: ESI points to numbers_Array, EDI points to number_string, ECX is the AMOUNT_OF_NUMS
;			memory OFFSETs: THESE ARE HANDLED IN MAIN
;
; Returns: Prints the integer numbers as strings to the console with commas in between the numbers
;-------------------------------------------------------------------------------------------------------------------------------
WriteVal PROC  
	PUSH	EBP
	MOV		EBP, ESP
	MOV		EBX, 10
	MOV		EAX, [ESI]
	MOV		ECX, 0
	CMP		EAX, 0
	JL		handl_neg
	; calculates each individual ascii digit and saves them in EDI
	CalculateString:
		CMP		EAX, 10
		JL		DoneString
		MOV		EDX, 0
		DIV		EBX
		PUSH	EAX
		ADD		EDX, 48
		MOV		EAX, EDX
		CLD
		STOSD
		POP		EAX
		INC		ECX
		JMP		CalculateString
	; handles (-) ascii value by displaying it before calculating string
	handl_neg:
		PUSH	ESI
		PUSH	OFFSET	char_ascii
		MOV		ESI, [ESP]		; places the character ascii to display in ESI
		MOV		EDX, 45
		MOV		[ESI], EDX
		mDisplayString
		POP		ESI				; removes the char_ascii offset
		POP		ESI
		NEG		EAX				; turns the value to a positive digit before continuing
		JMP		CalculateString
	; takes previously stored ascii characters and prints them to the console
	DoneString:
		ADD		EAX, 48
		MOV		[EDI], EAX
		INC		ECX
		MOV		ESI, EDI
		MOV		EBX, 0
		printString:
			STD
			LODSD
			PUSH	ESI
			ADD		ESI, 48		; moves ESI to not mess with printing 
			MOV		[ESI], EAX
			mDisplayString
			POP		ESI
			LOOP	printString
	XOR		EAX, EAX
	XOR		EBX, EBX
	XOR		ECX, ECX
	XOR		EDX, EDX
	POP		EBP
	RET
WriteVal ENDP


;--------------------------------------------------------------------------------------------------------------------------------
; Name: calculateSum
; Description:  Calculates and displays the summation value of the numbersArray integers. It also prints the 
;		summation prompt and calculated value to the console for the user
;
; Preconditions: randArray contains sorted integer values
;
; Postconditions: Restores EAX, EBX, ECX, EDX.  Saves sum value in sum_calculation
;
; Receives: memory OFFSETs:
;                          [EBP+16] sum_calculation,
;                          [EBP+12] sum_prompt,
;                          [EBP+8] numbersArray
;
; Returns: prints summation prompt and calculated sum to the user on the console.  Saves sum in var sum_calculation
;-------------------------------------------------------------------------------------------------------------------------------
calculateSum PROC
	PUSH	EBP
	MOV		EBP, ESP
	MOV		ESI, [EBP + 12]
	mDisplayString
	MOV ESI, [EBP + 8]
	MOV	EDI, [EBP + 16]
	MOV	EAX, 0
	MOV	EBX, 0
	MOV	ECX, AMOUNT_OF_NUMS
	; goes through all integers to calculate the sum
	calculationLoop:
		MOV	EBX, [ESI]
		ADD EAX, EBX
		ADD ESI, 4
		LOOP calculationLoop
	; Saves the sum, and prints it for the user
	endcalc:
		MOV	[EDI], EAX
		; sets up precondition for WriteVal to print the sum
		PUSHAD
		PUSH	OFFSET	sum_calculation		
		PUSH	OFFSET	number_string	
		MOV		[ESI], EAX
		MOV		EDI, [ESP]
		CALL	WriteVal
		POP		EAX					; pops OFFSETS
		POP		EAX					
		POPAD
		XOR		EAX, EAX
		XOR		EBX, EBX
		XOR		ECX, ECX
		XOR		EDX, EDX
	POP		EBP
	RET		12
calculateSum ENDP


;--------------------------------------------------------------------------------------------------------------------------------
; Name: calculateAvg
; Description:  Calculates and displays the truncated average value of the numbersArray integers. It also prints the 
;		average prompt and calculated value to the console for the user
;
; Preconditions: calculate_sum contains sum of all integer values
;
; Postconditions: Restores EAX, EBX, ECX, EDX
;
; Receives: memory OFFSETs:
;                          [EBP+12] avg_prompt
;                          [EBP+8] sum_calculation
;
; Returns: prints average prompt and truncated average to the user on the console.
;-------------------------------------------------------------------------------------------------------------------------------
calculateAvg PROC
	PUSH	EBP
	MOV		EBP, ESP
	CALL	CrLf
	MOV		ESI, [EBP + 12]
	mDisplayString				; displays prompt
	MOV		ESI, [EBP + 8]
	MOV		EBX, AMOUNT_OF_NUMS
	MOV		EDX, 0
	MOV		EAX, [ESI]
	CMP		EAX, 0				; handles positive value
	JGE		avgCalc
	NEG		EAX
	DIV		EBX
	NEG		EAX
	JMP		finishAvg
	avgCalc:
		DIV		EBX
	finishAvg:
		PUSHAD
		PUSH	OFFSET	sum_calculation		
		PUSH	OFFSET	number_string	
		MOV		[ESI], EAX
		MOV		EDI, [ESP]
		CALL	WriteVal
		POP		EAX					
		POP		EAX					
		POPAD
		XOR		EAX, EAX
		XOR		EBX, EBX
		XOR		ECX, ECX
		XOR		EDX, EDX
	POP		EBP
	RET		8
calculateAvg ENDP


;--------------------------------------------------------------------------------------------------------------------------------
; Name: farewell
;
; Description:	Prints Goodbye message to the user
;
; Preconditions: none
;
; Postconditions: Restores EDX
;
; Receives: memory OFFSETs:
;                          [EBP+8] farewell
;
; Returns: Prints statements to the console.
;-------------------------------------------------------------------------------------------------------------------------------
farewell PROC	
	PUSH	EBP
	MOV		EBP, ESP
	CALL	CrLf
	MOV		EDX, [EBP + 8]
	CALL	WriteString
	XOR		EDX, EDX
	POP		EBP
	RET		4
farewell ENDP


END main
