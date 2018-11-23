%ifndef METRICAS
%define METRICAS

%define terminacion_normal 0                  ; terminacion normal
%define terminacion_anormal_archEntrada 1     ; terminacion anormal por error en el archivo de entrada
%define terminacion_anormal_archSalida  2     ; terminacion anormal por error en el archivo de salida
%define terminacion_anormal 3				  ; terminacion anormal por otras causas

%include "automata_lexico.asm"
%include "calculador_metricas.asm"
%include "about.asm"

section .data
	fd_entrada dd 0                ; reserva memoria para mantener el descriptor del archivo de entrada.
	fd_salida  dd 1                ; reserva memoria para mantener el descriptor del archivo de salida de los resultados. Por defecto es por consola.
	file_temp  dd "temporal.txt"   ; nombre del archivo temporal, sera utilizado cuando la cantidad de parametros sea 0.

section .bss
	buffer   resb 100              ; reserva espacio para un buffer de 100 bytes.
	caracter resb 1                ; reserva espacio para un caracter leido de un archivo.

section .text
global _start

_start :
	pop EAX              ; EAX contiene ARGC.
	pop EBX              ; descartamos ARGV[0], nombre del programa.

	cmp EAX,1            ; ¿La cantidad de parametros es igual a 0?
	je cero_parametros   ; EAX = 0  ---> Rutina para 0 armumento.

	pop EBX              ; conservamos ARGV[1]

	cmp EAX,2            ; ¿La cantidad de parametros es igual a 1?
	je un_parametro      ; EAX = 1  ---> Rutina para 1 armumento.

	cmp EAX,3            ; ¿La cantidad de parametros es igual a 2?
	je dos_parametros    ; EAX = 2  ---> Rutina para 2 armumento.

	push terminacion_anormal  ; Si la cantidad de parametros no es la esperada, se produce una terminacion anormal.
	jmp _exit                 ; se ejecuta rutina de finalizacion.


cero_parametros :
	mov  EAX, 8                 ; sys_creat
   	mov  EBX, file_temp         ; EBX = nombre del archivo temporal.
   	mov  ECX, 0777              ; permiso RWE para todos los usuarios.
   	int  0x80                   ; genera interrrupcion.

   	mov [fd_entrada],EAX        ; fd_entrada = EAX;

   	cmp EAX,0					; se verifica que el procesi "sys_creat" haya sido exitoso.
   	jge leer_buffer				; si se pudo crear un nuevo archivo temporal, se procede a leer por consola.
   	push terminacion_anormal    ; se parametriza la condicion de terminacion.
   	jmp _exit                   ; se ejecuta la rutina de finalizacion.

   	leer_buffer :
		mov EAX, 3		            ; sys_read
		mov EBX, 0                  ; indica ingreso por consola STDIN.
		mov ECX, buffer             ; lo ingresado por usuario se almacenara en buffer.
		mov EDX, 1000               ; EDX = longitud de lo que se leera por consola. 
							        ; Se asume un maximo de 1000 caracteres por linea.
		int 0x80                    ; genera interrupcion.

		cmp EAX,0                   ; Detecta la secuencia de escape para el fin del ingreso por teclado (Ctrl+D).
		je  continuar				; si se termino el ingreso por teclado se procede a calcular las metricas del archivo temporal.

		mov EDX, EAX				; EDX = longitud en bytes de lo que se leyo por consola.
		mov EAX, 4                  ; sys_write
		mov EBX, [fd_entrada]	    ; indica que se escriba por fd_entrada
		mov ECX, buffer             ; texto a escribir.
		int 0x80                    ; genera interrupcion.

		jmp leer_buffer              ; se vuelve a leer por consola.

	continuar :
		mov EAX,6                ; sys_close
    	mov EBX,[fd_entrada]     ; indica puntero a archivo de entrada.
    	int 0x80                 ; genera interrrupcion.

		mov EBX,file_temp		 ; EBX = nombre del archivo temporal.
		call abrir_archivo       ; llamada a la rutina que abre el archivo mencionado en EBX.
								 ; finalizada la rutina, el file_descriptor del archivo se localiza en EAX.
		mov [fd_entrada],EAX     ; fd_entrada = EAX.
		cmp EAX,0				 ; se verifica que el proceso "sys_open" haya sido exitoso.
		jge procesar			 ; si se pudo abrir el archivo de temporal, continua la ejecucion.

		push terminacion_anormal ; se parametriza la condicion de terminacion.
		jmp _exit                ; se ejecuta la rutina de finalizacion.


un_parametro  :
	call verificar_ayuda					; se verifica si el usuario solicito ayuda.
	call abrir_archivo                      ; llamada a la rutina que trata de abrir el archivo de entrada.
	mov [fd_entrada],EAX                    ; fd_entrada = EAX
	cmp EAX,0								; se verifica que el proceso "sys_open" haya sido exitoso.
	jge procesar							; si se pudo abrir el archivo de entrada continua la ejecucion.

	push terminacion_anormal_archEntrada    ; se parametriza la condicion de terminacion.
	jmp _exit                               ; se ejecuta la rutina de finalizacion.


