%define terminacion_normal 0                  ; terminacion normal
%define terminacion_anormal_archEntrada 1     ; terminacion anormal por error en el archivo de entrada
%define terminacion_anormal_archSalida  2     ; terminacion anormal por error en el archivo de salida
%define terminacion_anormal 3				  ; terminacion anormal por otras causas

section .data
	fd_entrada dd 0                ; reserva memoria para mantener el descriptor del archivo de entrada.
	fd_salida  dd 1                ; reserva memoria para mantener el descriptor del archivo de salida de los resultados. Por defecto es por consola.
	file_temp  db "temporal.txt"   ; nombre del archivo temporal, sera utilizado cuando la cantidad de parametros sea 0.

section .bss
	input resb 1

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

   	leerCaracter :
		mov EAX, 3					; sys_read
		mov EBX, 0                  ; indica ingreso por consola STDIN.
		mov ECX, input              ; lo ingresado por usuario se almacenara en input.
		mov EDX, 1                  ; longitud de lo que se leera por consola.
		int 0x80                    ; genera interrupcion.

		cmp EAX,0                   ; Detecta la secuencia de escape para el fin del ingreso por teclado (Ctrl+D).
		je  continuar				; si se termino el ingreso por teclado se procede a calcular las metricas del archivo temporal.

		mov EAX, 4                  ; sys_write
		mov EBX, [fd_entrada]	    ; indica que se escriba por fd_entrada
		mov ECX, input              ; texto a escribir.
		mov EDX, 1                  ; longitud del texto a escribir.
		int 0x80                    ; genera interrupcion.

		jmp leerCaracter            ; se vuelve a leer otro caracter.

	continuar :
		push terminacion_normal         ; parametriza la condicion de terminacion.
		jmp _exit                       ; se ejecuta rutina de finalizacion.

unParametro  :
	mov EAX,5                    ; sys_open
	mov ECX,0                    ; modo solo lectura, para el archivo.  
	mov EDX,0777                 ; permiso RWE para todos los usuarios.
	int 0x80                     ; genera interrupcion.

	mov [fd_entrada],EAX         ; fd_entrada = EAX

	jmp _exit

dosParametros :
			   jmp _exit

abrirArchivo  :
    mov EAX,5                  ; sys_open
    mov ECX,2                  ; modo lectura y escritura, para el archivo.  
	mov EDX,0777               ; permiso RWE para todos los usuarios.
	int 0x80                   ; genera interrupcion.
	ret                        ; retorno

cerrarArchivos :
	mov EAX,6                  ; sys_close
    mov EBX,[fd_entrada]       ; indica puntero a archivo de entrada.
    int 0x80                   ; genera interrrupcion.

    mov EAX,6                  ; sys_close
    mov EBX,[fd_salida]        ; indica puntero a archivo de salida.
    int 0x80                   ; genera interrrupcion.

    ret                        ; retorno

calcularMetricas :
	mov EAX, 3			     ; sys_read
    mov EBX, [fd_entrada]    ; indica ingreso por consola fd_entrada.
    mov ECX, input           ; input  = lugar donde se almacenara lo leido del archivo de entrada.
    mov EDX, 1               ; 1 byte = longitud de lo que se leera del archivo de entrada.
    int 0x80                 ; genera interrupcion.

_exit :
    mov EAX,1   ; sys_exit
	pop EBX     ; condicion de terminacion.
	int 0x80    ; genera interrupcion.