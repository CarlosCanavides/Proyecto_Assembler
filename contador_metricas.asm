%ifndef CONTADOR_METRICAS
%define CONTADOR_METRICAS

section .data
	cant_letras dw 0   ; Inicializo un espacio en 0 para la cantidad de letras
	cant_palabras dw 0 ; Inicializo un espacio en 0 para la cantidad de palabras
	cant_lineas dw 0   ; Inicializo un espacio en 0 para la cantidad de lineas
	cant_parrafos dw 0 ; Inicializo un espacio en 0 para la cantidad de parrafos


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

%endif;CONTADOR_METRICAS

