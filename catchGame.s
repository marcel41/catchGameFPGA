;Game Project
;Marcel Moran Calderon
;Lab 9
;10/04/2019
;This program is a game where you need to catch the objects that are falling
;when you catch an object you get an extra point in your score(NOODLES) and the buzzer sounds
;and if you missed one object you get minus one point in your life
;if your life reaches zero then the game restarts
;this program uses LCD screen to display the scores and life of the player
;In addition a matrixLED 8bit color where you could see the game
;Moreover, for movement of the player I am using the first row of values of the
;keyboard;
;6 = rigth
;3 = left
;9 = reset
;the program uses interrupts for allowing to poll the Keyboard and then
;uses the inputs from the Keyboard, the main program it is a render of
;the game in base to certain inputs the game will be updated and thus the
;matrixLED screen as well as the LCD
;In order to implement this game the design ex8.bit was modified a little so
;it can use the I2C PROTOCOL
;Known bugs: No a bug but the game is a little slow because most of the mechanics
;consists in loading from memory and writting into memory. One way that could make
;the game could be to implement whole movement and mechanics of the object failling
;in the main.
org 0
B startExecution
GET header.s
org 8
B SVC_entry       ;branch to the SVC_entry
GET header.s
org &18
B ISR_entry       ;branch to ISR_entry


startExecution

;-------------------------------------------------------------------------------
;ENABLE THE INTERRUPT IN THE SYSTEM AND THE TIMER_COMPARE INTERRUPTBITS
;-------------------------------------------------------------------------------
ADR SP, stacksupervisor       ; add the SP for tthe stacksupervisor

                              ;change the supervisor mode to user mode
