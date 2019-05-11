; ------------------------------------------------------------------------------
;               Alexis Jair Rodriguez Nunez
;               29th March 2019
;   List of definitions
; ------------------------------------------------------------------------------
portA                 EQU   &10000000         ; Port A returns the values at the devices pins
timer                 EQU   &10000008         ; The counter that increments at each clock cycle
Max_Counter           EQU   255               ; 256 different states in the counter including 0
oneTenthOfASecond     EQU   100               ; in a tenth of a second the clock gets written 100 times as frequency is 1 kHz
noButton              EQU   0                 ; Default value used in the read button SVC
upper                 EQU   1                 ; Value returned from read button SVC if upper pressed
lower                 EQU   2                 ; Value returned from read button SVC if lower pressed
startButton           EQU   2                 ; Lower button is start button
pauseButton           EQU   1                 ; Upper button is Pause/Restore button
readControl           EQU   :100              ; Read - Control Register - Interface Inactive
LCDBusy               EQU   :10000000         ; Most sifnificant bit is busy bit
writeData             EQU   :00100010         ; Backlight enable, write - Data register - Interface Inactive
lowerButton           EQU   :10000000         ; Bit seven at port B is set when lower button is pressed
upperButton           EQU   :01000000         ; Bit six at port B is set when upper button is pressed
writeControl          EQU   :00100000         ; LCD backlight on     ; Write - Control register - Interface Inactive
displayClear          EQU   &01               ; Byte to output in control to reset the LCD to intial state
offsetToPortB         EQU   4                 ; Port B is at address &10000004
enable                EQU   &01               ; Interface Active
disable               EQU   &00               ; Interface Inactive
clearMode             EQU   &1F               ; Five less significant bits represent the mode
System_Mode           EQU   &1F               ; System mode
SVC_Mode              EQU   &13               ; Supervisor mode
Max_SVC               EQU   11                 ; There are only 8 SVCs implemented
maximumDecimal        EQU   9                 ; One digit decimals go from 0-9
User_Mode             EQU   &10               ; User mode
lcdControlBits        EQU   :00100111         ; Bits to be cleared are 5(LCD backlight), bit 4(disable LEDs), and the last 3 bits
LEDEnable             EQU   &10               ; Bit 4 controls if LEDs are enable or not
ten100ms              EQU   10                ; One second has ten 100ms
millisecondsPos       EQU   &05               ; The LCD position where to output the number of milliseconds
secondsPos            EQU   &00               ; The LCD position where to output the number of seconds
bitSevenSet           EQU   &80               ; All other bits except for the 7th bit are set
offsetToInterrupEn    EQU   4                 ; Offset to port that sets if each source of interrupt is enable/disable
IRQ_Mode              EQU   &12               ; Interrupt mode
enableInterrupt       EQU   :10000000         ; Bit seven when clear means interrupts are enabled
sourcesIRQEnable      EQU   :10000011         ; Enable loweButton - upperButton ---- Timer
enableFastInterrupt   EQU   :01000000         ; Bit six when clear means fast interrupt are enabled
interruptSources      DEFW  &10000018         ; Port where interrup bits are visible;
FPGAInterface         EQU   &20000000         ; The address space where the FPGA is mapped to
setPinsAsInOrOut      EQU   &F                ; Set pins 0 to 3 to be inputs while the rest are outputs
row3_6_9_hash         EQU   :00100000         ; Bit 5 when high activates the row with the keys 3 - 6 - 9 - #
row2_5_8_0            EQU   :01000000         ; Bit 6 when high activates the row with the keys 2 - 5 - 8 - 0
row1_4_7_asterisk     EQU   :10000000         ; Bit 7 when high activates the row with the keys 1 - 4 - 7 - *
timerCompare          EQU   &1000000C         ; Timer compare register, generates an interrupt when matches counter
secondLineDisplay     EQU   &40               ; The position of the second line in the display
firstLineDisplay      EQU   &00               ; The position of start of the first line in the display
readData              EQU   :00100110         ; Backlight enable, read - Data register - Interface Inactive
setCursorShift        EQU   :00000110         ; 1 (1 = Right 0 = left ) ( 1 = shift 0 = cursor)
firstColumn           EQU   0                 ; The first column is at the label itself
fourBytes             EQU   4                 ; 4 bytes same as a word
pressed               EQU   &FF               ; A key is said to be pressd after being pressed for 8 continuos milliseconds
released              EQU   &00               ; A key is said to be release if after 8 continuos milliseconds it has not been pressed
numberOfRows          EQU   3                 ; There are three rows in the keyboard
keysDataOffset        EQU   2                 ; The offset to the data register of the PIO implementing the keyboard
keysControlOffset     EQU   3                 ; The offset to the control register of the PIO implementing the keyboard
firstInputPinIO       EQU   :0001             ; The first input pin in bit 0
lastByte              EQU   &F                ; The last byte in a number
