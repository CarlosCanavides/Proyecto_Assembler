%ifndef ABOUT
%define ABOUT

%define LF 0xA

section .data
	mensaje_about 
		db 	LF, LF
		db 	"NOMBRE" , LF
		db	"	metricas - calculadora de metricas de texto", LF, LF
		db	"SINOPSIS", LF
		db	"	metricas [-h] [<archivo_entrada>] [<archivo_entrada> <archivo_salida>]", LF, LF
		db	"DESCRIPCION", LF
		db	"	Metricas es una rapida calculadora de diversas metricas sobre textos.", LF
		db	"	Los textos analizados pueden provenir de distintas fuentes, segun los ", LF
		db	"	argumentos con los que se ejecute la aplicacion pueden utilizarse como", LF
		db	"	fuente tanto la consola del sistema como un archivo almacenado.", LF
		db	"	De igual manera, las metricas pueden ser mostradas por consola, o pueden", LF
		db	"	ser almacenadas en un nuevo archivo, esto tambien dependera del modo de ", LF
		db	"	ejecucion de la aplicacion", LF, LF
		db	"	En esta pagina encontraras los comandos que Metricas ofrece", LF, LF
		db	"OPCIONES", LF
		db	"	-h", LF
		db	"		Muestra la pagina de ayuda de la aplicacion", LF, LF
		db	"	<archivo_entrada>", LF
		db	"		Calcula las metricas del texto contenido en el archivo", LF
		db	"		de entrada proveido.", LF
		db	"		Los resultados seran mostrados por la consola del sistema", LF, LF
		db	"	<archivo_entrada> <archivo_salida>", LF
		db	"		Calcula las metricas del texto contenido en el archivo", LF
		db	"		de entrada proveido.", LF
		db	"		Los resultados seran guardados en el archivo de salida indicado,", LF
		db	"		este sera creado en caso de que no exista.", LF, LF
		db	"AUTORES", LF
		db	"	Metricas fue creado por Carlos Canavides y Nicolas Vera, ambos", LF
		db	"	alumnos de la Universidad Nacional del Sur.", LF, LF
		db	"	El proyecto surgio como parte de la materia Organizacion", LF
		db	"	de Computadoras.", LF, LF
		db	"REPORTE DE BUGS", LF
		db	"	La aplicacion se encuentra alojada en un repositorio de GitHub,", LF
		db	"	en caso de que se desee reportar algun bug se puede crear", LF
		db	"	un nuevo Issue alli.", LF, LF
		db	"	La ubicacion del repositorio es:", LF
		db	"		https://github.com/CarlosCanavides/Proyecto_Assembler", LF, LF
		db	"MAS INFORMACION", LF
		db	"	Si se desea conocer mas acerca de la aplicacion por favor", LF
		db	"	revisar la documentacion provista", LF, LF

	length_mensaje EQU $ - mensaje_about


section .text
	global mostrar_about



; Subrutina que espera ser llamada con call
; Muestra por consola el about de la aplicacion
; No modifica el contenido de ningun registro
mostrar_about:
	push EAX 	; Preservo el contenido del registro EAX
	push EBX	; Preservo el contenido del registro EBX
	push ECX	; Preservo el contenido del registro ECX
	push EDX	; Preservo el contenido del registro EDX
	
	mov EAX, 4	; sys_write
	mov EBX, 1	; STD_OUT (Consola del sistema)
	mov ECX, mensaje_about		; Informacion ABOUT
	mov EDX, length_mensaje		; Largo de ABOUT
	int 0x80	; Interrupcion
	
	pop EDX		; Restauro el contenido del registro EDX
	pop ECX		; Restauro el contenido del registro ECX
	pop EBX		; Restauro el contenido del registro EBX
	pop EAX 	; Restauro el contenido del registro EAX
	ret 		; Retorno de la subrutina


%endif