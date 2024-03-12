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
.CSEG //Inicio del código
.ORG 0x00 
	JMP MAIN			//Vector reset
.org 0x08				//Vector interrupçion puerto b
	JMP ISR_PCINT0
.ORG 0x001A
	JMP TIM1_OVF
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

	LDI R16, 0b0001_0000
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

	INC R0 //DIA 0
	//R2 DIA 1
	
	INC R1 //Contador de mes
	INC R3 //MES 0
	// R4 MES 0
//*******************************************************
// LOOP
//*******************************************************
loop:
	SBRS R19, 0
	RJMP ESTADOFECHA
ESTADORELOJ: 
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
	SBRS r27, 0
	SBI PORTD, PD7
	CBI PORTD, PD7
	LPM R20, Z
	OUT PORTD, R20
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
	RJMP loop
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
	SBRS r27, 0
	SBI PORTD, PD7
	CBI PORTD, PD7
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

	RJMP loop
ESTADOALARMA:
	SBRS R19, 2
	RJMP loop
	CBI PORTC, PC4
	SBI PORTC, PC5

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
	LDI R19, 0b1000
	RJMP FIN
FIN:
	IN R21, PINB
	POP R16
	OUT SREG, R16
	POP R16
	RETI
//***********************************************************************************
//TIMER0
//***********************************************************************************
TIM1_OVF:
	PUSH R16
	IN R16, SREG
	PUSH R16

	LDI R16, HIGH(T1Value)
	STS TCNT1H, R16

	LDI R16, LOW(T1Value)
	STS TCNT1L, R16
	SBRS R27, 0
	RJMP ENP
	RJMP APP
ENP:
	LDI R27, 0b1
	RJMP SUMA
APP:
	LDI R27, 0b0
	RJMP SUMA
SUMA:
	/*INC R17 
	CPI R17, 240
	BRNE FIN3
	CLR r17*/
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

	LDI R24, 2
	CP R1, R24
	BREQ FEBRERO
FEBRERO: 
	LDI R24, 2
	CP R2, R24
	BREQ PR3
	RJMP SUMANORM
//EValua si ya va por dia 3X
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
	BREQ PR2

	LDI R24, 9
	CP R1, R24
	BREQ PR1

	LDI R24, 10
	CP R1, R24
	BREQ PR2

	LDI R24, 11
	CP R1, R24
	BREQ PR1

	LDI R24, 12
	CP R1, R24
	BREQ PR2
PR1:
	LDI R24, 1
	INC R0 
	CP R0, R24
	BREQ NM
	RJMP FIN2
PR2:
	LDI R24, 2
	INC R0 
	CP R0, R24
	BREQ NM
	RJMP FIN2
PR3:
	LDI R24, 9
	INC R0 
	CP R0, R24
	BREQ NM
	RJMP FIN2
CD:
	CLR R0
	INC R0
	INC R2
	RJMP FIN2
NM1:
	CLR R0
	INC R0
	CLR R2
	CLR R1
	INC R1
	CLR R3
	INC R3
	CLR R4
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
TOPNMES:
	CLR R3
	INC R4
	RJMP FIN2
TOPMES:
	INC R3
	INC R1
	LDI R24, 2
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