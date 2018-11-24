%ifndef METRICAS
%define METRICAS

%define terminacion_normal 0                  ; Terminacion normal
%define terminacion_anormal_archEntrada 1     ; Terminacion anormal por error en el archivo de entrada
%define terminacion_anormal_archSalida  2     ; Terminacion anormal por error en el archivo de salida
%define terminacion_anormal 3				  ; Terminacion anormal por otras causas

%include "procesador.asm"
%include "about.asm"

section .data
	fd_entrada dd 0                		; Reserva memoria para mantener el descriptor del archivo de entrada.
	fd_salida  dd 1                		; Reserva memoria para mantener el descriptor del archivo de salida de los resultados. Por defecto es por consola.
	file_temp  dd "archTemporal.txt",0  ; Nombre del archivo temporal, sera utilizado cuando la cantidad de parametros sea 0.
	
	msj_error0 db "Terminacion normal",0xA							; | Mensaje para mostrar cuando la ejecucion fue exitosa.
	msj_error0_len EQU $-msj_error0 								; |

	msj_error1 db "Terminacion anormal : archivo de entrada",0xA	; | Mensaje para mostrar cuando la ejecucion no fue exitosa.
	msj_error1_len EQU $-msj_error1									; |

	msj_error2 db "Terminacion anormal : archivo de salida",0xA		; | Mensaje para mostrar cuando la ejecucion no fue exitosa.
	msj_error2_len EQU $-msj_error2 								; |

	msj_error3 db "Terminacion anormal",0xA							; | Mensaje para mostrar cuando la ejecucion no fue exitosa.
	msj_error3_len EQU $-msj_error3 								; |

section .bss
	buffer   resb 1000             ; Reserva espacio para un buffer de 100 bytes.

section .text
	global _start

_start :
	pop EAX              ; EAX contiene ARGC.
	pop EBX              ; Descartamos ARGV[0], nombre del programa.

	cmp EAX,1            ; ¿La cantidad de parametros es igual a 0?
	je cero_parametros   ; EAX = 0  ---> Rutina para 0 armumento.

	pop EBX              ; Conservamos ARGV[1]

	cmp EAX,2            ; ¿La cantidad de parametros es igual a 1?
	je un_parametro      ; EAX = 1  ---> Rutina para 1 armumento.

	cmp EAX,3            ; ¿La cantidad de parametros es igual a 2?
	je dos_parametros    ; EAX = 2  ---> Rutina para 2 armumento.

	push terminacion_anormal  ; Si la cantidad de parametros no es la esperada, se produce una terminacion anormal.
	jmp _exit                 ; Se ejecuta rutina de finalizacion.


cero_parametros :
	mov  EAX, 8                 ; sys_creat
   	mov  EBX, file_temp         ; EBX = nombre del archivo temporal.
   	mov  ECX, 0777o             ; Permiso RWE para todos los usuarios.
   	int  0x80                   ; Genera interrrupcion.

   	mov [fd_entrada],EAX        ; fd_entrada = EAX;

   	cmp EAX,0					; Se verifica que el procesi "sys_creat" haya sido exitoso.
   	jge leer_buffer				; Si se pudo crear un nuevo archivo temporal, se procede a leer por consola.
   	push terminacion_anormal    ; Se parametriza la condicion de terminacion.
   	jmp _exit                   ; Se ejecuta la rutina de finalizacion.

   	leer_buffer :
		mov EAX, 3		            ; sys_read
		mov EBX, 0                  ; Indica ingreso por consola STDIN.
		mov ECX, buffer             ; Lo ingresado por usuario se almacenara en buffer.
		mov EDX, 1000               ; EDX = longitud de lo que se leera por consola. 
							        ; Se asume un maximo de 1000 caracteres por linea.
		int 0x80                    ; Genera interrupcion.

		cmp EAX,0                   ; Detecta la secuencia de escape para el fin del ingreso por teclado (Ctrl+D).
		je  continuar				; Si se termino el ingreso por teclado se procede a calcular las metricas del archivo temporal.

		mov EDX, EAX				; EDX = longitud en bytes de lo que se leyo por consola.
		mov EAX, 4                  ; sys_write
		mov EBX, [fd_entrada]	    ; Indica que se escriba por fd_entrada
		mov ECX, buffer             ; Texto a escribir.
		int 0x80                    ; Genera interrupcion.

		jmp leer_buffer              ; Se vuelve a leer por consola.

	continuar :
		mov EAX,6                ; sys_close
    	mov EBX,[fd_entrada]     ; Indica puntero a archivo de entrada.
    	int 0x80                 ; Genera interrrupcion.

		mov EBX,file_temp		 ; EBX = nombre del archivo temporal.
		call abrir_archivo       ; Llamada a la rutina que abre el archivo mencionado en EBX.
								 ; Finalizada la rutina, el file_descriptor del archivo se localiza en EAX.
		mov [fd_entrada],EAX     ; fd_entrada = EAX.
		cmp EAX,0				 ; Se verifica que el proceso "sys_open" haya sido exitoso.
		jge entrada_salida_cons	 ; Si se pudo abrir el archivo de temporal, continua la ejecucion.

		push terminacion_anormal ; Se parametriza la condicion de terminacion.
		jmp _exit                ; Se ejecuta la rutina de finalizacion.

		entrada_salida_cons :
			call procesar 			 		; Llamada a la rutina que se encarga de procesar el archivo temporal.
			call cerrar_archivos 			; Llamada a la rutina que se encarga de cerrar los archivos usados.
			call borrar_arch_temporal		; Se elimina el archivo temporal.
			push terminacion_normal    		; Parametriza la condicion de terminacion.
			jmp _exit   			   		; Se ejecuta la rutina de finalizacion.


