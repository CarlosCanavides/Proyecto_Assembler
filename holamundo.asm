; -------------------------------------------------------------------------
; Organizacion de computatoras :: 2018.
; Ing. Federico Joaquin.
; Muestra el "Hola Mundo" por consola.
; $ ./holamundo
; -------------------------------------------------------------------------

section .data
	mensaje db “Hola OC 2018",0xa 	; reserva memoria para el msg.
	longitud equ $ - mensaje 		; indica la longitud del mensaje.

section .text
	global _start 		; etiqueta que indica el comienzo del programa

_start:
	mov EAX, 4 			; indica syscall a realizar (sys_write).
	mov EBX, 1 			; indica el archivo destino (STDOUT).
	mov ECX, mensaje 	; referencia el buffer que aloja los datos a escribir.
	mov EDX, longitud 	; indica la cantidad de bytes a escribir.
	int 0x80 			; genera interrupción para ejecutar syscall.
	
	mov EAX, 1 			; indica syscall a realizar (sys_exit).
	mov EBX, 0 			; indica código de terminación.
	int 0x80 			; genera interrupción para ejecutar syscall.
  
; yasm -f elf holamundo.asm
; ld -o holamundo holamundo.o
; ./holamundo