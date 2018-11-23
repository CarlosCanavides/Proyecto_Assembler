%ifndef CALCULADOR_METRICAS
%define CALCULADOR_METRICAS

%include "contador_metricas.asm"

section .bss
	buffer_leido resb 1000000  ; reserva espacio para un buffer de 1000000 bytes.


section .text
	global calcular_metricas
	global mostrar_resultados

; Rutina que se encarga de procesar el archivo de entrada y calcular las metricas.
; Recibe un file_descriptor en el registro EBX.
; Se asume un maximo de 1000 lineas, con 1000 caracteres cada una.
calcular_metricas :
	mov EAX,3                  ; sys_read
	mov ECX,buffer_leido 	   ; buffer donde se almacenara lo leido del archivo.
	mov EDX,1000000 		   ; EDX = cantidad máxima de bytes (caracteres) leidos del archivo.
							   ; Se asume un maximo de 1000 caracteres por linea. 
	int 0x80                   ; genera interrupcion.

	cmp EAX,0                  ; compara la cantidad de bytes que se pudieron leer del archivo con 0.
	je finalizar               ; si la cantidad de bytes leidas es 0, se alcanzo el EOF del archivo.
							   ; por lo cual el archivo esta vacio.

	mov EBX,0x0 			   ; EBX funcionara como un registro de desplazamiento.
							   ; Desplazandose en la memoria reservada para el buffer.

	; Una vez que se ejecuta sys_read, el registro EAX contiene la cantidad de bytes que se pudieron leer del archivo.
	; Esta cantidad de bytes se corresponde con la cantidad de caracteres leidos. Por lo tanto, se procede a analizar
	; dichos caracteres uno por uno. Despalzandose en la memoria reservada para el buffer.
	leer_caracter :
		mov cl, byte[buffer_leido+EBX]   ; ECX = caracter contenido en el buffer.
		dec EAX                    		 ; decremento la cantidad de caracteres que faltan procesar.
		call analizar_caracter     		 ; llamada a la rutina que analiza el caracter leido.
		cmp EAX,0                  		 ; comparo la cantidad de caracteres que faltan procesar con 0.
		je finalizar              		 ; si ya no hay nada mas para procesar, finalizo la lectura de caracteres.
		inc EBX                    		 ; si faltan procesar caracteres, incremento el registro de desplazamiento.
		jmp leer_caracter          		 ; proceso el siguiente caracter.

	finalizar :
		ret   ; retorno


; Rutina que se encarga de mostrar los resultados del calcula de maetricas.
; Recibe un file_descriptor en el registro EBX.
; El fd_salida es almacenado en el registro ESI para preservar su valor.
mostrar_resultados :
	mov ESI,EBX  					; ESI = fd_salida

	call recuperar_cant_letras      ; llamada a la rutina que devuelve la cantidad de letras (en ECX).
	mov EAX, 4					    ; sys_write
	mov EBX,ESI 					; EBX = fd_salida
	int 0x80					 	; genera interrupcion.

	push 0xA						; push salto de linea.

	mov EAX, 4					    ; sys_write
	mov EBX,ESI 					; EBX = fd_salida
	mov ECX,ESP 					; ECX = salto de linea.
	mov EDX,1 						; EDX = 1 byte.
	int 0x80					 	; genera interrupcion.

	call recuperar_cant_palabras	; llamada a la rutina que devuelve la cantidad de palabras (en ECX).
	mov EAX, 4						; sys_write
	mov EBX,ESI 					; EBX = fd_salida.
	int 0x80						; genera interrupcion.

	mov EAX, 4					    ; sys_write
	mov EBX,ESI 					; EBX = fd_salida
	mov ECX,ESP 					; ECX = salto de linea.
	mov EDX,1 						; EDX = 1 byte.
	int 0x80					 	; genera interrupcion.

	call recuperar_cant_lineas		; llamada a la rutina que devuelve la cantidad de lineas (en ECX).
	mov EAX, 4						; sys_write
	mov EBX,ESI 					; EBX = fd_salida
	int 0x80						; genera interrupcion.

	mov EAX, 4					    ; sys_write
	mov EBX,ESI 					; EBX = fd_salida
	mov ECX,ESP 					; ECX = salto de linea.
	mov EDX,1 						; EDX = 1 byte.
	int 0x80					 	; genera interrupcion.

	call recuperar_cant_parrafos	; llamada a la rutina que devuelve la cantidad de parrafos (en ECX).
	mov EAX, 4						; sys_write
	mov EBX,ESI 					; EBX = fd_salida
	int 0x80						; genera interrupcion.

	mov EAX, 4					    ; sys_write
	mov EBX,ESI 					; EBX = fd_salida
	mov ECX,ESP 					; ECX = salto de linea.
	mov EDX,1 						; EDX = 1 byte.
	int 0x80					 	; genera interrupcion.

	pop ESI                         ; pop salto de linea.

	ret

%endif; CALCULADOR_METRICAS