un_parametro  :
	call verificar_ayuda					; Se verifica si el usuario solicito ayuda.
	call abrir_archivo                      ; Llamada a la rutina que trata de abrir el archivo de entrada.
	mov [fd_entrada],EAX                    ; fd_entrada = EAX
	cmp EAX,0								; Se verifica que el proceso "sys_open" haya sido exitoso.
	jge entrada_arch_salida_cons			; Si se pudo abrir el archivo de entrada continua la ejecucion.

	push terminacion_anormal_archEntrada    ; Se parametriza la condicion de terminacion.
	jmp _exit                               ; Se ejecuta la rutina de finalizacion.

	entrada_arch_salida_cons :
		call procesar 			 			; Llamada a la rutina que se encarga de procesar el archivo.
		call cerrar_archivos       			; Llamada a la rutina que se encarga de cerrar los archivos usados.
		push terminacion_normal    			; Parametriza la condicion de terminacion.
		jmp _exit   			   			; Se ejecuta la rutina de finalizacion.


dos_parametros :
	call abrir_archivo                      ; Llamada a la rutina que trata de abrir el archivo de entrada.
	mov [fd_entrada],EAX         			; fd_entrada = EAX
	cmp EAX,0								; Se verifica que el proceso "sys_open" haya sido exitoso.
	jge abrir_archSalida					; Si se pudo abrir el archivo de entrada se procede a abrir el archivo de salida.

	push terminacion_anormal_archEntrada	; Se parametriza la condion de terminacion.
	jmp _exit								; Se ejecuta la rutina de finalizacion.

	abrir_archSalida :
		pop EBX								; Se desapila es segundo parametro ARGV[2], que corresponde con el archivo de salida.
		call abrir_archivo_salida    		; Llamada a la rutina que trata de abrir el archivo de salida.
		mov [fd_salida],EAX					; fd_salida = EAX
		cmp EAX,0							; Se verifica que el proceso "sys_open" haya sido exitoso.
		jge entrada_salida_arch				; Si se pudo abrir el archivo de salida, continua la ejecucion.

		push terminacion_anormal_archSalida ; Se parametriza la condicion de terminacion.
		jmp _exit							; Se ejecuta la rutina de finalizacion.

	entrada_salida_arch :
		call procesar 			 ; Llamada a la rutina que se encarga de procesar los archivos.
		call cerrar_archivos     ; Llamada a la rutina que se encarga de cerrar los archivos usados.
		push terminacion_normal  ; Parametriza la condicion de terminacion.
		jmp _exit   			 ; Se ejecuta la rutina de finalizacion.


; Una vez que el control de los parametros fue realizado, esta rutina se encarga del procesamiento posterior.
; Asume que todo los archivos correspondientes pudieron abrirse exitosamente.
procesar :
	mov EBX,[fd_entrada]	   ; EBX = fd_entrada, ya que la rutina calcular_metricas espera dicho parametro.
	call calcular_metricas     ; Llamada a la rutina que calcula las metricas sobre el archivo de entrada.
	mov EBX,[fd_salida]		   ; EBX = fd_salida, ya que la rutina mostrar_resultados espera dicho parametro.
	call mostrar_resultados    ; Llamada a la rutina que se encarga de mostrar los resultados.
	ret


; Rutina que se encarga de abrir un archivo para lectura, cuyo file_name ya se encuentra en el registro EBX.
abrir_archivo  :
    mov EAX,5                  ; sys_open
    mov ECX,0                  ; Modo lectura, para el archivo.  
	mov EDX,0777o              ; Permiso RWE para todos los usuarios.
	int 0x80                   ; Genera interrupcion.
	ret                    	   ; Retorno


; Rutina que se encarga de abrir un archivo para escritura, cuyo file_name ya se encuentra en el registro EBX.
abrir_archivo_salida :
	mov EAX,5                  ; sys_open
    mov ECX,0x241              ; Modo O_CREAT, O_TRUNC y O_WRONLY.
    						   ; si el archivo no existe se crea O_CREAT.
    						   ; si el archivo ya existe, se borra todo su contenido O_TRUNC.
    						   ; si es posible abrirlo, lo hace en modo escritura O_WRONLY.
	mov EDX,0777o              ; Permiso RWE para todos los usuarios.
	int 0x80                   ; Genera interrupcion.
	ret                    	   ; Retorno


