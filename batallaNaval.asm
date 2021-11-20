;Gabriel Alexander Maldonado Rodriguez
;Aaron Reyes 


.model small
.data

;Variables
corX db 0       ;cordenada de las colubnas para el disparo
corY db 0       ;cordenada de las filas para el disparo 
nDisparos db 0  ;Numero de disparos

;Areglos


;Texto
msgMisil db "Misil $"
msgIngreso db ",ingrese la celda a atacar: $"
msgExitoso db "Impacto confirmado$"   
msgFallido db "Sin impacto$"


.code
.start

;---------------------------------Generacion de Tablero---------------------------------






;---------------------------------Ingreso de cordenadas---------------------------------

ingresoCordenadas:  ;Imprime el mensaje para el ingreso de cordenadas
inc nDisparos

mov ah , 09h
lea dx , msgMisil
int 21h             ;Imprecion del mensaje en msgMisil
                    
mov ax , 00h
mov al , nDisparos
mov bl , 10
div bl
mov dx , ax
mov ah , 02h
add dl , 30h
int 21h             ;Imprecion del las decenas de nDisparos
mov dl , dh
add dl , 30h
int 21h             ;Imprecion del las unidades de nDisparos


mov ah , 09h
lea dx , msgIngreso 
int 21h             ;Imprecion del mensaje en msgIngreso

jmp scanerLetra     ;Salto a scanerLetra (Inicio del ingreso de datos)



scanerLetra:        ;Extrae una letra entre A-F o a-f, si se ingresa algo incorecto lo borra
call borrar
  
mov ah , 01h
int 21h             ;Extrae un caracter del teclado y lo guarda en al

cmp al , 65
jb scanerLetra      ;Si lo ingresado esta debajo de A(65 ASCII) , salto a scanerLetra

cmp al , 70
jbe mayuscula       ;Si caracter ingresado entre A(65 ASCII)-F(70 ASCII) salto a mayuscula 
 

cmp al , 97         
jb scanerLetra      ;Si lo ingresado esta encima de F(70 ASCII) y debajo de a(97 ASCII), salto a scanerLetra

cmp al , 102
jbe minuscula       ;Si caracter ingresado entre a(97 ASCII)-f(102 ASCII) salto a minuscula

jmp scanerLetra     ;Si el caracter ingresado no esta entre A-F o a-f, salto a scanerLetra


mayuscula:          ;Convierte caracter de A-F a entero de 1-6
sub al , 64         ;Conversion a numero
mov corX ,al        ;Guardado en memoria
mov ah , 02h
mov dl , 00h
int 21h             ;Imprime un espacio para evitar que la letra se borre al entrar en scanerNumero
jmp scanerNumero    ;Salto a scanerNumero


minuscula:          ;Convierte caracter de a-f a entero de 1-6
sub al , 96         ;Conversion a entero
mov corX ,al        ;Guardado en memoria
mov ah , 02h
mov dl , 00h
int 21h             ;Imprime un espacio para evitar que la letra se borre al entrar en scanerNumero
jmp scanerNumero    ;scanerNumero



scanerNumero:       ;Extrae una caracter entre 1-6, si se ingresa algo incorecto lo borra
call borrar  
mov ah , 01h
int 21h             ;Extrae un caracter del teclado y lo guarda en al

cmp al , 54
ja  scanerNumero    ;Si caracter ingresado esta encima de 6(54 ASCII) salto a scanerNumero
cmp al , 49
jb  scanerNumero    ;Si caracter ingresado esta debajo de 1(49 ASCII) salto a scanerNumero

sub al , 30h        ;Conversion de caracter a entero
mov corY , al       ;Guardado en memoria

jmp disparar        ;Si caracter ingresdo entre 1(49 ASCII)-6(54 ASCII) salto a disparar 

    

borrar:             ;Borra un caracter de pantalla
mov ah , 02h
mov dl , 8
int 21h             ;Retrosede un un espacio el puntero
mov dl , 00h
int 21h             ;Imprimer un espacion en blanco
mov dl , 8
int 21h             ;Retrosede un un espacio el puntero
ret 



;---------------------------------Disparos---------------------------------

disparar:           ;Revisa el valor de matriz en la cordenas de ingresada (corX,corY) 
jmp salir



;---------------------------------Juego ganado---------------------------------




;---------------------------------Juego perdido---------------------------------




salir: ;Cerrar programa 
.exit
end