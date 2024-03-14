//*****************************************************************
// Universidad del Valle de Guatemala
// IE2023: Programacion de microcontroladores
// Proyecto: Proyecto.asm
// Created: 5/3/2024 12:18:45
// Author : alane
//*****************************************************************************
// Encabezado
//*****************************************************************************
.INCLUDE "M328PDEF.inc"
.equ T1Value = 0x0BDC
//.equ T1Value = 0xFE17
.CSEG //Inicio del código
.ORG 0x00 
	JMP MAIN			//Vector reset
.org 0x08				//Vector interrupçion puerto b
	JMP ISR_PCINT0
.ORG 0x001A
	JMP TIM1_OVF
.org 0x0020
	JMP TIM0_OVF
MAIN:
//*****************************************************************************
// Stack Pointer
//*****************************************************************************
	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R17, HIGH(RAMEND)
	OUT SPH, R17
//*****************************************************************************
// Tabla de Valores
//*****************************************************************************
	TABLA7SEG: .DB 0b100_0000, 0b111_1001, 0b010_0100, 0b011_0000, 0b001_1001, 0b001_0010, 0b000_0010, 0b111_1000, 0b000_0000, 0b001_0000
//*****************************************************************************
// Configuracion
//*****************************************************************************
Setup:
//7 SEGMENTOS
	LDI ZH, HIGH(TABLA7SEG << 1)
	LDI ZL, LOW(TABLA7SEG << 1)


	LDI R16, 0b1111_1111
	OUT DDRD, R16

	LDI R16, 0b0011_0000
	OUT DDRB, R16

	LDI R16, 0b0011_1111
	OUT DDRC, R16

	LDI R16, 0b0000_1111
	OUT PORTB, R16

	LDI R16,0b0001//pines de control
	STS PCICR,R16

	LDI R16, 0b0000_0001
	STS TIMSK1, R16


	LDI R16, 0b0000_1111 //coloca la máscara a lo pines pertenecientes
	STS PCMSK0, R16
	
	CALL IdelayT0
	CALL IdelayT1	

	SEI		

//*******************************************************
// Apagar tx y rx
//*******************************************************
	LDI R16, 0x00
	STS UCSR0B, R16

	LDI R16, 0
	LDI R17, 0
	LDI R18, 0
	LDI R19, 0 
	LDI R20, 0
	LDI R21, 0 
	LDI R22, 0
	LDI R23, 0
	LDI R24, 0 //libre
	LDI R25, 0
	LDI R26, 0
	LDI R27, 0
	LDI R28, 0
	LDI R29, 0
	CLR R0
	CLR R1
	CLR R2
	CLR R3
	CLR R4
	CLR R10
	CLR R15
	INC R0 //DIA 0
	//R2 DIA 1
	
	INC R1 //Contador de mes
	INC R3 //MES 0
	// R4 MES 0

	CLR R5 //OR para configurar distintos modos
	CLR R6 //Variable de modificacion
	CLR R7 //Variable de eleccion de display (Unidades, decenas, etc.)
	CLR R8 // TEMP 
	CLR R11
	CLR R12
	CLR R13
	CLR R14
	INC R19
//*******************************************************
// LOOP
//*******************************************************
loop:
	
	SBRS R19, 0
	RJMP ESTADOFECHA
//*****************************************************************
//                            HORA
//*****************************************************************
ESTADORELOJ: 
	SBRC R7, 0
	MOV R6, R23
	SBRS R7, 0
	MOV R6, R22
	CBI PORTC, PC4
	CBI PORTC, PC5
	LDI ZH, HIGH(TABLA7SEG << 1)
	LDI ZL, LOW(TABLA7SEG << 1)
	ADD ZL, R22
	SBI PORTC, PC1
	LPM R20, Z
	OUT PORTD, R20
	CALL delaybounce3
	CBI PORTC, PC1


	LDI ZH, HIGH(TABLA7SEG << 1)
	LDI ZL, LOW(TABLA7SEG << 1)
	ADD ZL, R18
	SBI PORTC, PC0
	LPM R20, Z
	OUT PORTD, R20

	CALL delaybounce3

	CBI PORTC, PC0

	LDI ZH, HIGH(TABLA7SEG << 1)
	LDI ZL, LOW(TABLA7SEG << 1)
	ADD ZL, R23
	SBI PORTC, PC2
	LPM R20, Z
	OUT PORTD, R20
	SBRS r27, 0
	RJMP PP1
	RJMP PP2
