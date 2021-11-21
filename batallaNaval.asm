;Gabriel Alexander Maldonado Rodriguez
;Aaron Reyes 


.model small
.data

;Variables
corX db 0       ;cordenada de las colubnas para el disparo
corY db 0       ;cordenada de las filas para el disparo 
nDisparos db 0  ;Numero de disparos

;Areglos
           ;A B C D E F
array   db (0,0,3,3,3,0) ;1
        db (0,4,0,0,0,5) ;2
        db (0,4,0,0,0,5) ;3
        db (0,4,0,0,0,5) ;4
        db (0,4,0,0,0,5) ;5
        db (0,0,0,0,0,5) ;6

;Texto
msgMisil db "Misil $"
msgIngreso db ",ingrese la celda a atacar: $"
msgExitoso db "..................Impacto confirmado$"   
msgFallido db "..................Sin impacto$"
msgRepetido db "..................Ya disparo hay, no desperdicie misiles!$"


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

mov al , 6
mov bl ,corY
dec bl
mul bl              
dec al              ;Los calculos determinana la posicicion del ultimo elemento de la fila anterior (6,corY-1) en la matriz

add al , corX       ;Determina la posicion derminada por (corX, corY) en la matriz
mov ah , 00h
mov si , ax         ;Guarde la posicion derminada por (corX, corY) en la matriz en si 
mov al ,array[si]   ;Extrae el valor de la mtriz en posicion si

cmp al , 0
je tiroFallido     ;Si al == 0, el tiro fue al agua

cmp al , 1
ja tiroExitoso     ;Si al > 1 , el tiro fue a un barco ()
je tiroRepetido    ;Si al== 1 , ya disparo hay


tiroRepetido:
mov ah , 09h
lea dx , msgRepetido
int 21h             ;Imprecion del mensaje en msgRepetido
                    

jmp continuar
 

tiroFallido:       ;Imprime el mensaje de tiro fallido
mov ah , 09h
lea dx , msgFallido
int 21h             ;Imprecion del mensaje en msgFallido
                    
                    ;Revicion si el ultimo tiro undio a un barco

jmp continuar 


tiroExitoso:       ;Imprime el mensaje de tiro exitoso y cambia el valor en esa cordenada a 1
mov ah , 09h
lea dx , msgExitoso
int 21h             ;Imprecion del mensaje en msgExitoso
mov array[si] , 1   ;Asigna el valor de 1 a la matriz en la posicion si
jmp continuar


continuar:         ;Controla si el juego continua o acaba   

mov ah,02h
mov dl,13
int 21h            ;Retorno de carro (regreso al inicio de la linea)
  
mov dl,10
int 21h            ;Salto a nueva linea


                   ;Comprobar si todos los barcos ya an sido undidos;
                   
                   
mov dl , nDisparos
cmp dl , 20
jae salir          ;Paro provicional del programa

jb ingresoCordenadas
                   
                   
;---------------------------------Juego ganado---------------------------------




;---------------------------------Juego perdido---------------------------------



;---------------------------------Nueva partida---------------------------------




salir: ;Cerrar programa 
.exit
end