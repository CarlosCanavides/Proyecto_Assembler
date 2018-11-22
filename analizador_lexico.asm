%ifndef ANALIZADOR_LEXICO
%define ANALIZADOR_LEXICO

section .text
	global verificar_letra
	global verificar_separador

; Espera el caracter en el registro CL (8 LSB de ECX)
; Si es letra almacena un 1 (true) en EAX, 0 en caso contrario
; Ignora si habia algun contenido previo en EAX
verificar_letra:
	cmp CL, "A" 	   ; Sera menor a 'A' (ASCII) ?
	jl no_es_mayuscula ; Si es menor, no es una letra mayuscula 

	cmp CL, "Z" 	   ; Sera mayor a 'Z' (ASCII) ?
	jg no_es_mayuscula ; Si es mayor, no es una letra mayuscula

	mov EAX, true ; Esta entre 'A' y 'Z', es una letra
	ret 		  ; Retorno de la subrutina
	no_es_mayuscula:
		cmp CL, "a"   ; Sera menor que 'a' (ASCII) ?
		jl no_es_letra ; Si es menor entonces no es una letra
		
		cmp CL, "z"   ; Sera mayor que 'z' (ASCII) ?
		jg no_es_letra ; Si es mayor entonces no es una letra

		mov EAX, true ; Esta entre 'a' y 'z', es una letra
		ret 		  ; Retorno de la subrutina
	no_es_letra: 
		mov EAX, false ; No es una letra
		ret 		   ; Retorno de la subrutina


; Espera el caracter en el registro CL (8 LSB de ECX)
; Si es un separador almacena un 1 (true) en EAX, 0 en caso contrario
; Ignora si habia algun cotenido previo en EAX
verificar_separador:
	cmp CL, 0x9 	; Comparacion con caracter tabulador
	je es_separador ; Si es igual, es un separador
	cmp CL, 0x20	; Comparacion con caracter espacio
	je es_separador	; Si es igual, es un separador
	cmp CL, 0xA	; Comparacion con caracter de nueva linea
	je es_separador	; Si es igual, es un separador
	cmp CL, 0x2E	; Comparacion con caracter '.'
	je es_separador	; Si es igual, es un separador
	cmp CL, 0x2C	; Comparacion con caracter ','
	je es_separador	; Si es igual, es un separador
	cmp CL, 0x3B	; Comparacion con caracter ';'
	je es_separador	; Si es igual, es un separador
	cmp CL, 0x21	; Comparacion con caracter '!'
	je es_separador	; Si es igual, es un separador
	cmp CL, 0x3F	; Comparacion con caracter '?'
	je es_separador	; Si es igual, es un separador

	mov EAX, false	; No era igual a ninguno, no es un separador
	ret 			; Retorno de la subrutina
	es_separador:
		mov EAX, true ; Si era un separador
		ret 		  ; Retorno de la subrutina

%endif;ANALIZADOR_LEXICO