PP1:
	SBI PORTD, PD7
	RJMP Seguir
PP2:
	CBI PORTD, PD7
	RJMP Seguir
Seguir:
	CALL delaybounce3
	CBI PORTC, PC2

	LDI ZH, HIGH(TABLA7SEG << 1)
	LDI ZL, LOW(TABLA7SEG << 1)
	ADD ZL, R25
	SBI PORTC, PC3
	LPM R20, Z
	OUT PORTD, R20
	CALL delaybounce3
	CBI PORTC, PC3
	SBRS R19, 3
	RJMP ENCENDERMASK
	RJMP CONFIH
//*****************************************************************
//CONFIGURACION DE HORA
//*****************************************************************
CONFIH:
	SBI PORTB, PB5
	LDI R16, 0b0000_0000
	STS TIMSK1, R16
	
	SBRC R7, 0
	RJMP CONFIVERI2
CONFIVERI1:
	MOV R22, R6					
	CPI R22, 0b000_1010             //Contador de minutos
	BREQ OVERFLOCONFI
	CPI R22, 0b1111_1111
	BREQ UNDERFLOCONFI
	RJMP loop

UNDERFLOCONFI:
	LDI R22, 9
	DEC R18
	CPI R18, 0xFF
	BRNE CONFIA1
	LDI R22, 9
	LDI R18, 5
	RJMP loop
CONFIA1:
	RJMP loop
OVERFLOCONFI:
	CLR R22
	INC R18                         //Contador de decenas
	CPI R18, 0b000_0110
	BREQ OVERFLOCONFI2
	RJMP loop
OVERFLOCONFI2:
	CLR R18
	RJMP loop

CONFIVERI2:
	MOV R23, R6
	CPI R23, 0b1111_1111
	BREQ UNDERFLOCONFI2
	CPI R25, 0b000_0010
	BREQ CONFITOP24                       //Contador de horas
	CPI R23, 0b000_1010
	BREQ OVERFLOCONFI3
	CPI R23, 0b1111_1111
	BREQ UNDERFLOCONFI2
	rjmp loop
UNDERFLOCONFI2:
	LDI R23, 9
	DEC R25
	CPI R25, 0b1111_1111
	BRNE CONFIFIN
	LDI R25, 2
	LDI R23, 3
	RJMP loop
OVERFLOCONFI3:
	CLR R23
	INC R25                         //Contador de decenas de horas
	rjmp loop
CONFITOP24:
	CPI R23, 0b0000_0100
	BREQ CONFITOP2
	RJMP loop
CONFITOP2:
	CLR R23
	CLR R25
CONFIFIN:
	RJMP loop
//*****************************************************************
//                            FECHA
//*****************************************************************
ESTADOFECHA:
	SBRS R19, 1
	RJMP ESTADOALARMA
	SBI PORTC, PC4
	CBI PORTC, PC5

	LDI ZH, HIGH(TABLA7SEG << 1)
	LDI ZL, LOW(TABLA7SEG << 1)
	ADD ZL, R0
	SBI PORTC, PC1
	LPM R20, Z
	OUT PORTD, R20
	CALL delaybounce3
	CBI PORTC, PC1


	LDI ZH, HIGH(TABLA7SEG << 1)
	LDI ZL, LOW(TABLA7SEG << 1)
	ADD ZL, R2
	SBI PORTC, PC0
	LPM R20, Z
	OUT PORTD, R20

	CALL delaybounce3

	CBI PORTC, PC0

	LDI ZH, HIGH(TABLA7SEG << 1)
	LDI ZL, LOW(TABLA7SEG << 1)
	ADD ZL, R3
	SBI PORTC, PC2
	LPM R20, Z
	OUT PORTD, R20
	CALL delaybounce3
	CBI PORTC, PC2

	LDI ZH, HIGH(TABLA7SEG << 1)
	LDI ZL, LOW(TABLA7SEG << 1)
	ADD ZL, R4
	SBI PORTC, PC3
	LPM R20, Z
	OUT PORTD, R20
	CALL delaybounce3
	CBI PORTC, PC3
	SBRS R19, 3
	RJMP ENCENDERMASK
	RJMP CONFIF