dos_parametros :
	call abrir_archivo                      ; llamada a la rutina que trata de abrir el archivo de entrada.
	mov [fd_entrada],EAX         			; fd_entrada = EAX
	cmp EAX,0								; se verifica que el proceso "sys_open" haya sido exitoso.
	jge abrir_archSalida					; si se pudo abrir el archivo de entrada se procede a abrir el archivo de salida.

	push terminacion_anormal_archEntrada	; se parametriza la condion de terminacion.
	jmp _exit								; se ejecuta la rutina de finalizacion.

	abrir_archSalida :
		pop EBX								; se desapila es segundo parametro ARGV[2], que corresponde con el archivo de salida.
		call abrir_archivo_escritura		; llamada a la rutina que trata de abrir el archivo de salida.
		mov [fd_salida],EAX					; fd_salida = EAX
		cmp EAX,0							; se verifica que el proceso "sys_open" haya sido exitoso.
		jge procesar						; si se pudo abrir el archivo de salida, continua la ejecucion.

		push terminacion_anormal_archSalida ; se parametriza la condicion de terminacion.
		jmp _exit							; se ejecuta la rutina de finalizacion.


; Una vez que el control de los parametros fue realizado, esta rutina se encarga del procesamiento posterior.
; Asume que todo los archivos correspondientes pudieron abrirse exitosamente.
procesar :
	mov EBX,[fd_entrada]	   ; EBX = fd_entrada, ya que la rutina calcular_metricas espera dicho parametro.
	call calcular_metricas     ; llamada a la rutina que calcula las metricas sobre el archivo de entrada.
	mov EBX,[fd_salida]		   ; EBX = fd_salida, ya que la rutina mostrar_resultados espera dicho parametro.
	call mostrar_resultados    ; llamada a la rutina que se encarga de mostrar los resultados.
	call cerrar_archivos       ; llamada a la rutina que se encarga de cerrar los archivos usados.
	push terminacion_normal    ; parametriza la condicion de terminacion.
	jmp _exit   			   ; se ejecuta la rutina de finalizacion.


; Rutina que se encarga de abrir un archivo para lectura, cuyo file_name ya se encuentra en el registro EBX.
abrir_archivo  :
    mov EAX,5                  ; sys_open
    mov ECX,0                  ; modo lectura, para el archivo.  
	mov EDX,0777               ; permiso RWE para todos los usuarios.
	int 0x80                   ; genera interrupcion.
	ret                    	   ; retorno


; Rutina que se encarga de abrir un archivo para escritura, cuyo file_name ya se encuentra en el registro EBX.
abrir_archivo_escritura :
	mov EAX,5                  ; sys_open
    mov ECX,1                  ; modo escritura, para el archivo.  
	mov EDX,0777               ; permiso RWE para todos los usuarios.
	int 0x80                   ; genera interrupcion.
	ret                    	   ; retorno


; Rutina que se encarga de cerrar los archivos de entrada y salida.
; Si el archivo de salida es "salida estandar" no necesita cerrarlo.
cerrar_archivos :
	mov EAX,6                  ; sys_close
    mov EBX,[fd_entrada]       ; indica puntero a archivo de entrada.
    int 0x80                   ; genera interrrupcion.

    mov EAX, [fd_salida]       ; EAX = fd_salida.
    cmp EAX,1                  ; chequea si la salida fue por STDOUT (salida estandar).
    je fin                     ; si fd_salida = STDOUT finaliza la rutina.

    mov EAX,6                  ; sys_close
    mov EBX,[fd_salida]        ; indica puntero a archivo de salida.
    int 0x80                   ; genera interrrupcion.

    fin :
    	ret 				   ; retorno


; Rutina que verifica si el parametro ingresado se corresponde con la secuencia de ayuda "-h"
; Esta rutina esperra ser llamada con call, y requiere modificar el registro ECX sin preocupacion.
; Para llamar a esta rutina, se requiere un puntero a la direccion del parametro, en el registro EAX.
; No se modificara el registro EAX, ya que contiene dicho puntero.
verificar_ayuda :
	mov ECX,0 				   ; set ECX = 0
	mov CL, BYTE[EBX] 		   ; Low(ECX) = codigo ASCII del primer caracter del parametro.
	cmp CL, "-"				   ; comparo el 1er caracter con "-".
	jne posible_archivo 	   ; si el 1er caracter no es igual a "-", entonces el parametro
							   ; probablemente es el nombre de un archivo.

	mov CL, BYTE[EBX+1] 	   ; Low(ECX) = codigo ASCII del segundo caracter del parametro.
	cmp CL, "h" 			   ; comparo el 2do caracter con "h".
	jne posible_archivo        ; si el 2do caracter no es igual a "h", entonces el parametro
							   ; probablemente es el nombre de un archivo.

	mov CL, BYTE[EBX+2]		   ; Low(ECX) = codigo ASCII del tercer caracter del parametro.
	cmp CL, "" 				   ; comparo el 1er caracter con "" (vacio).
	je mostrar_ayuda 		   ; si el 3er caracter es igual a "", entonces la secuencia ingresada
							   ; corresponde con "-h", por lo cual el usuario solicita ayuda.
	posible_archivo :
		ret         ; retorno

	mostrar_ayuda :
		call mostrar_about        ; muestra la ayuda
		push terminacion_normal   ; parametriza la condicion de terminacion.
		jmp _exit 				  ; se ejecuta la rutina de finalizacion.


; Rutina de finalizacion
_exit :
    mov EAX,1   ; sys_exit
	pop EBX     ; condicion de terminacion.
	int 0x80    ; genera interrupcion.


%endif;METRICAS