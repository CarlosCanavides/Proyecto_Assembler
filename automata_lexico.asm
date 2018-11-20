%define true 1
%define false 0

%include "contador_metricas.asm"
%include "analizador_lexico.asm"


section .data
	estado_actual dd estado_nueva_linea ; Inicializo el espacio del estado actual
										; con el estado de una nueva linea
										

; Espera el ultimo caracter leido en el registro CL (8 LSB de ECX)
analizar_caracter:
	push EAX 			 ; Preseva el contenido de EAX, sera usado para analizar el caracter
	call [estado_actual] ; Salto a la primera instruccion de la rutina del estado actual 
	pop EAX 			 ; Recupero el contenido de EAX
	ret 				 ; Retorno de la subrutina




; Espera el ultimo caracter en el registro CL (8 LSB de ECX)
; Representa estar en el inicio de una nueva linea
estado_nueva_linea:
	call verificar_letra ; Verifico si el caracter es una letra (Rutina externa)
	cmp EAX, 1			 ; Si es una letra, EAX = 1
	je linea_letra		 ; Si era una letra, tengo combinacion nueva_linea/letra
	
	cmp CL, 0xA		 ; Comparo el caracter con un caracter de nueva linea
	je linea_linea		 ; Si era un igual, tengo combinacion nueva_linea/nueva_linea

	ret 				 ; Si era un separador o un caracter basura, no hago nada
	linea_letra:
		call aumentar_letras 					; Aumento la cantidad de letras (Rutina externa)
		mov [estado_actual], DWORD estado_letra	; Modifico el estado actual por el de letra
		ret 									; Finalizo la subrutina de estado
	linea_linea:
		call aumentar_lineas 				; Aumento la cantidad de lineas (Rutina externa)
		ret 								; Finalizo la subrutina de estado




; Espera el ultimo caracter en el registro CL (8 LSB de ECX)
; Representa haber leido una letra previamente
estado_letra: 
	call verificar_separador ; Verifico si el caracter es un separador (Rutina externa)
	cmp EAX, 1				 ; Si es un separador, EAX = 1
	je letra_separador		 ; Si es igual, tengo combinacion letra/separador

	call verificar_letra	 ; Verifico si el caracter es una letra (Rutina externa)
	cmp EAX, 1				 ; Si es una letra, EAX = 1
	je letra_letra			 ; Si es igual, tengo combinacion letra/letra

	mov [estado_actual], DWORD estado_nueva_linea 	; Es un caracter basura, volvemos al estado "inicial"
	ret 											; Retorno de la subrutina

	letra_separador:
		cmp CL, 0xA	; Comparo el caracter con uno de nueva linea
		je letra_linea	; Si es igual tengo combinacion letra/linea

		call aumentar_palabras                  	; No es nueva linea, aumento la cantidad de palabras (Rutina externa)
		mov [estado_actual], DWORD estado_separador	; Cambio el estado actual por el de separador
		ret 										; Retorno de la subrutina

		letra_linea:
			call aumentar_palabras 	; Aumento la cantidad de palabras (Rutina externa)
			call aumentar_lineas	; Aumento la cantidad de lineas (Rutina externa)
			call aumentar_parrafos 	; Aumento la cantidad de parrafos (Rutina externa)
			mov [estado_actual], DWORD estado_nueva_linea ; Cambio el estado actual por el de nueva linea
			ret 										  ; Retorno de la subrutina 
	
	letra_letra:
		call aumentar_letras	; Aumento la cantidad de letras (Rutina externa)
		ret 					; Retorno de la subrutina




; Espera el ultimo caracter en el registro CL (8 LSB de ECX)
; Representa haber leido un separador previamente
estado_separador:
	call verificar_letra ; Verifico si el caracter es una letra (Rutina externa)
	cmp EAX, 1			 ; Si es una letra, EAX = 1
	je separador_letra	 ; Si era una letra, tengo combinacion separador/letra
	
	cmp CL, 0xA		 ; Comparo el caracter con un caracter de nueva linea
	je separador_linea	 ; Si era un igual, tengo combinacion separador/nueva_linea

	ret 				 ; Si era un separador o un caracter basura, no hago nada

	separador_letra:
		call aumentar_letras 	; Aumento la cantidad de letras (Rutina externa)
		mov [estado_actual], DWORD estado_letra_parrafo ; | Cambio al estado de letra, pero como ya lei una
												  		; | palabra valida, es el estado letra_parrafo
		ret 									  		; Retorno de la subrutina
	separador_linea:
		call aumentar_parrafos	; Aumento la cantidad de parrafos (Rutina externa)
		call aumentar_lineas	; Aumento la cantidad de lineas (Rutina externa)
		mov [estado_actual], DWORD estado_nueva_linea	; Vuelvo al estado "inicial" de nueva linea
		ret 					; Retorno de la subrutina




; Espera el ultimo caracter en el registro CL (8 LSB de ECX)
; Representa haber leido una letra previamente, pero con 
; la condicion de ya haber armado una palabra valida en la linea actual
estado_letra_parrafo:
	call verificar_separador ; Verifico si el caracter es un separador (Rutina externa)
	cmp EAX, 1				 ; Si es un separador, EAX = 1
	je letra_separador		 ; Si es igual, tengo combinacion letra/separador

	call verificar_letra	 ; Verifico si el caracter es una letra (Rutina externa)
	cmp EAX, 1				 ; Si es una letra, EAX = 1
	je letra_letra			 ; Si es igual, tengo combinacion letra/letra

	mov [estado_actual], DWORD estado_separador ; | Es un caracter basura, volvemos al estado de separador
										  		; | (esta es la unica variacion respecto al estado_letra comun)
	ret 								  		; Retorno de la subrutina