//*****************************************************************
//CONFIGURACION DE FECHA
//*****************************************************************
CONFIF:
	LDI R16, 0b0000_0000
	STS TIMSK1, R16
	
	SBRC R7, 0
	RJMP CONFINM
//********************************************************************************************************************************************
//------------------------------------------------------------DIA-----------------------------------------------------------------------------
//********************************************************************************************************************************************
CONFIFECHA1:
	SBI PORTB, PB5
	MOV R0, R6
	CP R0, R9
	BREQ CONFINICRE7
	LDI R24, 2
	CP R1, R24
	BRNE CONFICOMP
	LDI R24, 2
	CP R2, R24
	BRNE CONFICOMP
	LDI R24, 9
	CP R0, R24
	BREQ CONFINM
	RJMP loop
CONFINICRE7:
	RJMP loop
CONFICOMP:
	LDI R24, 3
	CP R2, R24
	BREQ CONFITOPDIA
CONFISUMANORM:
	LDI R24, 10
	CP R0, R24
	BREQ CONFICD

	RJMP loop
CONFITOPDIA:
	LDI R24, 1
	CP R1, R24
	BREQ CONFIPR1

	LDI R24, 3
	CP R1, R24
	BREQ CONFIPR1

	LDI R24, 4
	CP R1, R24
	BREQ CONFIPR2

	LDI R24, 5
	CP R1, R24
	BREQ CONFIPR1

	LDI R24, 6
	CP R1, R24
	BREQ CONFIPR2

	LDI R24, 7
	CP R1, R24
	BREQ CONFIPR1

	LDI R24, 8
	CP R1, R24
	BREQ CONFIPR1

	LDI R24, 9
	CP R1, R24
	BREQ CONFIPR2

	LDI R24, 10
	CP R1, R24
	BREQ CONFIPR1

	LDI R24, 11
	CP R1, R24
	BREQ CONFIPR2

	LDI R24, 12
	CP R1, R24
	BREQ CONFIPR1

	rjmp loop
CONFIPR1:
	LDI R24, 2
	CP R0, R24
	BREQ CONFICD
	RJMP loop
CONFIPR2:
	LDI R24, 1
	CP R0, R24
	BREQ CONFICD
	RJMP loop

CONFICD:
	CLR R0
	INC R2
	RJMP loop
SALTO: 
	MOV R9, R0
	RJMP loop

//********************************************************************************************************************************************
//------------------------------------------------------------MES-----------------------------------------------------------------------------
//********************************************************************************************************************************************
CONFINM:
	MOV R3, R6
	LDI R24, 1
	CP R4, R24
	BREQ CONFITOPMES
	CP R3, R9
	BRNE CONFINICRE5
	INC R1
CONFINICRE5:
	LDI R24, 10
	CP R3, R24
	BREQ CONFITOPNMES
	RJMP SALTO2
CONFITOPNMES:
	CLR R3
	INC R4
	RJMP SALTO2
CONFITOPMES:
	CP R3, R9
	BRNE CONFINICRE6
	INC R1
CONFINICRE6:
	LDI R24, 3
	CP R3, R24
	BREQ CONFICM
	RJMP SALTO2
CONFICM:
	CLR R1
	CLR R3
	CLR R4
	INC R3
	MOV R9, R3
	RJMP SALTO2
SALTO2:
	MOV R9, R3
	RJMP loop
	RJMP loop
//*****************************************************************
//                          ALARMA
//*****************************************************************
ESTADOALARMA:
	SBRS R19, 2
	RJMP loop
	CBI PORTC, PC4
	SBI PORTC, PC5
	// DIPLAY 1
	LDI ZH, HIGH(TABLA7SEG << 1)
	LDI ZL, LOW(TABLA7SEG << 1)
	ADD ZL, R11
	SBI PORTC, PC1
	LPM R20, Z
	OUT PORTD, R20
	CALL delaybounce3
	CBI PORTC, PC1

	// DIPLAY 2
	LDI ZH, HIGH(TABLA7SEG << 1)
	LDI ZL, LOW(TABLA7SEG << 1)
	ADD ZL, R12
	SBI PORTC, PC0
	LPM R20, Z
	OUT PORTD, R20
	CALL delaybounce3
	CBI PORTC, PC0

	// DIPLAY 3
	LDI ZH, HIGH(TABLA7SEG << 1)
	LDI ZL, LOW(TABLA7SEG << 1)
	ADD ZL, R13
	SBI PORTC, PC2
	LPM R20, Z
	OUT PORTD, R20
	CALL delaybounce3
	CBI PORTC, PC2

	// DIPLAY 4
	LDI ZH, HIGH(TABLA7SEG << 1)
	LDI ZL, LOW(TABLA7SEG << 1)
	ADD ZL, R14
	SBI PORTC, PC3
	LPM R20, Z
	OUT PORTD, R20
	CALL delaybounce3
	CBI PORTC, PC3

	SBRS R19, 3
	RJMP loop
	RJMP CONFIA