; Rutina que se encarga de cerrar los archivos de entrada y salida.
; Si el archivo de salida es "salida estandar" no necesita cerrarlo.
cerrar_archivos :
	mov EAX,6                  ; sys_close
    mov EBX,[fd_entrada]       ; Indica puntero a archivo de entrada.
    int 0x80                   ; Genera interrrupcion.

    mov EAX, [fd_salida]       ; EAX = fd_salida.
    cmp EAX,1                  ; Chequea si la salida fue por STDOUT (salida estandar).
    je fin                     ; Si fd_salida = STDOUT finaliza la rutina.

    mov EAX,6                  ; sys_close
    mov EBX,[fd_salida]        ; Indica puntero a archivo de salida.
    int 0x80                   ; Genera interrrupcion.

    fin :
    	ret 				   ; Retorno


; Rutina que se enxarga de borra el archivo temporal.
borrar_arch_temporal :
	mov EAX,0x0A
	mov EBX,file_temp
	int 0x80
	ret


; Rutina que verifica si el parametro ingresado se corresponde con la secuencia de ayuda "-h"
; Esta rutina esperra ser llamada con call, y requiere modificar el registro ECX sin preocupacion.
; Para llamar a esta rutina, se requiere un puntero a la direccion del parametro, en el registro EAX.
; No se modificara el registro EAX, ya que contiene dicho puntero.
verificar_ayuda :
	mov ECX,0 				   ; Set ECX = 0
	mov CL, BYTE[EBX] 		   ; Low(ECX) = codigo ASCII del primer caracter del parametro.
	cmp CL, "-"				   ; Comparo el 1er caracter con "-".
	jne posible_archivo 	   ; Si el 1er caracter no es igual a "-", entonces el parametro
							   ; probablemente es el nombre de un archivo.

	mov CL, BYTE[EBX+1] 	   ; Low(ECX) = codigo ASCII del segundo caracter del parametro.
	cmp CL, "h" 			   ; comparo el 2do caracter con "h".
	jne posible_archivo        ; si el 2do caracter no es igual a "h", entonces el parametro
							   ; probablemente es el nombre de un archivo.

	mov CL, BYTE[EBX+2]		   ; Low(ECX) = codigo ASCII del tercer caracter del parametro.
	cmp CL, "" 				   ; Comparo el 1er caracter con "" (vacio).
	je mostrar_ayuda 		   ; Si el 3er caracter es igual a "", entonces la secuencia ingresada
							   ; corresponde con "-h", por lo cual el usuario solicita ayuda.
	posible_archivo :
		ret         		   ; Retorno

	mostrar_ayuda :
		call mostrar_about        ; Muestra la ayuda
		push terminacion_normal   ; Parametriza la condicion de terminacion.
		jmp _exit 				  ; Se ejecuta la rutina de finalizacion.


; Rutina que mustra el mensaje de error correspondiente de acuerdo al contenido del registro EBX.
; Espera ser llamada con call, desde la rutina _exit .
; Muestra por pantalla el error. Para eso requiere que quien la llame, coloque el numero de error
; en el registro EBX.
mostrar_error :
	cmp EBX,0    ; verifico si el error de terminacion es 0.
	je exito 	 ; si el error de terminacion es 0, muestro el mensaje de error 0.
	cmp EBX,1 	 ; verifico si el error de terminacion es 1.
	je error1 	 ; si el error de terminacion es 1, muestro el mensaje de error 1.
	cmp EBX,2 	 ; verifico si el error de terminacion es 2.
	je error2 	 ; si el error de terminacion es 2, muestro el mensaje de error 2.
	cmp EBX,3 	 ; verifico si el error de terminacion es 3.
	je error3 	 ; si el error de terminacion es 3, muestro el mensaje de error 3.

	exito :
		mov ECX,msj_error0 		; ECX = mensaje de error 0.
		mov EDX,msj_error0_len 	; EDX = longitud del mensaje de error.
		jmp imprimir 			; imprimo el mensaje de error.

	error1 :
		mov ECX,msj_error1 		; ECX = mensaje de error 1.
		mov EDX,msj_error1_len	; EDX = longitud del mensaje de error.
		jmp imprimir 			; imprimo el mensaje de error.

	error2 :
		mov ECX,msj_error2 		; ECX = mensaje de error 2.
		mov EDX,msj_error2_len	; EDX = longitud del mensaje de error.
		jmp imprimir 			; imprimo el mensaje de error.

	error3 :
		mov ECX,msj_error3 		; ECX = mensaje de error 3.
		mov EDX,msj_error3_len	; EDX = longitud del mensaje de error.
		jmp imprimir 			; imprimo el mensaje de error.

	imprimir :
		push EBX	; preservo el contenido de EBX.
		mov EAX,4	; sys_write
		mov EBX,1	; STDOUT , salida estandar.
		int 0x80	; genera interrupcion.
		pop EBX 	; restauro el contenido de EBX.
		ret 		; retorno.


; Rutina de finalizacion
_exit :
	pop EBX
	call mostrar_error
    mov EAX,1   ; sys_exit
	int 0x80    ; Genera interrupcion.


%endif;METRICAS