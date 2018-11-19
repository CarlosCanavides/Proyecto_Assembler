%define terminacion_normal 0                 ; terminacion normal
%define terminacion_anormal_archEntrada 1     ; terminacion anormal por error en el archivo de entrada
%define terminacion_anormal_archSalida  2     ; terminacion anormal por error en el archivo de salida
%define terminacion_anormal 3				 ; terminacion anormal por otras causas

section .data

section .bss

section .text
global _start

_start :
	pop EAX          ; EAX contiene ARGC 
	pop EBX          ; descartamos ARGV[0]

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
			  push terminacion_normal
			  jmp _exit

unParametro  :
			  mov EAX,5        ; sys_open
			  mov ECX,0        ; modo solo lectura, para el archivo.  
			  mov EDX,0777     ; permiso RWE para todos los usuarios.
			  jmp _exit

dosParametros :
			  jmp _exit

_exit :
	   mov EAX,1
	   pop EBX
	   int 0x80