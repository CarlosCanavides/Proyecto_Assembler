%define true 1
%define false 0

%include "contador_metricas.asm"


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
	call verificar_letra ; Verifico si el caracter es una letra
	cmp EAX, 1			 ; Si es una letra, EAX = 1
	je linea_letra		 ; Si era una letra, tengo combinacion nueva_linea/letra
	
	cmp ECX, 0xA		 ; Comparo el caracter con un caracter de nueva linea
	je linea_linea		 ; Si era un igual, tengo combinacion nueva_linea/nueva_linea

	ret 				 ; Si era un separador o un caracter basura, no hago nada
	linea_letra:
		call aumentar_letras 				; Aumento la cantidad de letras
		mov [estado_actual], estado_letra	; Modifico el estado actual por el de letra
		ret 								; Finalizo la subrutina de estado
	linea_linea:
		call aumentar_lineas 				; Aumento la cantidad de lineas
		ret 								; Finalizo la subrutina de estado

; Espera el ultimo caracter en el registro ECX
; Representa haber leido una letra previamente
estado_letra 
	call verificar_separador ; Verifico si el caracter es un separador
	cmp EAX, 1				 ; Si es un separador, EAX = 1
	je letra_separador		 ; Si es igual, tengo combinacion letra/separador
	call verificar_letra	 ; Verifico 

; Espera el caracter en el registro ECX
; Si es letra almacena un 1 (true) en EAX, 0 en caso contrario
; Ignora si habia algun contenido previo en EAX
verificar_letra:
	cmp ECX, "A" 	   ; Sera menor a 'A' (ASCII) ?
	jl no_es_mayuscula ; Si es menor, no es una letra mayuscula 

	cmp ECX, "Z" 	   ; Sera mayor a 'Z' (ASCII) ?
	jg no_es_mayuscula ; Si es mayor, no es una letra mayuscula

	mov EAX, true ; Esta entre 'A' y 'Z', es una letra
	ret 		  ; Retorno de la subrutina
	no_es_mayuscula:
		cmp ECX, "a"   ; Sera menor que 'a' (ASCII) ?
		jl no_es_letra ; Si es menor entonces no es una letra
		
		cmp ECX, "z"   ; Sera mayor que 'z' (ASCII) ?
		jg no_es_letra ; Si es mayor entonces no es una letra

		mov EAX, true ; Esta entre 'a' y 'z', es una letra
		ret 		  ; Retorno de la subrutina
	no_es_letra: 
		mov EAX, false ; No es una letra
		ret 		   ; Retorno de la subrutina


; Espera el caracter en el registro ECX
; Si es un separador almacena un 1 (true) en EAX, 0 en caso contrario
; Ignora si habia algun cotenido previo en EAX
verificar_separador:
	cmp ECX, 0x9 	; Comparacion con caracter tabulador
	je es_separador ; Si es igual, es un separador
	cmp ECX, 0x20	; Comparacion con caracter espacio
	je es_separador	; Si es igual, es un separador
	cmp ECX, 0xA	; Comparacion con caracter de nueva linea
	je es_separador	; Si es igual, es un separador
	cmp ECX, 0x2E	; Comparacion con caracter '.'
	je es_separador	; Si es igual, es un separador
	cmp ECX, 0x2C	; Comparacion con caracter ','
	je es_separador	; Si es igual, es un separador
	cmp ECX, 0x3B	; Comparacion con caracter ';'
	je es_separador	; Si es igual, es un separador
	cmp ECX, 0x21	; Comparacion con caracter '!'
	je es_separador	; Si es igual, es un separador
	cmp ECX, 0x3F	; Comparacion con caracter '?'
	je es_separador	; Si es igual, es un separador

	mov EAX, false	; No era igual a ninguno, no es un separador
	ret 			; Retorno de la subrutina
	es_separador:
		mov EAX, true ; Si era un separador
		ret 		  ; Retorno de la subrutina