LIST P=PIC16F877
include <P16f877.inc>
;include  <BCD.inc> 
__CONFIG _CP_OFF & _WDT_OFF & _BODEN_ON & _PWRTE_ON & _RC_OSC & _WRT_ENABLE_ON & _LVP_OFF & _DEBUG_OFF & _CPD_OFF


org 0x00
reset:
	
 	goto start
	org 0x10
start:
		call BANK1
		clrf ADCON1
		movlw 0x06
		movwf ADCON1
		clrf	TRISD				;PortD output
		clrf	TRISE				;PortE output
		movlw	0xff
		movwf	TRISA				;PortA input
	
		call BANK0
		clrf	PORTD
		clrf	PORTE
		
 		CALL INITILIZE

main:	movlw 0x8F
		CALL SEND_C
		movlw 0x76
		CALL SEND_D

		movlw 0x8D
		CALL SEND_C
		movlw 0x2E
		CALL SEND_D
		
		CALL hthla
		movf ADRESH, w
		movwf 0X71
		CALL div
		CALL ADD_30
		
		movlw 0x8E
		CALL SEND_C
		movf 0x72,w
		CALL SEND_D

		movlw 0x8C
		CALL SEND_C
		movf 0x75,w
		CALL SEND_D

	goto main

ADD_30:
	clrw
	addlw 0X30
	addwf 0X75

;	addlw 0X30
	addwf 0X72
	return

div:
bcf STATUS,C
movlw 0x00
movwf 0x75 ; unit
movwf 0x72 ;Tenths
lulaa_1:
	movlw 0x33
	subwf 0x71
	btfss STATUS,C
	goto lulaa_2
	incf 0x75,f   ; unit
	goto lulaa_1
lulaa_2:
	addwf 0x71, f
	movlw 0x05
	subwf 0x71 
	btfss STATUS,C
	return
	incf 0x72,f  ;Tenths
	goto lulaa_2+1



 INITILIZE:
  MOVLW 0X30
  CALL SEND_C
  CALL delay_ONE_HALFu
  CALL delay_ONE_HALFu
  CALL delay_ONE_HALFu
  MOVLW 0X30
  CALL SEND_C
  MOVLW 0X30
  CALL SEND_C
  MOVLW 0X38
  CALL SEND_C
  MOVLW 0X0C
  CALL SEND_C
  MOVLW 0X06
  CALL SEND_C
  MOVLW 0X01
  CALL SEND_C
  RETURN

 SEND_C:
  MOVWF PORTD
  BCF PORTE,1
  BSF PORTE,0
  NOP 
  BCF PORTE,0
  CALL delay_ONE_HALFu
  RETURN

 SEND_D: 
   MOVWF PORTD
   BSF PORTE,1
   BSF PORTE,0
   NOP 
   BCF PORTE,0
   CALL delay_ONE_HALFu
  RETURN 



hthla:	bcf		STATUS, RP0
		bsf		STATUS, RP0			;Bank1 <------
;-------------------------------------------------
		movlw	0x02
		movwf	ADCON1				; all A analog; E digital
									; format : 6 lower bit of ADRESL =0
		clrf	TRISD				;PortD output
		movlw	0xff
		movwf	TRISA				;PortA input

		bcf		STATUS, RP0			;Bank0 <------
;-------------------------------------------------
		bcf		INTCON, GIE			;Disable interrupts
		movlw	0x81
		movwf	ADCON0				;Fosc/32, channel_0, ADC on
		call	d_20				;Delay TACQ
lulaa:	bsf		ADCON0, GO			;start conversion
waitc:	btfsc	ADCON0, GO			;wait end of conversion
		goto	waitc
		call	d_4

		
return

;---------------------------------------------------------------------------------------
delay_ONE_HALFu:     ;-----> 1ms delay
	  movlw  0x0B   ;N1 = 11d
 	  movwf  0x51
	  CONT1: movlw  0x96   ;N2 = 150d
 	  movwf  0x52
	  CONT2: decfsz  0x52, f
	  goto  CONT2
	  decfsz  0x51, f
	  goto  CONT1
 return      ; D = (5+4N1+3N1N2)*200nsec = (5+4*11+3*11*150)*200ns = 999.8us=~1ms


d_20:	movlw	0x20
		movwf	0x22
lulaa1:	decfsz	0x22, f
		goto	lulaa1
		return

d_4:	movlw	0x06
		movwf	0x22
lulaa3:	decfsz	0x22, f
		goto	lulaa3
		return
;---------------------------------------------------------------------------------------

BANK1:
	BSF STATUS, RP0
	BCF STATUS,RP1
	RETURN 
BANK0:
	BCF STATUS, RP0
	BCF STATUS,RP1
	RETURN 
	
	goto$

	end