MOV R0, #FPGAInterface
MOV R1, #&1F                  ;activate all inputs
STRB R1,[R0, #offset3]        ;activate  the row2 of the FPGAInterface

MRS R0, CPSR                  ; Read current status
BIC R0, R0, #:10000000        ; clear the bit that allows us to turn on IRQ
MSR CPSR_c, R0                ; Update CPSR

MOV R0, #portA
MOV R1, #activateTimerCompare
STRB R1, [R0, #interruptBits]


;I need to clean the buzzer because of my implementation of my schematic design
;BL ClearBuzzer
;------------------------------------------------------------------------------
; restart the LED matrix
;------------------------------------------------------------------------------
BL  i2cinit
BL  startc

MOV R0, #:11100000   ;specific address for sending command to board
BL  sendCommand

;turn on the clock of the led matrix
MOV R0, #:00100001
BL  sendCommand
BL  stop

;------------------------------------------------------------------------------
;                        supervisor ->IRQ-> system
;------------------------------------------------------------------------------



MRS R0, CPSR                ; Read current status
BIC R0, R0, #&1F            ; clear mode
ORR R0, R0, #&12            ; APPEND IRQ
MSR CPSR_c, R0              ; Update CPSR
ADR SP, stackIRQ


MRS R0, CPSR                ; Read current status
BIC R0, R0, #&1F            ; clear mode
ORR R0, R0, #&1F            ; APPEND system mode
MSR CPSR_c, R0              ; Update CPSR
;------------------------------------------------------------------------------
;                        system -> user
;------------------------------------------------------------------------------

ADR SP, stackuser     ; system and user have the same SP, for conventional reasons
                      ; add the SP for the stackuser
MRS R0, CPSR          ; Read current status
BIC R0, R0, #&1F      ; clear mode
ORR R0, R0, #&10      ; APPEND user mode
MSR CPSR_c, R0        ; Update CPSR

;------------------------------------------------------------------------------
;main
;------------------------------------------------------------------------------
;the following is the user code, user code will just execute a trivial program
;clean the buzzer because of the schematic design
SVC 2
loop
ADR R2, matrixLed       ;pointer to matix
ADR R4, rowsForLed      ; pointer to which row is being used
MOV R3, #0              ; initialize r3 = 0;
whileRender             ;the following is a loop that load the state for every square in
LDRB R0, [R2, R3]       ;the matrixLed using the state contained in matrixLed
LDRB R1,[R4, R3]
SVC 0                   ;this svc is the one that is charged of communication with LEDMatrixLed
ADD R3, R3, #1          ;r3++
CMP R3, #8              ;this will update all the rows from the matrix
BLT whileRender
SVC 1                   ;this svc is in charged of updating the score and life of player on the LCD screen
B loop

;------------------------------------------------------------------------------
;GLOBAL VARIABLES
;------------------------------------------------------------------------------
;key Pressed
;------------------------------------------------------------------------------
keyPressed DEFW 0
;------------------------------------------------------------------------------
;life
;------------------------------------------------------------------------------
playerLife DEFB 3
ALIGN
;------------------------------------------------------------------------------
;objectToPick
;------------------------------------------------------------------------------
objectToPick DEFW 0
;------------------------------------------------------------------------------
;score
;------------------------------------------------------------------------------
scorePlayer DEFW 0
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;key Pressed
;------------------------------------------------------------------------------
rowsForLed DEFB 1, 3, 5, 7, 9, 11, 13, 14 ;this an address that is used for turning on a
                                          ;a certain colour in the matrixLed
ALIGN

;--------------------MESSAGES FOR LCD-------------------------------------------
string1 DEFB 'NOODLES:',0                 ;WHY you ask? because NOODLES is better than score
ALIGN
string2 DEFB 'LIFE:',0
ALIGN
;-------------------------------------------------------------------------------
;MATRIX ARRAY
;-------------------------------------------------------------------------------
matrixLed
;each of these bytes will represent one state of the matrixLed
;in otherwords each bit of each byte represents one square of the matrixLed of a row
DEFB :00000000, :01000000 , :00000000 , :00000000, :00000000, :00000000, :00000000, :00111000
ALIGN

;-------------------------------------------------------------------------------
;OBJECTS
;-------------------------------------------------------------------------------
obstaclesToCatchMatrix
;each of these bytes will represent one state for the obstacles
;we are wasting lot of memory for a good animation of the object falling
DEFB :00000000, :00000000 , :00000000 , :00000000, :00000000, :00100000, :00000000, :00000000
DEFB :00000000, :00000000 , :00000000 , :00000100, :00000000, :00000000, :00000000, :00000000
DEFB :00000000, :00000100 , :00000000 , :00000000, :00000000, :00000000, :00000000, :00000001
DEFB :00000000, :00000000 , :00000000 , :00000000, :00000000, :01000000, :00000000, :00000000
DEFB :00000000, :00000000 , :00000000 , :00001000, :00000000, :00000000, :00000000, :00000000
DEFB :00000000, :00000010 , :00000000 , :00000000, :00000000, :00000000, :00000000, :01000000
DEFB :00000000, :00000000 , :00000000 , :00000000, :00000000, :00000000, :00000000, :01000000
DEFB :00000000, :00000000 , :00000000 , :00000000, :00000000, :00000000, :01000000, :00000000
ALIGN
;------------------------------------------------------------------------------
;numberPrinted
;------------------------------------------------------------------------------
numbersPrinted DEFW 0
;------------------------------------------------------------------------------
;                          STACKS
;------------------------------------------------------------------------------
DEFS 100
stacksupervisor ;define space for the stack
DEFS 100
stackuser ;setting up the stack for the user
DEFS 100
stackIRQ ;setting up the stack for the IRQ



;------------------------------------------------------------------------------
;                             ISR_ENTRY
;------------------------------------------------------------------------------
ISR_entry
                                      ;deactive the interrupt source
MOV R0, #portA
MOV R1, #deactivatingTimerCompare     ;deactivating other interrupts to avoid 7% dropping perfomance
STRB R1, [R0, #offset3]
          SUB LR, LR, #4              ; Correct return addr
          PUSH {R0-R8,LR}            ; Save working regs
          MOV R0, #FPGAInterface      ;get the location of the Keyboard
          MOV R4,#&20                 ;activate row number 3
          STRB R4,[R0, #2]            ;store value in data register
          LDRB R4, [R0, #2]           ;reload the data register
                                      ;detectKeyPressed needs to Know the row we are printing
          MOV R8, #0                  ;that is why we are storing the 0 to in R8
          BL detectKeyPressed               ;so we can update which key has been pressed
          BL updateStatesOfGame            ;now we need to update the states matrixLed arrray

          MOV R0, #portA                        ;read portA
          LDRB R3, [R0, #timerCompareRegister]  ;using offset get the timerCompareRegister value
          ADD R3, R3, #5                       ;add any value that you desire between 5-100 for detecting keys
                                                ;5 give the best for polling the keys
          CMP R3, #255                          ;remember fix the case when timer_compare overflows
          ;BLE skipFix                           ;if timer_compare > 255
          SUBGT R3, R3, #256
          STR R3,[R0, #timerCompareRegister]    ;store the new value for the next interrupt


          BL delay2         ;a little delay to smooth the animation of the objects falling
          BL objectsToCatch;once that the player has  updated his position we should updated
                                                ;obstacles

          MOV R1, #activateTimerCompare ;activate the interrupts again
          STRB R1, [R0, #offset3]
          POP {R0-R8,PC}^



;-------------------------------------------------------------------------------
;                        SVC_ENTRY
;NOTE: SVC_ENTRY HANDLES REQUEST FOR COMMUNICATION WITH MATRIX LED SCREEN
;-------------------------------------------------------------------------------
SVC_entry
;STR LR, [SP, #-4]!                       ; Push scratch register
PUSH {LR}
LDR R14, [LR, #-4]                        ; Read SVC instruction
BIC R14, R14, #&FF000000                  ; Mask off opcode
CMP R14, #3                               ;compare with maximum of svcs
BHS Out_of_range                          ;stop the program
ADR R10, Jump_table
;LDR LR, [SP], #4
LDR PC, [R10, R14, LSL #2]                ;decide which SVC to execute
Jump_table DEFW SVC_0
           DEFW SVC_1
           DEFW SVC_2

;future svc
SVC_1
BL updateScoreLed
POP{PC}^
SVC_2
BL ClearBuzzer
POP{PC}^
;in case something goes wrong
Out_of_range
 b .
;-------------------------------------------------------------------------------
;                         METHODS
;-------------------------------------------------------------------------------
detectKeyPressed                              ;the following method will workout which
                                        ;buttons has been pressed and which are
                                        ;not
                                        ;passing arguments: R8
push{r0-r9,lr}                          ;before doing any change push registers that we were using in method
; BIC R4, R4, #&F0                        ;leave the first 4 bits of R4
; MOV R6, R4                              ;store this value in another register to avoid conflicts
ADD  R6, R4, #&F0
MOV R4, R6
MOV R0, #totalDebugginKeyBoard          ;move the address of our debugginkeyboard
ADD R0, R0, R8                          ;add the offset of row
MOV R1, #0
forloop                                 ;shift the values of the keys of this row first x < 4

LDRB R2, [R0,R1]
LSL R2, R2, #1                          ;shift values to the left
STRB R2, [R0,R1]
ADD R1, R1, #1                          ;r1++

CMP R1, #4
BLT forloop
;------------------------------------------------------------------------------
;improvement for detecting which keys were activated
;------------------------------------------------------------------------------

MOV R9, #0
MOV R7, #1                              ;initialize testing number of column
loopIncreasingBufferKeys
MOV r6, r4                              ;reload the value to check if the next key has been pressed
TST R6, R7                              ;use TST to know if the button pressed was the first one
BEQ goToNextKeyToTestIt
LDRB R1, [R0, R9]                       ;increase the buffer in the debugginkeyboard
ORR R1, R1, #1                          ;using or for adding 1 to the buffer
STRB R1, [R0, R9]                       ;store the result back


goToNextKeyToTestIt
LSL R7, R7, #1                          ;shift values to the left
ADD R9, R9, #1
CMP R7, #9
BLT loopIncreasingBufferKeys

POP{r0-r9,pc} ;before doing any change push registers that we will be using in the method

;-------------------------------------------------------------------------------
; restartGame
;-------------------------------------------------------------------------------
restartGame
;method will restart score to zero along with the data of the matrix
PUSH{R0-R3,LR}
ADR R2, matrixLed    ;pointer to matrix
ADR R3, scorePlayer  ;poitner to scorePlayer
MOV R1, #6           ;initialize r1 = 0 for loop
MOV R0, #:00000000   ;initialize r0 for restarting the data matrix
STRB R0, [R3]       ;restar the score of player
                    ;restart the first row as well
STRB R0,[R2]
resetLoop           ;loop that will go through the first FIVE row and will set them to zero
STRB R0, [R2,R1]
SUBS R1, R1, #1
BGE resetLoop
MOV R0, #:00111000    ;restart the postion of player
STRB R0, [R2, #7]
ADR R2, playerLife    ;pointer to playerLife
MOV R0, #3
STRB R0, [R2]         ;restart life as well
POP {R0-R3, PC}

;-------------------------------------------------------------------------------
; SCORE
;-------------------------------------------------------------------------------
scorePoints           ;method that will check if the last row and penultimate row matches
                      ;parameters R2(pointer to matrixLed)
PUSH{R0-R9,LR}        ; I am pushing all the register because otherwise one register is corrupted
                      ;due to bcd_convert
                      ;get the value from the last matrixes
LDRB R0,[R2, #7]
LDRB R1,[R2, #6]      ;check if this value is equal to zero to avoid negative points for player
CMP R1, #0
BEQ skipIncreasingScore ;if there was an object in the row 6 then skip all
ANDS R0, R1, R0        ; compare if they match
                      ;if they don't then we proceed to substract one point from player's life
BEQ negativeLife
ADR R1, scorePlayer   ;pointer to scorePlayer
LDR R0, [R1]
ADD R0, R0, #1        ;load the value and 1 and store it back
STR R0,[R1]
BL soundToCatch       ;write to the buzzer to hear a sound when you catch an object
B skipIncreasingScore
negativeLife
ADR R1, playerLife    ;pointer to playerLife
LDRB R0, [R1]
SUBS R0, R0, #1        ;load the value from the playerLife, substract one and store it back
STRB R0, [R1]
BNE skipIncreasingScore ;if r0 = 0 then restartGame otherwise skip
BL restartGame
skipIncreasingScore
POP{R0-R9, PC}
;-------------------------------------------------------------------------------
; updateScoreLed
;-------------------------------------------------------------------------------
updateScoreLed ;method that will read the value of scoreValue and will display
               ;this value in the LED
PUSH{R0-R1,R7, LR}
BL clear                ;restart the position of the LCD before printing anything

MOV R0, #1              ; this is a special parameters that will print a string
ADR R1, string1
BL printString          ;something that will the user how many objects has recollected

ADR R1, scorePlayer
LDR R0, [R1]
BL bcd_convert          ;finally print the score in the LCD Screen
BL PrintHex16

MOV R0, #0              ;when the parameters is zero it the function printCharacter will execute a command
MOV R7, #screenPosition ; screenPosition is a command  that will print a new line
BL printCharacter

MOV R0, #1              ; this is a special parameters that will print a string
ADR R1, string2
BL printString          ;something that will let the user know how many objects has recollected

ADR R1, playerLife
LDR R0, [R1]
BL bcd_convert         ;finally print the score in the LCD Screen
BL PrintHex16

POP{R0-R1,R7, PC}
;-------------------------------------------------------------------------------
;The following method will be used to update the objectsToCatch in the LEDMatrix
;-------------------------------------------------------------------------------
objectsToCatch ;this method will result in rain of object to catch
PUSH{R0-R9,LR}
ADR R2, matrixLed             ;pointer to matrix
ADR R6, rowsForLed            ; rows for leds that will be updated
ADR R3, objectToPick          ;first check that objectToPick is not greater than 8
LDRB R0, [R3]

CMP R0, #64                   ;there could 64 states for objects
                              ;most of them are empty to help the player to catch them
MOVEQ R0, #0

ADR R4, obstaclesToCatchMatrix
LDRB R1, [R0,R4]              ;get the value from obstaclesToCatch
                              ;descend the position of the obstacles from 1 to 6
BL scorePoints                ;check if the row 6 and 7 match to get 1 point
MOV R7, #6                    ;initialize r7
;before doing the following updating check the value in the penultimate row and last row
;to detect if they match to count
loopForUpdatingObjects
SUB R7, R7, #1    ;row above
LDRB R8, [R2, R7] ;loading the content of the row
ADD R7, R7, #1    ;make this content to descend to this row
STRB R8, [R2, R7]
SUBS R7, R7, #1   ;when we reach the penultimate row then we finish this loop
BGT loopForUpdatingObjects
;once that is finished then update the first row
STRB R1, [R2]
ADD R0, R0, #1 ;go to the next object
STRB R0, [R3]  ;store that one in the first row
POP{R0-R9,PC}

;-------------------------------------------------------------------------------
;ActionPlay
;-------------------------------------------------------------------------------
;the following method will determine the movement of the user
actionPlay ;R1 will contain the key that is pressed
          ; in this is case if R1 = 0 , LEFT, R2, = 1 RIGHT otherwise skip
PUSH{R0-R5,LR}
ADR R2, matrixLed ;pointer to matix
MOV R4, #7 ; this is a hardcoded rowofLedMatrix

CMP R1, #0                         ;if he pressed 3
BEQ leftMovement
CMP R1, #1                         ;else if he pressed 6
BEQ rightMovement
CMP R1, #2                         ;else if he pressed 9
BEQ restartAll
B endActionPlay                   ;else do nothing
leftMovement
                                   ;get the value that is contained in the row and rotate to left the value
LDRB R3, [R2, R4]
MOV R3, R3, ROR #31                ;rotate r0 right 7 places
                                   ;compare whether we have reach the limit of the board
CMP R3, #limitOfLedLeft
MOVGE R3, #:11100000              ;fix the position
STRB R3, [R2, R4]
B endActionPlay
rightMovement
LDRB R3, [R2, R4]
MOV R3, R3, LSR #1                ;rotate r0 right 1 places
CMP R3, #limitOfLedRigth          ;compare whether we have reach the limit of the board
MOVLT R3, #:00000111                ;if we have reach the limit then set position limit
STRB R3, [R2, R4]
B endActionPlay
restartAll
BL restartGame                  ;in case the user wants to restar the whole game
endActionPlay
POP{R0-R5,PC}
;------------------------------------------------------------------------------
;GameMechanics
;-------------------------------------------------------------------------------
updateStatesOfGame                      ;the following method will go through
                                        ;the array of the totalDebugginKeyBoard
                                        ;and will print the keys that have been
                                        ;pressed
PUSH{R0-R7,LR}
MOV R5, #totalDebugginKeyBoard          ;move the address of our debugginkeyboard
MOV R3, #totalKeyBoard                  ;move the address of our debugginkeyboard
MOV R1, #0
forloop2                                ;shift the values of the keys of this row first r1 < 12

LDRB R2, [R5,R1]                        ;get the value of a key being pressed
CMP R2, #&01                            ;if its value is 1 then restart it and call actionPlay
BNE skipPrinting
BL actionPlay
MOV R2, #0                              ;restart that key that was pressed
STRB R2, [R5, R1]
LDRB R7, [R3, R1]
LDR R2, [R5,R1]
skipPrinting
ADD R1, R1, #1                         ;r1++, keeps doing until we go through all the keys of the row
CMP R1, #12
BLT forloop2
POP{R0-R7,PC}

;-------------------------------------------------------------------------------
;READCLOCK
;-------------------------------------------------------------------------------

readClock                           ;function that will read the state of the clock
                                    ;return R3 with the current time of clock
                                    ;passing arguments: void
MOV R3, #timer                      ;move the the address of the clock in r3
LDRB R3, [R3]                       ;store this frequency in r3
MOV PC, LR
;-------------------------------------------------------------------------------
;Clear the Buzzer
;-------------------------------------------------------------------------------

ClearBuzzer                         ;ClearBuzzer
PUSH{R0-R1, LR}
MOV R0, #FPGAInterface ; loading the fpga
                       ;lets clean the buzzer
MOV R1, #0
STRB R1, [R0,#1]

POP{R0-R1, PC}
;-------------------------------------------------------------------------------
;PrintString
;-------------------------------------------------------------------------------
printString
LDRB R7, [R1] ;R7 will be the register that will have the value of the character

;Now print this character
;but seems this a method we will need to store our register
;in this case our register to be stored will be R1 and LR into the stack
;we will need to use the stack in here to call another method
readString

            STMFD SP!, {LR, R1}
            BL printCharacter
            LDMFD SP!, {LR, R1}

            ADD R1 ,R1, #1
            LDRB R7, [R1]
            CMP R7, #0
            BNE readString


MOV PC, LR ;return to print the rest of the string
;------------------------------------------------------------------------------
;SEND COMMAND CODE FROM ALEXIS RODRIGUEZ COPYRIGHT 2019-2020
;-------------------------------------------------------------------------------
; Procedure used to send commands serialized the data to be sent is received from
; R0 and the address from R1
; Received the address where to send in R1 and the first byte of R0 states
; which leds are going to be turned on
SVC_0
                      PUSH  {R2-R3}
                      PUSH  {R0-R1}               ; Save arguments in case program fails
                      B     skip_SVC_11
backUp_SVC_11         POP   {R0-R1}
                      PUSH  {R0-R1}               ; Save for future cases

skip_SVC_11           MOV   R2, R0                ; Save the value in R0
                      MOV   R3, R1                ; Save the value in R1 // the address
                      ADR   R1, backUp_SVC_11

                      BL  i2cinit
                      BL  startc

                      ; The address of the slave device to talk to
                      MOV R0, #:11100000
                      BL  sendCommand

                      ; ; Set the address of the ram display to talk to
                      MOV R0, R3
                      BL  sendCommand

                      ; Write to that address
                      MOV R0, R2
                      BL  sendCommand

                      ; Enable LEDMatrix
                      BL  restartc

                      ; The address of the slave device to talk to
                      MOV R0, #:11100000
                      BL  sendCommand

                      MOV R0, #&80
                      ORR R0, R0, #1        ; Enable display or disable display
                      BL  sendCommand


end_SVC_11            BL  stop

                      MOV   R0, #1
                      ; SVC   10

                      POP  {R0-R1}         ; Pop the copy of necessary registers
                      POP {R2-R3, PC}^


; Check byte is actually sent and the keep trying until it can be actually sent
sendCommand           PUSH {LR}
                      BL  send
                      CMP  R0,  #0
                      BNE  end_sendDevice
                      BL    stop
                      POP   {R0}        ;; The LR WAS PUSHED
                      MOV   PC, R1
end_sendDevice        POP   {PC}
;-------------------------------------------------------------------------------
;END OF CODE
;-------------------------------------------------------------------------------
;Buzzer communication
;-------------------------------------------------------------------------------
soundToCatch ;let's have a sound when the player catches the object
PUSH{R0-R1, LR}
MOV R0, #FPGAInterface ; loading the fpga
                      ;lets store the one sound and the buffer
MOV R1, #1            ;activate buffer
STRB R1, [R0,#1]
BL delay              ;for a shor time there will be a sound
MOV R1, #0
STRB R1, [R0,#1]      ;and then we should restart the buzzer
POP{R0-R1, PC}
;-------------------------------------------------------------------------------
;DELAY
;-------------------------------------------------------------------------------
delay
;method delay will take the value &80000 and then subtracts
;until reaching zero and the loop can exit coming back
PUSH{R2,LR}
MOV R2, #valueForDelay
loopDelay2
SUB R2, R2, #1
CMP R2, #0                          ;I am using compare to creating more delay
BNE loopDelay2                      ; I know I could use SUBS
POP {R2, PC}


;-------------------------------------------------------------------------------
;DELAY2
;-------------------------------------------------------------------------------
delay2
;method delay will take the value &80000 and then subtracts
;until reaching zero and the loop can exit coming back
PUSH{R2,LR}
MOV R2, #valueForDelay2
loopDelay
SUB R2, R2, #1                       ;I am using compare to creating more delay
CMP R2, #0                           ; I know I could use SUBS
BNE loopDelay
POP {R2, PC}
;-------------------------------------------------------------------------------
;clear
;-------------------------------------------------------------------------------
clear                           ;the following method will send a command to
                                ;printCharacter method and will make that the
                                ;the cursor moves to the start of the first line
PUSH {R0,R7,LR}                    ;save r0 and lr
;MOV R4, R0
MOV R0, #0                      ;change r0 to 0 so the data store in r7 will be executed as command
MOV R7, #2
BL printCharacter
;MOV R0, R4
POP {R0,R7,PC}                    ;recover r0 and return to SVC

;-------------------------------------------------------------------------------
;writeCompare
;-------------------------------------------------------------------------------
;function that will allow you to write to the timer register
writeCompare
MOV R0, #portA
LDRB R3, [R0, #timerCompareRegister]
MOV PC, LR

;-------------------------------------------------------------------------------
;methodToPrintCharacther
;-------------------------------------------------------------------------------
methodToPrintCharacther           ;helper methods for printing character
                                  ;the following writes to LCD  a character
                                  ;passing arguments: R7 contains character
MOV R6, #stateWRITEControl
STRB R6,[R1, #4]

STRB R7, [R1] ;output character

;MOV R2, #stateWRITEControlENABLE
ORR R6, R6, #1                     ;change the state from portB E = 1
STRB R6,[R1, #4]

BIC R6, R6, #1                     ;change the state from portB E = 0
STRB R6,[R1, #4]

MOV PC, LR

;-------------------------------------------------------------------------------

methodToControl                     ;helper methods for printing a command
                                    ;passing arguments: R7 contains commands


MOV R6, #stateWRITEControlSpecial
STRB R6,[R1, #4]                   ;store this state in the portB


STRB R7, [R1]                       ;output command

ORR R6, R6, #1                      ;change the state from portB E = 1
STRB R6,[R1, #4]                    ;

BIC R6, R6, #1                      ;change the state from portB E = 0
STRB R6,[R1, #4]


MOV PC, LR
;-------------------------------------------------------------------------------
printCharacter                    ;the following method will set up everything
                                  ;to print  a character or a command
                                  ;passing arguments: R7 contains character or command
                                  ;                   R1 is a boolean that will be used to
                                  ;                   print either a character or command
                                  ;create the sequence
                                  ;Set to read control with data bus direction as input
MOV R1, #portA                    ;load the portA

MOV R6, #stateReadControl
STRB R6,[R1,#4]                   ;change the state of the the portB using offset 4
                                  ;the port from the portA

;MOV  R5, #portA
MOV R4, #:10000000                    ;mov the value that will be tested to Know
                                  ;if the screen is not busy and thus we can print
tryAgain

            ORR R6, R6, #1        ;change the state from portA E = 1
            STRB R6,[R1, #4]      ;enable bus

            LDRB R3, [R1]         ;Read LCD status byte

            BIC R6, R6, #1        ;change the state from portA E = 0
            STRB R6,[R1, #4]
            TST R3, R4            ;if bit 7 byte was high repeat process

            BNE tryAgain
                                 ;set to write data with data bus direction as output
                                 ;call the functions but remember to push register and LR


CMP R0, #1                      ;boolean expression is contain in R0
                                ;if it is 1 then we have to print a char otherwise
                                ;we print a command
STMFD SP!, {LR, R2, R6}         ;store the following register to avoid corruption
BEQ isAchar
BL methodToControl
B skipthis

          isAchar
          BL methodToPrintCharacther


        skipthis
LDMFD SP!, {LR, R2, R6}       ;recover register from stack
MOV PC, LR


;-------------------------------------------------------------------------------
PrintHex8                         ;function that will print 8 hexadecimal
                                  ;passing arguments R0
PUSH {R0,LR}                      ;store LR in case lost when calling rest of functions
                                  ;WE will store the value R0 in case R0 becomes corrupted
MOV R0, R0, ROR #4                ;rotate r0 right 4 places
BL PrintHex4                      ;print the first 4 hexadecimal numbers
MOV R0, R0, ROR #(32 - 4)         ;print the last 4 hexadecimal numbers
BL PrintHex4
                                  ;recover the value from
POP {R0,PC}


;-------------------------------------------------------------------------------
PrintHex16                        ;function that will print 8 hexadecimal
                                  ;passing arguments R0
PUSH {LR}                         ;store LR in case lost when calling rest of functions
MOV R0, R0, ROR #8                ;rotate r0 8 places to the right
BL PrintHex8
MOV R0, R0, ROR #(32 -8)          ;rotate r0 8 places to the left
BL PrintHex8
POP {PC}


;-------------------------------------------------------------------------------
PrintHex4
;PUSH{R0}                  ;WE will store the value R0 in case R0 becomes corrupted
MOV R8, R0
BIC R0, R0, #&FFFFFFF0    ; Mask off everything except lower 4 bits
CMP R0, #9
ADDLE R7, R0, #'0'
ADDGT R7, R0, #('A' - &10)
MOV R0, #1                ;boolean for printing a character in printCharacter
PUSH{LR}                  ;save LR in stack
BL printCharacter         ;call the function that will need a character be stored in R7
MOV R0, R8
POP {PC}                  ;recover R0 and LR values

;-------------------------------------------------------------------------------
;                               KEYBOARD
;-------------------------------------------------------------------------------
;KEYBOARD define starts at 36600 and  4000 to avoid some errors  such as
;totalKeyBoard out of range
org&3600
totalKeyBoard
DEFB  '3',  '6',  '9', '#',  '2',  '5', '8',  '0',  '1', '4',  '7',  '*'
org&4000
totalDebugginKeyBoard
DEFB  0,  0,  0, 0,  0,  0, 0,  0,  0, 0,  0,  0
ALIGN


;-------------------------------------------------------------------------------
;           I2C PROTOCOL & bcd_convert
;-------------------------------------------------------------------------------
INCLUDE i2c.s
INCLUDE bcd_convert.s
