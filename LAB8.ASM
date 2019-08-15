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
		movlw 0x06
		movwf ADCON1
		clrf	TRISD				;PortD output
		clrf	TRISE				;PortD output
		movlw	0xff
		movwf	TRISA				;PortA input
	
	
		call BANK0
		clrf	PORTD
		clrf	PORTE

main:	CALL hthla
main1:	movf	ADRESH, w
		movwf	0X71
		movlw 0x40
		subwf 0x71,w
		btfsc STATUS,C 
		call buzzer
		call leds
		goto main


leds:
	movlw	0Xff
	movwf  PORTD
	return 

buzzer:
	bsf PORTE,2
	return 
 


BANK1:
	BSF STATUS, RP0
	BCF STATUS,RP1
	RETURN 
BANK0:
	BCF STATUS, RP0
	BCF STATUS,RP1
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

	
	goto$

	end