//*****************************************************************
//                          CONFIGURACION DE ALARMA
//*****************************************************************
CONFIA:
	SBI PORTB, PB5
	SBRC R7, 0
	RJMP CONFIVERI6
CONFIVERI5:
	LDI R24, 0b000_1010	
	CP R11, R24             //Contador de minutos
	BREQ OVERFLOCONFI5
	LDI R24, 0b1111_1111	
	CP R11, R24   
	BREQ UNDERFLOCONFI5
	RJMP loop

UNDERFLOCONFI5:
	LDI R24, 9
	MOV R11, R24
	DEC R12
	LDI R24, 0xFF
	CP R12, R24
	BRNE CONFIA5
	LDI R24, 9
	MOV R11, R24
	LDI R24, 5
	MOV R12, R24
	RJMP loop
CONFIA5:
	RJMP loop
OVERFLOCONFI5:
	CLR R11
	INC R12
	LDI R24, 0b000_0110                         //Contador de decenas
	CP R24, R12
	BREQ OVERFLOCONFI6
	RJMP loop
OVERFLOCONFI6:
	CLR R12
	RJMP loop

CONFIVERI6:
	LDI R24, 0b1111_1111
	CP R24, R13
	BREQ UNDERFLOCONFI6
	LDI R24, 0b000_0010
	CP R24, R14
	BREQ CONFITOP245                       //Contador de horas
	LDI R24, 0b000_1010
	CP R24, R13
	BREQ OVERFLOCONFI7
	LDI R24, 0b1111_1111
	CP R24, R13
	BREQ UNDERFLOCONFI6
	rjmp loop
UNDERFLOCONFI6:
	LDI R24, 9
	MOV R13, R24
	DEC R14
	LDI R24, 0b1111_1111
	CP R24, R14
	BRNE CONFIFIN5
	LDI R24, 2
	MOV R14, R24
	LDI R24, 3
	MOV R13, R24
	RJMP loop
OVERFLOCONFI7:
	CLR R13
	INC R14                         //Contador de decenas de horas
	rjmp loop
CONFITOP245:
	LDI R24, 0b0000_0100
	CP R13, R24
	BREQ CONFITOP25
	RJMP loop
CONFITOP25:
	CLR R13
	CLR R14
CONFIFIN5:
	RJMP loop
//*****************************************************************
//                      ENCENDER MASCARAS
//*****************************************************************
ENCENDERMASK:
	LDI R16, 0b0000_0001
	STS TIMSK1, R16
	RJMP loop
//*****************************************************************************
// Sub-rutinas
//*****************************************************************************

delaybounce2:
	LDI R16, 255

	delay2:
		DEC R16
		BRNE delay2
	ret

delaybounce3:
	LDI R24, 255
	delay3:
	LDI R16, 100
	delay4:
		DEC R16
		BRNE delay4
		DEC r24
		BRNE delay3
	ret
IdelayT0:
	LDI R16, (1 << CS02) | (1 << CS00)
	OUT TCCR0B, R16

	LDI R16, 100
	OUT TCNT0, R16

	RET
IdelayT1:
	LDI R16, 0b0000_0011
	STS TCCR1B, R16

	LDI R16, HIGH(T1Value)
	STS TCNT1H, R16

	LDI R16, LOW(T1Value)
	STS TCNT1L, R16
	clr R16


	RET
//***********************************************************************************
//PCINT0
//***********************************************************************************
ISR_PCINT0:
	PUSH R16
	IN R16, SREG
	PUSH R16

	INC R26
	SBRS R26, 1
	RJMP FIN
	SBRC R19, 3
	RJMP CONFIINT
