;following program are the definitions of printing in LCD
;Created by Marcel Moran C. 28/01/2019
;defining the ports
portA EQU &10000000														;communication with lcd
portB EQU &10000004                           ;control communication to print char
timer EQU &10000008                           ;port that commuincates with the clock
interruptBits EQU &1C                         ;buttonInterrupts
timerCompareRegister EQU &0C                  ;register where exists a timer register
stateReadControl EQU :00000100                ;defination of variable for printCharacter in lcd
stateReadControlENABLE EQU :00000101          ;defination of variable for printCharacter in lcd
stateWRITEControl EQU :00000010               ;defination of variable for printCharacter in lcd
stateWRITEControlSpecial EQU :00000000        ;defination of variable for printCharacter in lcd
stateWRITEControlENABLE EQU :00000011         ;defination of variable for printCharacter in lcd
stateWRITEControlENABLESpecial EQU :00000001  ;defination of variable for printCharacter in lcd
screenPosition EQU &C0                        ;creation of new line when printing this value as command
offset1 EQU &1                                ;+1
specialCharacter EQU &1F											;new line
checkButtonLower EQU :10000000                ;value that will be compared to know when the lower button has been pushed
checkButtonUpper EQU :01000000                ;value that will be compared to know when the upper button has been pushed
checkClock EQU :00000001                      ;value that will be compared to know when timer has increased
activateTimerAndUpper EQU :11000001           ;activating interrup of timer and upper button
disableTimerAndUpper EQU :11000000            ;deactivating timer and upper button interrups
activateTimerCompare EQU :00000001						;bits that will activate the timer compare
offset3 EQU 3                                 ;+3
activateIRQ EQU :10000000											;value to activate interrupt routines
deactivatingTimerCompare EQU :00000000        ;deactivatingTimer
FPGAInterface         EQU   &20000000         ; The address space where the FPGA is mapped to
limitOfLedLeft EQU &100                       ;maximum movement allow for player(LEFT)
limitOfLedRigth EQU &7                        ;maximum movement allow for player(RIGHT)
valueForDelay EQU &1000                       
valueForDelay2 EQU &500
;memoryToADD EQU &58
