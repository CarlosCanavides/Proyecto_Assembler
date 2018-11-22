%define terminacion_normal 0                  ; terminacion normal
%define terminacion_anormal_archEntrada 1     ; terminacion anormal por error en el archivo de entrada
%define terminacion_anormal_archSalida  2     ; terminacion anormal por error en el archivo de salida
%define terminacion_anormal 3				  ; terminacion anormal por otras causas

;%include "automata_lexico.asm"

section .data
	mensaje    db "hola"
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
	je ceroParametros    ; EAX = 0  ---> Rutina para 0 armumento.

	pop EBX              ; conservamos ARGV[1]

	cmp EAX,2            ; ¿La cantidad de parametros es igual a 1?
	je unParametro       ; EAX = 1  ---> Rutina para 1 armumento.

	cmp EAX,3            ; ¿La cantidad de parametros es igual a 2?
	je dosParametros     ; EAX = 2  ---> Rutina para 2 armumento.

	push terminacion_anormal  ; Si la cantidad de parametros no es la esperada, se produce una terminacion anormal.
	jmp _exit

ceroParametros :
	mov  EAX, 8                 ; sys_creat
   	mov  EBX, file_temp         ; EBX = nombre del archivo temporal.
   	mov  ECX, 0777              ; permiso RWE para todos los usuarios.
   	int  0x80                   ; genera interrrupcion.

   	mov [fd_entrada],EAX        ; fd_entrada = EAX;

   	leerBuffer :
		mov EAX, 3					; sys_read
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

		jmp leerBuffer              ; se vuelve a leer por consola.

	continuar :
		push terminacion_normal  ; parametriza la condicion de terminacion.

		mov EAX,6                ; sys_close
    	mov EBX,[fd_entrada]     ; indica puntero a archivo de entrada.
    	int 0x80                 ; genera interrrupcion.

		mov EBX,file_temp		 ; EBX = nombre del archivo temporal.
		call abrirArchivo        ; llamada a la rutina que abre el archivo mencionado en EBX.
								 ; finalizada la rutina, el file_descriptor del archivo se localiza en EAX.

		mov [fd_entrada],EAX     ; fd_entrada = EAX.

		call calcularMetricas    ; llamada a la rutina que calcula las metricas sobre el archivo temporal.
		call cerrarArchivos      ; llamada a la rutina que se encarga de cerrar los archivos usados.
		jmp _exit                ; se ejecuta rutina de finalizacion.

unParametro  :
	call abrirArchivo            ; llamada a la rutina que trata de abrir el archivo de entrada.
	mov [fd_entrada],EAX         ; fd_entrada = EAX
	call calcularMetricas        ; llamada a la rutina que calcula las metricas sobre el archivo de entrada.
	jmp _exit                    ; se ejecuta la rutina de finalizacion.

dosParametros :
	call abrirArchivo            ; llamada a la rutina que trata de abrir el archivo de entrada.
	mov [fd_entrada],EAX         ; fd_entrada = EAX
	call calcularMetricas        ; llamada a la rutina que calcula las metricas sobre el archivo de entrada.
	jmp _exit                    ; se ejecuta la rutina de finalizacion.

abrirArchivo  :
    mov EAX,5                  ; sys_open
    mov ECX,0                  ; modo lectura, para el archivo.  
	mov EDX,0777               ; permiso RWE para todos los usuarios.
	int 0x80                   ; genera interrupcion.
	ret                        ; retorno

cerrarArchivos :
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

calcularMetricas :
	leer_linea :
		mov EAX,3                  ; sys_read
		mov EBX,[fd_entrada]	   ; EBX = archivo de entrada.
		mov ECX,caracter 		   ; buffer donde se almacenara lo leido del archivo.
		mov EDX,1000 			   ; EDX = longitud de lo que se leera por consola. 
								   ; Se asume un maximo de 1000 caracteres por linea. 
		int 0x80                   ; genera interrupcion.

	cmp EAX,0                  ; compara la cantidad de bytes que se pudieron leer del archivo con 0.
	je finalizar               ; si la cantidad de bytes leidas es 0, se alcanzo el EOF del archivo.

	ret

	finalizar :
		; muestra por pantalla el mensaje "hola" cuando se llego a EOF
		; Dev only
		mov EDX,4
		mov EAX, 4
		mov EBX, 1
		mov ECX, mensaje
		int 0x80

		ret

_exit :
    mov EAX,1   ; sys_exit
	pop EBX     ; condicion de terminacion.
	int 0x80    ; genera interrupcion.