Verificar:
	CLR R26
	SBRS R21, 0
	RJMP INCRE
	SBRS R21, 1
	RJMP INCRE2
	SBRS R21, 2
	RJMP INCRE3
	RJMP INCRE4
INCRE:
	LDI R19, 0b0001
	RJMP FIN
INCRE2: 
	LDI R19, 0b0010
	RJMP FIN
INCRE3: 
	LDI R19, 0b0100
	RJMP FIN
INCRE4: 
	SBI PORTB, PB5
	MOV R5, R19
	LDI R19, 0b1000
	OR R19, R5
	RJMP FIN
APAGARCONFI:
	CBR R19, PC3
	RJMP FIN
CONFIINT:
	CLR R26
	SBRS R21, 0
	RJMP CONFI1
	SBRS R21, 1
	RJMP CONFI2
	SBRS R21, 2
	RJMP CONFI3
	SBRS R21, 3
	RJMP CONFI4
	RJMP FIN
//*****************************************************************************************************************************//
CONFI1:
//*************************
//CONFI HORA
//*************************
	SBRS R19, 0
	RJMP CONFIGURARFECHA1
	SBRS R7, 0
	MOV R6, R22
	SBRC R7, 0
	MOV R6, R23
	RJMP CONFI11
//*************************
//CONFI FECHA
//*************************
CONFIGURARFECHA1:
	SBRS R19, 1
	RJMP CONFIGURARALARMA1
	SBRS R7, 0
	MOV R6, R0
	SBRC R7, 0
	MOV R6, R3
	RJMP CONFI11
//*************************
//CONFI ALARMA
//*************************
CONFIGURARALARMA1:
	SBRS R19, 2
	RJMP FIN
	SBRS R7, 0
	INC R11
	SBRC R7, 0
	INC R13
	RJMP CONFI12
CONFI12:
	RJMP FIN
CONFI11:
	INC R6
	RJMP FIN
//*****************************************************************************************************************************//
CONFI2: 
//*************************
//CONFI HORA
//*************************
	SBRS R19, 0
	RJMP CONFIGURARFECHA2
	SBRS R7, 0
	MOV R6, R22
	SBRC R7, 0
	MOV R6, R23
	RJMP CONFI21
//*************************
//CONFI FECHA
//*************************
CONFIGURARFECHA2:
	SBRS R19, 1
	RJMP CONFIGURARALARMA2
	SBRS R7, 0
	MOV R6, R0
	SBRC R7, 0
	MOV R6, R3
	RJMP CONFI21
//*************************
//CONFI ALARMA
//*************************
CONFIGURARALARMA2:
	SBRS R19, 2
	RJMP FIN
	SBRS R7, 0
	DEC R11
	SBRC R7, 0
	DEC R13
	RJMP CONFI22
CONFI22:
	RJMP FIN
CONFI21:
	DEC R6
	RJMP FIN
//*****************************************************************************************************************************//
CONFI3: 
	INC R7
	LDI R24, 2
	CP R24, R7
	BREQ OVERCONFI3
	RJMP FIN
//*****************************************************************************************************************************//
CONFI4:
	CBI PORTB, PB5
	LDI R24, 0b0111
	AND R19, R24
	RJMP FIN
OVERCONFI3:
	CLR R7
	RJMP FIN
FIN:
	IN R21, PINB
	POP R16
	OUT SREG, R16
	POP R16
	RETI
//***********************************************************************************
//TIMER1
//***********************************************************************************
TIM1_OVF:
	PUSH R16
	IN R16, SREG
	PUSH R16

	LDI R16, HIGH(T1Value)
	STS TCNT1H, R16

	LDI R16, LOW(T1Value)
	STS TCNT1L, R16

	CP R14, R25
	BRNE NADA
	CP R13, R23
	BRNE NADA
	CP R12, R18
	BRNE NADA
	CP R11, R22
	BRNE NADA
	LDI R16, 0b0000_0001
	STS TIMSK0, R16
NADA:
	LDI R24, 1
	INC R10
	CP R10, R24
	BRNE SUMA

	SBRS R27, 0
	RJMP ENP
	RJMP APP
ENP:
	CLR r10
	LDI R27, 0b1
	RJMP SUMA
APP:
	CLR r10
	LDI R27, 0b0
	RJMP SUMA
SUMA:
	INC R17 
	CPI R17, 240
	BRNE FIN3
	CLR r17
