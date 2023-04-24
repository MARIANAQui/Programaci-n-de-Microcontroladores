; Archivo: PreLab2.s
; Dispositivo: PIC16F887
; Autor: Mariana Quirós
; Compilador: pic-a (v2.30), MPLABX V5.40
;
; Programa: contador ascendente y descendente (sumador de 4 bits)
; Hardware: LEDs en el puerto A, push button, pull down(RBO y RB1)
;
; Creado: 30 enero, 2022
; Última modificación: 30 enero, 2022

PROCESSOR 16F887
#include <xc.inc>

;configuration word 1
    CONFIG FOSC=INTRC_NOCLKOUT 
    CONFIG WDTE=OFF 
    CONFIG PWRTE=OFF 
    CONFIG MCLRE=OFF 
    CONFIG CP=OFF 
    CONFIG CPD=OFF 
    
    CONFIG BOREN=OFF 
    CONFIG IESO=OFF 
    CONFIG FCMEN=OFF 
    CONFIG LVP=OFF 
    
    ;CONFIGURATION WORD 2
    CONFIG WRT=OFF 
    CONFIG BOR4V=BOR40V 
    PSECT udata_bank0 ;common memory
	cont_small: DS 1 ;1 byte
	cont_big: DS 1
    
	cont: DS 2 ;1 byte
	;cont_big: DS 1
	UP EQU 1 
	DOWN EQU 0
    
    PSECT resVect, class=CODE, abs, delta=2 
    ;vector reset
    ORG 00h	;posición 0000h para el reset
    resetVec:
	PAGESEL main
	goto main
	
    PSECT code, delta=2, abs
    ORG 100h ; posición para el código
    ;Configuración
    main:
	call	config_io  
	call	config_reloj 
	banksel PORTA	; banco 0
	
    ;loop principal
    loop:
	btfsc PORTB, UP 
	call inc_porta
	btfsc PORTB,DOWN
	call dec_porta
	goto loop   ; loop forever

   ;sub rutinas
       delay_big:
	movlw 197 
	movwf cont_big 
	call delay_small 
	decfsz cont_big, 1 
	goto $-2 
	return

    delay_small:
	movlw 165 
	movwf cont_small
	decfsz cont_small, 1 ;
	goto $-1  

	return
    inc_porta:
	call delay_small //antirebote
	btfsc PORTB, UP
	goto $-1
	incf PORTA
	return
    dec_porta:
	call delay_small
	btfsc PORTB, DOWN
	goto $-1
	decf PORTA
	return   
    config_io:
	bsf	STATUS,5 ;banco 11
	bsf	STATUS,6 
	clrf	ANSEL	; pines digittales
	clrf	ANSELH
	
	bsf	STATUS,5 ; banco 01
	bcf	STATUS,6 
	clrf	TRISA	 ; port A como salida
	bsf	TRISB, UP
	bsf	TRISB, DOWN
	
	bcf	STATUS, 5 ; banco 00
	bcf	STATUS, 6
	clrf	PORTA
	return
    
    config_reloj:
	banksel OSCCON
	bcf	IRCF2	  ; OSCCON,6
	bsf	IRCF1	  ; OSCCON,5
	bcf	IRCF0	  ; OSCCON,4
	bsf	SCS	  ; reloj interni
	
	return 
		   
END


