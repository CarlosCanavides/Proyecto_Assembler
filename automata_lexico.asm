%define true 1
%define false 0

%include "contador_metricas.asm"
%include "analizador_lexico.asm"


section .data
	estado_actual dd estado_nueva_linea ; Inicializo el espacio del estado actual
										; con el estado de una nueva linea

section .text
	global _start ; Dev only
	global analizar_caracter ; Rutina inicial del automata

_start: ; Dev only

; Espera el ultimo caracter leido en el registro ECX
analizar_caracter:
	push EAX 			 ; Preseva el contenido de EAX, sera usado para analizar el caracter
	call [estado_actual] ; Salto a la primera instruccion de la rutina del estado actual 

	mov EAX, 1 ; Dev only
	int 0x80   ; Dev only


; Espera el ultimo caracter en el registro ECX
; Representa estar en el inicio de una nueva linea
estado_nueva_linea:
	call verificar_letra ; Verifico si el caracter es una letra (Rutina externa)
	cmp EAX, 1			 ; Si es una letra, EAX = 1
	je linea_letra		 ; Si era una letra, tengo combinacion nueva_linea/letra
	
	cmp ECX, 0xA		 ; Comparo el caracter con un caracter de nueva linea
	je linea_linea		 ; Si era un igual, tengo combinacion nueva_linea/nueva_linea

	ret 				 ; Si era un separador o un caracter basura, no hago nada
	linea_letra:
		call aumentar_letras 				; Aumento la cantidad de letras (Rutina externa)
		mov [estado_actual], estado_letra	; Modifico el estado actual por el de letra
		ret 								; Finalizo la subrutina de estado
	linea_linea:
		call aumentar_lineas 				; Aumento la cantidad de lineas (Rutina externa)
		ret 								; Finalizo la subrutina de estado

; Espera el ultimo caracter en el registro ECX
; Representa haber leido una letra previamente
estado_letra 
	call verificar_separador ; Verifico si el caracter es un separador (Rutina externa)
	cmp EAX, 1				 ; Si es un separador, EAX = 1
	je letra_separador		 ; Si es igual, tengo combinacion letra/separador
	call verificar_letra	 ; Verifico (Rutina externa)