SUM:
    INC R22						//Contador de minutos
	CPI R22, 0b000_1010
    BREQ OVERFLO
	RJMP FIN2
FIN3:
	POP R16
	OUT SREG, R16
	POP R16
	RETI
OVERFLO:
	CLR R22
	INC R18                         //Contador de decenas
	CPI R18, 0b000_0110
	BREQ OVERFLO2
	RJMP FIN2
OVERFLO2:
	CLR R18
	INC R23  
	CPI R25, 0b000_0010
	BREQ TOP24                       //Contador de horas
	CPI R23, 0b000_1010
	BREQ OVERFLO3
	rjmp FIN2
OVERFLO3:
	CLR R23
	INC R25                         //Contador de decenas de horas
	rjmp FIN2
TOP24:
	CPI R23, 0b0000_0100
	BREQ TOP2
	RJMP FIN2
TOP2:
	CLR R23
	CLR R22
	CLR R18
	CLR R25

//EValua si ya va por dia 3X
	LDI R24, 2
	CP R1, R24
	BRNE COMP
	LDI R24, 2
	CP R2, R24
	BRNE COMP
	LDI R24, 9
	INC R0 
	CP R0, R24
	BREQ NM
	RJMP FIN2
COMP:
	LDI R24, 3
	CP R2, R24
	BREQ TOPDIA
SUMANORM:
	LDI R24, 10
	INC R0 
	CP R0, R24
	BREQ CD

	RJMP FIN2
TOPDIA:
	LDI R24, 1
	CP R1, R24
	BREQ PR1

	LDI R24, 3
	CP R1, R24
	BREQ PR1

	LDI R24, 4
	CP R1, R24
	BREQ PR2

	LDI R24, 5
	CP R1, R24
	BREQ PR1

	LDI R24, 6
	CP R1, R24
	BREQ PR2

	LDI R24, 7
	CP R1, R24
	BREQ PR1

	LDI R24, 8
	CP R1, R24
	BREQ PR1

	LDI R24, 9
	CP R1, R24
	BREQ PR2

	LDI R24, 10
	CP R1, R24
	BREQ PR1

	LDI R24, 11
	CP R1, R24
	BREQ PR2

	LDI R24, 12
	CP R1, R24
	BREQ PR1

	rjmp FIN2
PR1:
	LDI R24, 2
	INC R0 
	CP R0, R24
	BREQ NM
	RJMP FIN2
PR2:
	LDI R24, 1
	INC R0 
	CP R0, R24
	BREQ NM
	RJMP FIN2

CD:
	CLR R0
	INC R2
	RJMP FIN2

NM:
	CLR R0
	INC R0
	CLR R2
	LDI R24, 1
	CP R4, R24
	BREQ TOPMES
	INC R1
	INC R3
	LDI R24, 10
	CP R3, R24
	BREQ TOPNMES
	RJMP FIN2
TOPNMES:
	CLR R3
	INC R4
	RJMP FIN2
TOPMES:
	INC R3
	INC R1
	LDI R24, 3
	CP R3, R24
	BREQ CM
	RJMP FIN2
CM:
	CLR R1
	CLR R3
	CLR R4
	INC R1
	INC R3
FIN2:
	POP R16
	OUT SREG, R16
	POP R16
	RETI

//***********************************************************************************
//TIMER0
//***********************************************************************************
TIM0_OVF:
	PUSH R16
	IN R16, SREG
	PUSH R16

	LDI R16, 100
	OUT TCNT0, R16

	
	INC R15
	LDI R24, 100
	CP R15, R24
	BRNE FIN0
	CLR R15

	SBIS PORTB, PB4
	RJMP ENCENDERBUZZ

	SBIC PORTB, PB4
	RJMP APAGARBUZZ

	ENCENDERBUZZ:
		SBI PORTB, PB4
		INC R8
		LDI R24, 60
		CP R8, R24
		BRNE FIN0
		LDI R16, 0b0000_0000
		STS TIMSK0, R16
		RJMP FIN0
	APAGARBUZZ:
		CBI PORTB, PB4
		INC R8
		LDI R24, 60
		CP R8, R24
		BRNE FIN0
		CLR R8
		LDI R16, 0b0000_0000
		STS TIMSK0, R16
		RJMP FIN0
	FIN0:
	POP R16
	OUT SREG, R16
	POP R16
	RETI