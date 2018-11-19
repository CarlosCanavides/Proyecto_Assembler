%define terminacion_normal 0                  ; terminacion normal
%define terminacion_anormal_archEntrada 1     ; terminacion anormal por error en el archivo de entrada
%define terminacion_anormal_archSalida  2     ; terminacion anormal por error en el archivo de salida
%define terminacion_anormal 3				  ; terminacion anormal por otras causas

section .data
	fd_entrada dd 0     ; reserva memoria para mantener el descriptor del archivo de entrada.
	fd_salida  dd 1     ; reserva memoria para mantener el descriptor del archivo de salida de los resultados. Por defecto es por consola.

section .bss

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
			   ;mov  eax, 8               ; sys_creat
   			   ;mov  ebx, fd_entrada      ;
   			   ;mov  ecx, 0777            ; permiso RWE para todos los usuarios.
   			   ;int  0x80                 ; genera interrrupcion.

   			   ;mov [fd_entrada],EAX

			    push terminacion_normal   ; parametriza la condicion de terminacion.
			    jmp _exit

unParametro  :
			  mov EAX,5                   ; sys_open
			  mov ECX,0                   ; modo solo lectura, para el archivo.  
			  mov EDX,0777                ; permiso RWE para todos los usuarios.
			  mov [fd_entrada],EAX        ; fd_entrada = EAX

			  jmp _exit

dosParametros :
			   jmp _exit

cerrarArchivos :
                mov EAX,6                  ; sys_close
                mov EBX,[fd_entrada]       ; indica puntero a archivo de entrada.
                int 0x80                   ; genera interrrupcion.

                mov EAX,6                  ; sys_close
                mov EBX,[fd_salida]        ; indica puntero a archivo de salida.
                int 0x80                   ; genera interrrupcion.

_exit :
	   mov EAX,1   ; sys_exit
	   pop EBX     ; condicion de terminacion.
	   int 0x80    ; genera interrupcion.