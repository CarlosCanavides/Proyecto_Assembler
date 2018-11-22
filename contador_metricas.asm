%ifndef CONTADOR_METRICAS
%define CONTADOR_METRICAS

section .data
	cant_letras dd 0   ; Inicializo un espacio en 0 para la cantidad de letras
	cant_palabras dd 0 ; Inicializo un espacio en 0 para la cantidad de palabras
	cant_lineas dd 0   ; Inicializo un espacio en 0 para la cantidad de lineas
	cant_parrafos dd 0 ; Inicializo un espacio en 0 para la cantidad de parrafos

section .bss
	representacion_entera resb 10 ; Reservo espacio para colocar los caracteres numericos
								  ; que representaran a las distintas cantidades cuando
								  ; pidan ser recuperadas (Solo una representacion estara
								  ; almacenada a la vez)

section .text
	global _start

_start:
	times 51532 call aumentar_parrafos

	mov EAX, 4
	mov EBX, 1
	call recuperar_cant_parrafos
	int 0x80
	mov EAX, 1
	int 0x80


; Espera ser llamado con call
; Aumenta la cantidad de letras
; Ignora el contenido previo de EAX
aumentar_letras:
	mov EAX, [cant_letras] ; Muevo el valor actual a un registro
	inc EAX				   ; Incremento la cantidad letras
	mov [cant_letras], EAX   ; Vuelvo a colocar el nuevo valor
	ret 				   ; Retorno de la subrutina


; Espera ser llamado con call
; Aumenta la cantidad de palabras
; Ignora el contenido previo de EAX
aumentar_palabras:
	mov EAX, [cant_palabras] ; Muevo el valor actual a un registro
	inc EAX				   	 ; Incremento la cantidad palabras
	mov [cant_palabras], EAX   ; Vuelvo a colocar el nuevo valor
	ret 					 ; Retorno de la subrutina


; Espera ser llamado con call
; Aumenta la cantidad de lineas
; Ignora el contenido previo de EAX
aumentar_lineas:
	mov EAX, [cant_lineas] ; Muevo el valor actual a un registro
	inc EAX				   ; Incremento la cantidad lineas
	mov [cant_lineas], EAX   ; Vuelvo a colocar el nuevo valor
	ret 				   ; Retorno de la subrutina


; Espera ser llamado con call
; Aumenta la cantidad de parrafos
; Ignora el contenido previo de EAX
aumentar_parrafos:
	mov EAX, [cant_parrafos] ; Muevo el valor actual a un registro
	inc EAX				   	 ; Incremento la cantidad parrafos
	mov [cant_parrafos], EAX   ; Vuelvo a colocar el nuevo valor
	ret 					 ; Retorno de la subrutina


; Espera ser llamado con call
; Vuelve a 0 todas las metricas
reestablecer_metricas:
	mov [cant_letras], DWORD 0x0	; Vuelvo a 0 la cantidad de letras
	mov [cant_palabras], DWORD 0x0	; Vuelvo a 0 la cantidad de palabras
	mov [cant_lineas], DWORD 0x0	; Vuelvo a 0 la cantidad de lineas
	mov [cant_parrafos], DWORD 0x0	; Vuelvo a 0 la cantidad de parrafos
	ret 							; Retorno de la subrutina


; Espera ser llamado con call
; Retorna en ECX la direccion a la cantidad de letras (ASCII),
; y en EDX la cantidad de digitos 
; No modifica el contenido previo de los registros no mencionados
recuperar_cant_letras:
	push EAX				; Preservo el contenido de EAX
	mov EAX, [cant_letras] 	; Almaceno en EAX la cantidad de letras en binario
	call convertir_decimal	; Convierto el valor de EAX a caracteres decimales
	mov ECX, representacion_entera	; Dejo en ECX la direccion a donde se encuentran los digitos
	pop EAX					; Restauro el contenido de EAX
	ret 					; Retorno de la subrutina


