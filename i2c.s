;ALEXIS JAIR RODRIGUEZ COPYRIGHT 2019 - 2020
;CODE IMPORTED TO ALLOW THE COMMUNICATION BETWEEN THE
;THE LED SCREEN AND THE BOARD
;***************************************
;Ports Used for I2C Communication
;***************************************
sda equ :01   ; First pin is data
scl equ :10   ; Second pin is clock
clearSdaScl EQU   :00
setSdaScl EQU     :11
; sda equ P0.0
; scl equ P0.1

;***************************************
;Initializing I2C Bus Communication
;***************************************
; Both bits need to be set before Initializing I2C communication
i2cinit       PUSH  {R0-R1}
              MOV   R1, #&20000000

              ; TESTING
              ; MOV   R0, #setSdaScl               ; Both lines are not pulled down
              ; STRB  R0, [R1, #5]                   ; Use S1 connector bottom store in control register
              ; LDRB  R0, [R1, #4]                    ; Both should be zero
              ; MOV   R0, #clearSdaScl                ; Both should be 1
              ; STRB  R0, [R1, #5]                   ; Use S1 connector bottom store in control register
              ; LDRB  R0, [R1, #4]                    ; Both should be zero
              ;
              ; MOV   R0, #sda
              ; STRB  R0, [R1, #5]                   ; Use S1 connector bottom store in control register
              ; LDRB  R0, [R1, #4]                    ; first bit data should be zero
              ;
              ; MOV   R0, #sda
              ; BIC   R0, R0, #sda
              ; STRB  R0, [R1, #5]                   ; Use S1 connector bottom store in control register
              ; LDRB  R0, [R1, #4]                    ; first bit data should be a one (floating)

              MOV   R0, #clearSdaScl               ; Both lines are not pulled down
              STRB  R0, [R1, #5]                   ; Use S1 connector bottom store in control register
checkAgain    LDRB  R0, [R1, #4]                   ; Read the state of the lines if they are free they both are high
              CMP   R0, #setSdaScl
              BNE   checkAgain
              ; ; Start communication using I2C by pulling down SDA (serialized data)
              ; ; It is mapped to control register pin 1 is clock and pin 2 is data
              ; ; While clock is set and data is clear sets the Communication to Start
              ; MOV   R0, #sda
              ; STRB  R0, [R1, #5]                   ; Pull down the data to show the start
              POP   {R0-R1}
              MOV   PC, LR

; i2cinit:
;   setb sda
;   setb scl
;   ret

;****************************************
;ReStart Condition for I2C Communication
;****************************************

restartc    PUSH  {R0-R1}
            MOV   R1, #&20000000
            LDRB  R0, [R1,  #4]
            ORR   R0, R0, #scl                   ;
            STRB  R0, [R1, #5]                   ; Pull down the clock
            BIC   R0, R0, #sda                  ;
            STRB  R0, [R1, #5]                   ; Pull up data
            BIC   R0, R0, #scl                  ;
            STRB  R0, [R1, #5]                   ; Pull up the clock
            ORR   R0, R0, #sda
            STRB  R0, [R1,  #5]                   ; Pull down the data
            POP   {R0-R1}
            MOV   PC, LR
;****************************************
;Start Condition for I2C Communication
;****************************************
; Start communication using I2C by pulling down SDA (serialized data)
; It is mapped to control register pin 1 is clock and pin 2 is data
; While clock is set and data is clear sets the Communication to Start
startc      PUSH  {R0-R1}
            MOV   R1, #&20000000

            LDRB  R0, [R1,  #4]
            MOV   R0, #sda
            STRB  R0, [R1, #5]                   ; Pull down the data to show the start
            LDRB  R0, [R1,  #4]
            POP   {R0-R1}
            MOV   PC, LR

;*****************************************
;Stop Condition For I2C Bus
;*****************************************
; Assumes the clock is being pulled down
stop      PUSH  {R0-R1}
          MOV   R1, #&20000000
          LDRB  R0, [R1, #5]
          ; ORR   R0, R0, #scl                   ; Pull down the clock
          ; STRB  R0, [R1, #5]                   ;
          BIC   R0, R0, #sda                   ; Pull up the data
          STRB  R0, [R1, #5]                   ;
          BIC   R0, R0, #scl                   ; Pull UP the clock
          STRB  R0, [R1, #5]
          ORR   R0, R0, #sda                   ; Pull down the data
          STRB  R0, [R1, #5]                   ;

          POP   {R0-R1}
          MOV   PC, LR
;*****************************************
;Sending Data to slave on I2C bus
;*****************************************
; Received the data to be sent in R0 and returns in Ro if datra was sent correctly
send      PUSH {R1-R3}
          MOV   R3, #&20000000
          MOV   R2, #8

          ; LSL   R0, R0, #24                    ; Leave 8 msb at the end

          LDRB  R1, [R3, #5]                   ; Load whether the clock is being pulled
back      ORR   R1, R1, #scl                   ; clear serial clock bit // updating only the bits being used
          STRB  R1, [R3, #5]                   ; Pull down clock as data can only change when clock is low
          LSL   R0, R0, #1                     ; Most significant bit is sent first
          ; ORRCC R1, R1, #sda                   ; ; By default it will send a zero CARRY IS CLEAR
          ; BICCS R1, R1, #sda                   ; Do not pull down by clearing the bit
          TST   R0, #:100000000                ; Check the eight bit is a zero or a one
          ORREQ R1, R1, #sda                   ; ; By default it will send a zero
          BICNE R1, R1, #sda                   ; Do not pull down by clearing the bit
          STRB  R1, [R3, #5]                   ; Update the serial data signal
          BIC   R1, R1, #scl                   ; Pull up clock to send the data
          STRB  R1, [R3, #5]                   ;
          SUBS  R2, R2, #1
          BGT   back                           ; Send the eight bits
          ORR   R1, R1, #scl                   ; Pull the clock down
          STRB  R1, [R3, #5]                   ;
          BIC   R1, R1, #sda                   ; Set the data bit and hope
          STRB  R1, [R3, #5]                   ; it to be pulled down if the data was received
          BIC   R1, R1, #scl                   ; Pull up the clock
          STRB  R1, [R3, #5]                   ; (set the clock)
          ; ; NOP
          ; NOP
          ; NOP
          ; MOV   R0, #sda
          ; STRB  R0, [R3, #5]                   ; (set the clock)
          ; LDRB  R2, [R3, #4]                   ; data bit should be zero



          LDRB  R2, [R3, #4]                   ; Load the current status of the clock and data signals
          ; MOV   R0, #1
          AND   R2, R2, #sda
          EORS   R2, R2, #sda
          MOVNE R0, #1                         ; If the bit was not pulled down data was not received correctly, if the result is different than zero 0 xor 1 is 1
          MOVEQ R0, #0                         ; If they do not match is okay

          ORR   R1, R1, #scl                   ;
          STRB  R1, [R3, #5]                   ; Pull down the clock
          ; LDRB  R2, [R3, #4]                   ; Load the current status of the clock and data signals
          ; ; MOV   R0, #1
          ; TST   R2, #sda
          ; MOVNE R0, #0                         ; If the bit was not pulled down data was not received correctly, if the result is zero ack was received as it changed from 1 to zero
          ; MOVEQ R0, #1                         ; If they do not match is okay
          POP   {R1-R3}
          MOV   PC, LR