; Espera ser llamado con call
; Retorna en ECX la direccion a la cantidad de palabras (ASCII),
; y en EDX la cantidad de digitos 
; No modifica el contenido previo de los registros no mencionados
recuperar_cant_palabras:
	push EAX					; Preservo el contenido de EAX
	mov EAX, [cant_palabras] 	; Almaceno en EAX la cantidad de palabras en binario
	call convertir_decimal		; Convierto el valor de EAX a caracteres decimales
	mov ECX, representacion_entera	; Dejo en ECX la direccion a donde se encuentran los digitos
	pop EAX						; Restauro el contenido de EAX
	ret 						; Retorno de la subrutina


; Espera ser llamado con call
; Retorna en ECX la direccion a la cantidad de lineas (ASCII),
; y en EDX la cantidad de digitos 
; No modifica el contenido previo de los registros no mencionados
recuperar_cant_lineas:
	push EAX				; Preservo el contenido de EAX
	mov EAX, [cant_lineas] 	; Almaceno en EAX la cantidad de lineas en binario
	call convertir_decimal	; Convierto el valor de EAX a caracteres decimales
	mov ECX, representacion_entera	; Dejo en ECX la direccion a donde se encuentran los digitos
	pop EAX					; Restauro el contenido de EAX
	ret 					; Retorno de la subrutina


; Espera ser llamado con call
; Retorna en ECX la direccion a la cantidad de parrafos (ASCII),
; y en EDX la cantidad de digitos 
; No modifica el contenido previo de los registros no mencionados
recuperar_cant_parrafos:
	push EAX					; Preservo el contenido de EAX
	mov EAX, [cant_parrafos] 	; Almaceno en EAX la cantidad de parrafos en binario
	call convertir_decimal		; Convierto el valor de EAX a caracteres decimales
	mov ECX, representacion_entera	; Dejo en ECX la direccion a donde se encuentran los digitos
	pop EAX						; Restauro el contenido de EAX
	ret 						; Retorno de la subrutina



; Espera ser llamado con call
; Espera el entero (unsigned) binario en el registro EAX
; Almacena en la direccion representacion_entera el arreglo de caracteres
; Retorna en EDX la cantidad de digitos resultantes
; No altera ningun contenido previo de los registros no mencionados
convertir_decimal:
	push EBX	; Preservo el contenido de EBX
	push ECX	; Preservo el cotenido de ECX

	mov ECX, 0x0	; | ECX contara la cantidad de digitos
	mov EBX, 0xA	; | EBX sera el divisor (10)
					; | EAX sera el dividendo
					; | El cociente se almacena en EAX, el resto en EDX
	loop_division:
		mov EDX, 0x0		; Limpio el contenido de EDX
		div EBX				; Divido EDX:EAX / EBX
		push EDX			; Apilo el resto de la division
		inc ECX				; Incremento en 1 la cantidad de digitos
		cmp EAX, 0			; Verifico si el cociente es 0
		jne loop_division	; Si el cociente no es 0 continuo dividiendo

	mov EBX, 0x0	; | Utilizo EBX para contar las desapiladas de restos,
					; | cuando EBX = ECX, consegui todos los digitos
	loop_conversion
		pop EDX			; Desapilo un resto, sera un numero binario entre 0-9
		add EDX, "0"	; Sumo el valor de EDX para conseguir su representacion ASCII
		mov [representacion_entera + EBX], EDX	; Muevo a memoria el digito obtenido convertido a ASCII
		inc EBX				; Aumento la cantidad de digitos desapilados
		cmp ECX, EBX		; Verifico si desapile todos los restos
		jne loop_conversion	; Si no desapile todos los restos, continuo convirtiendo digitos

	mov EDX, ECX	; Dejo la cantidad de digitos en el registro EDX
	pop ECX			; Restauro el contenido de ECX
	pop EBX			; Restauro el contenido de EBX
	ret 			; Retorno de la subrutina



%endif;CONTADOR_METRICAS