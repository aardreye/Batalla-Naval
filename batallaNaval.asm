;Gabriel Alexander Maldonado Rodriguez
;Aaron David Reyes Holguin 


.model small
.data

;----------Variables----------
corX db 0       ;coordenada  de las columnas para el disparo
corY db 0       ;coordenada  de las filas para el disparo 
nDisparos db 0  ;Numero de disparos

;vp de los barcos
vpSubmarino db 3
vpCrucero db 4 
vpPortaAviones db 5

;----------Arreglos----------
           ;ABCDEF
x_random db ?       ;coordenada  random en x para colocar barco
y_random db ?       ;coordenada  random en y para colocar barco

table   db 6 dup(0) ;1
        db 6 dup(0) ;2
        db 6 dup(0) ;3
        db 6 dup(0) ;4
        db 6 dup(0) ;5
        db 6 dup(0) ;6 

cordenadasX db " A B C D E F $"
borde db "_____________$"

;----------Texto---------- 

intruciones db "Instrucciones BatallaNaval:",10 , 13 
            db "1. Para una adecuada impresion de texto juegue en una resolucion de 80x25 char",10,13
            db "2. De ingresar una coordenada no valida el programa no registrara su ingreso",10,13
            db "3. Presione ENTER para disparar a las cordenadas ingresadas",10,13 
            db "4. De volver a disparar en una misma coordena, el programa no disparara " ,10,13
            db "5. El proceso de generacion de tablero puede tardar. Sea paciente",10,13
            db "6. Bajo ninguna circunstancia modifique el codigo!",10,13
            db "$"

;Mesajes de ingreso 
msgInicio1  db "        ************************************************************", 10,13
            db "        ************************************************************", 10,13
            db "        **                                                        **", 10,13 
            db "        **             BIENVENIDO A LA BATALLA NAVALA             **", 10,13  
            db "        **                                                        **", 10,13
            db "        **             ....el estilo de la pelea....              **", 10,13 
            db "        **                                                        **", 10,13 
            db "        ************************************************************", 10,13
            db "        ************************************************************$" 
msgInicio2 db " Presiona ENTER para visualizar el tablero y ubicar los barcos aleatoriamente $" 
msgInicio3 db "Generando tablero aleatorio............ Espere por favor $"
msgMisil db "Misil $"
msgIngreso db ",ingrese la celda a atacar: $"

msgFin db "Muchas gracias por jugar. Hasta la proxima $"

msgNuevaPartida db "Ingrese ENTER para nueva partida y ESC para acabar el programa $"

;Notificasiones de disparo
msgExitoso db "..................Impacto confirmado$"   
msgFallido db "..................Sin impacto$"
msgRepetido db "..................Ya disparo ahi",10,13
            db ",No desperdicie misiles!$"

;Notificasiones de hundimiento
msgSubmarinoHundido db 10 , 13 , ",Submarino hundido.$"
msgCruseroHundido db 10 , 13 ,",Crucero hundido.$"
msgPortaAvionesHundido db 10 , 13 ,",Portaaviones hundido.$"

;Mensajes de final de juego:
msgGanador1  db " *********************************************************** ", 10,13
             db " *********************************************************** ", 10,13
             db " **                                                       ** ", 10,13
             db " ** ||   ||                                       ||   || ** ", 10,13 
             db " **    ?         EN HORA BUENA, HAS GANADO!!!        ?    ** ", 10,13  
             db " ** \\   //                                       \\   // ** ", 10,13
             db " **  \___/                                         \___/  ** ", 10,13 
             db " **                                                       ** ", 10,13 
             db " *********************************************************** ", 10,13 
             db " *********************************************************** $"
msgGanador2 db "Numero de total de tiros: $"

msgPerdedor1 db " ************************************************************* ", 10,13
             db " ************************************************************* ", 10,13
             db " **\ \  / /                                         \ \  / /** ", 10,13
             db " ** \ \/ /                                           \ \/ / ** ", 10,13 
             db " **  \  /        HAS AGOTADO TODOS TUS MISILES        \  /  ** ", 10,13  
             db " **  /  \                                             /  \  ** ", 10,13
             db " ** / /\ \   Juego perdido, vuelve a intentarlo!!!   / /\ \ ** ", 10,13 
             db " **/ /  \ \                                         / /  \ \** ", 10,13 
             db " ************************************************************* ", 10,13 
             db " ************************************************************* $"
msgPerdedor2 db "Objetivos restantes por disparar: $"
msgPerdedor3 db "Imprimiendo tablero $"
msgPerdedor4 db "S = Submarino      C = Crucero     P = Portaaviones $"
msgPerdedor5 db "0 = Agua       1 = Disparos Acertados  $" 

msgSalir6 db "Gracias por jugar $"

.code
.start

;---------------------------------Inicio del juego-----------------------------------

inicio:                         ;Establece el modo de video y muestra las instruciones
    mov ah ,00h
    mov al ,03h
    int 10h                     ;Define el modo de video (03h - text mode. 80x25. 16 colors. 8 pages)
    
    
    mov ah , 09h
    lea dx , intruciones
    int 21h                     ;Impresion del mensaje en intrucciones
    
    
    call saltoLinea 
    
    mov ah , 09h
    lea dx , msgInicio2
    int 21h                     ;Impresion del mensaje en msgInicio2
    
    jmp iniciar


iniciar:                        ;Arranca el juego al ingresar ENTER
    mov ah , 00h
    int 16h  
 
    cmp al , 13
    je bienvenido               ;De ingresar ENTER el programa continua
    
    jne iniciar  
               
bienvenido:                     ;Muestra el mensaje de bienvenida y arranca la primera partida
    
    call saltoLinea 
      
    mov ah , 09h
    lea dx , msgInicio1
    int 21h                     ;Impresion del mensaje en msgInicio1 
    
    jmp generarTablero

    

;---------------------------------Generacion de Tablero---------------------------------
generarTablero:                 ;Genera el tablero con las naves ubicadas aleatoriamente
    call saltoLinea             ;Salto de liena
    
    call imprimirMatriz         
    
    call saltoLinea             ;Salto de linea
    
    mov ah , 09h
    lea dx , msgInicio3
    int 21h                     ;Impresion del mensaje en msgInicio3
    
    call saltoLinea             ;Salto de linea
    jmp place_p_aircraft   
    

;COLOCA UN PORTAVIONES DE FORMA ALEATORIA EN EL TABLERO
place_p_aircraft: ; 50h >> 5 
    call coordinate_random      ;Genera una coordenada random
    call get_coordinate         ;Obtiene el valor de la coordenada random en el tablero
    
    mov bl, x_random            ;Asigna el valor de x_random a bl
    mov cl, 6                   ;cl es numero maximo de coordenadas X o Y
    
    cmp bl, 4                   
    jg fill_left_p_aircraft     ;Si bl es mayor a 4 la matriz se rellena de derecha a izquierda
    
    cmp bl, 3
    jl fill_right_p_aircraft    ;Si bl es mayor a 3 la matriz se rellena de izquierda a derecha
    
    mov bl, y_random            ;Ahora se asigna el valor de y_random a bl
    
    cmp bl, 4
    jg fill_up_p_aircraft       ;Si bl es mayor a 4 la matriz se rellena de abajo hacia arriba
    
    cmp bl, 3
    jl fill_down_p_aircraft     ;Si bl es mayor a 3 la matriz se rellena de arriba hacia abajo
    
    cmp bl, 4
    je place_p_aircraft         ;Si bl es igual a 4 la matriz no se puede rellenar, el proceso vuelve a empezar
    
    cmp bl, 3                   ;Si bl es igual a 3 la matriz no se puede rellenar, el proceso vuelve a empezar
    je place_p_aircraft


;COLOCA UN CRUCERO DE FORMA ALEATORIA EN EL TABLERO
place_cruise: ; 43h >> 4
call coordinate_random          ;Genera una coordenada random
call get_coordinate             ;Obtiene el valor de la coordenada random en el tablero
call empty_coordinate_cruise    ;Se asegura que la coordenada random este vacia

mov bl, x_random                ;Asigna el valor de x_random a bl
mov cl, 6                       ;cl es numero maximo de coordenadas X o Y

cmp bl, 4
jge find_space_cruise_left      ;Si bl es mayor a 4 la matriz se rellena de derecha a izquierda 

cmp bl, 3
jle find_space_cruise_right     ;Si bl es mayor a 3 la matriz se rellena de izquierda a derecha


;COLOCAR UN SUBMARINO DE FORMA ALEATORIA EN EL TABLERO
place_submarine: ; 53h >> 3
call coordinate_random          ;Genera una coordenada random
call get_coordinate             ;Obtiene el valor de la coordenada random en el tablero
call empty_coordinate_submarine ;Se asegura que la coordenada random este vacia

mov bl, y_random                ;Asigna el valor de y_random a bl
mov cl, 6                       ;cl es numero maximo de coordenadas X o Y

cmp bl, 4
jge find_space_submarine_up     ;Si bl es mayor a 4 la matriz se rellena de abajo hacia arriba

cmp bl, 3
jle find_space_submarine_down   ;Si bl es mayor a 3 la matriz se rellena de arriba hacia abajo


;COLOCAR UN PORATAAVIONES DE DERECHA A IZQUIERDA
fill_left_p_aircraft:
mov table[si], 50h              ;Asigna el ascii de P a la matriz en la posicion si
dec si
dec cl      
cmp cl, 1
jg fill_left_p_aircraft         ;Si el numero maximo de coordenadas X o Y es mayor a 1 se repite el ciclo
jle place_cruise                ;Si el numero maximo de coordenadas X o Y es menor a 1 busca espacio para la siguiente nave


;COLOCAR UN PORATAAVIONES DE IZQUIERDA A DERECHA
fill_right_p_aircraft:
mov table[si], 50h              ;Asigna el valor de 1 a la matriz en la posicion si
inc si
dec cl      
cmp cl, 1                       
jg fill_right_p_aircraft        ;Si el numero maximo de coordenadas X o Y es mayor a 1 se repite el ciclo
jle place_cruise                ;Si el numero maximo de coordenadas X o Y es menor a 1 busca espacio para la siguiente nave


;COLOCAR UN PORATAAVIONES DE ABAJO HACIA ARRIBA
fill_up_p_aircraft:
mov table[si], 50h              ;Asigna el ascii de P a la matriz en la posicion si
sub si, 6
dec cl      
cmp cl, 1
jg fill_up_p_aircraft           ;Si el numero maximo de coordenadas X o Y es mayor a 1 se repite el ciclo
jle place_cruise                ;Si el numero maximo de coordenadas X o Y es menor a 1 busca espacio para la siguiente nave


;COLOCAR UN PORATAAVIONES DE ARRIBA HACIA ABAJO
fill_down_p_aircraft:
mov table[si], 50h              ;Asigna el ascii de P a la matriz en la posicion si
add si, 6
dec cl      
cmp cl, 1
jg fill_down_p_aircraft         ;Si el numero maximo de coordenadas X o Y es mayor a 1 se repite el ciclo
jle place_cruise                ;Si el numero maximo de coordenadas X o Y es menor a 1 busca espacio para la siguiente nave


;GENERAR UN NUMERO RANDOM EN EL RANGO DE 1 A 6   
number_random:          
mov ah, 00h                     ; obtiene la hora del sistema
int 1Ah                         ; cx: dx = numero de tics del reloj desde la medianoche

mov ax, dx                      ; ahora ax contiene  el numero de tics
xor dx, dx                      ; se borra el registro dx porque posteriormente lo utilizaremos nuevamente
mov cx, 6                       ; asignamos el decimal 6 a cx, para obtener un residuo de 0 a 5
div cx                          ; obtenemos un resto en el rango de 0 a 5 y se almacena en dx    
add dl, 1                       ; agregamos ASCII '1'(49) a dx para ponerlos en ASCII '1' a '6'
ret


;GENERAR UNA COORDENADA RANDOM EN EL RANGO DE 1 A 6

coordinate_random:
call number_random              ;Genera un numero random
mov x_random, dl                ;Asigna un numero random a x_random
call number_random              ;Genera otro numero random
mov y_random, dl                ;Asigna un numero random a x_random
ret 


;OBTENER EL VALOR DE LA COORDENADA RANDOM EN AL
get_coordinate:
mov al , 6
mov bl , y_random
dec bl
mul bl              
dec al              

add al , x_random               ; Posicionamiento aleatorio de "x"
mov ah , 00h
mov si , ax                     ; Guarda la coordenada aleatoria (x,y) en el registro si 
mov al , table[si]              ; Extrae el valor de la matriz en posicion almacenada en registro si
ret


;VERIFICAR QUE LA COORDENADA PARA EL CRUCERO ESTE VACIA 
empty_coordinate_cruise:
cmp al, 0                       ; Si el valor de la coordena random es mayor a 0 esta ocupado el espacio
mov di, 3                       ; di es el tamanio del submarino
mov bp, si
jg place_cruise                 ;si no esta vacio generar otra coordenada
ret

;VERIFICAR QUE LA COORDENADA PARA EL SUBMARINO ESTE VACIA
empty_coordinate_submarine:
cmp al, 0                       ; Si el valor de la coordena random es mayor a 0 esta ocupado el espacio
mov di, 2                       ; di es el tamanio del submarino
mov bp, si
jg place_submarine              ; Si no esta vacio generar otra coordenada
ret

;COLOCAR UN CRUCERO DE DERECHA A IZQUIERDA
fill_left_cruise:
mov table[si], 43h              ;Asigna el valor ascii de C a la matriz en la posicion si
dec si              
dec cl      
cmp cl, 2                       ; pone un limite de 4 posicionamientos en el tablero
jg fill_left_cruise         
jle place_submarine     


find_space_cruise_left:         ;Busca un espacio libre a la isquierda en matriz para ubicar el crucero
cmp di, 0
je fill_left_cruise
dec di

dec bp
mov al, table[bp]
cmp al, 0
je find_space_cruise_left
jg place_cruise
    
;COLOCAR UN CRUCERO DE IZQUIERDA A DERECHA
fill_right_cruise:
mov table[si], 43h              ;Asigna el valor ascii de C a la matriz en la posicion si
inc si
dec cl      
cmp cl, 2                       ; pone un limite de 4 posicionamientos en el tablero
jg fill_right_cruise
jle place_submarine


find_space_cruise_right:        ;Busca un espacio libre a la derecha en matriz para ubicar el crucero
cmp di, 0
je fill_right_cruise
dec di

inc bp
mov al, table[bp]
cmp al, 0
je find_space_cruise_right
jg place_cruise


;COLOCAR UN SUBMARINO DE ABAJO HACIA ARRIBA
fill_up_submarine:
mov table[si], 53h              ;Asigna el valor ascii de S a la matriz en la posicion si
sub si, 6
dec cl      
cmp cl, 3                       ; pone un limite de 3 posicionamientos en el tablero
jg fill_up_submarine
jle cambiar_si
 
 
find_space_submarine_up:        ;Busca un espacio libre hacia arriba en matriz para ubicar el submarino
cmp di, 0
je fill_up_submarine
dec di

sub bp, 6
mov al, table[bp]
cmp al, 0
je find_space_submarine_up
jg place_submarine      


;COLOCAR UN SUBMARINO DE ARRIBA HACIA ABAJO
fill_down_submarine:
mov table[si], 53h              ;Asigna el valor ascii de S a la matriz en la posicion si
add si, 6
dec cl      
cmp cl, 3                       ; pone un limite de 3 posicionamientos en el tablero
jg fill_down_submarine
jle cambiar_si


find_space_submarine_down:      ;Busca un espacio libre hacia abajo en matriz para ubicar el submarino
cmp di, 0
je fill_down_submarine
dec di

add bp, 6
mov al, table[bp]
cmp al, 0
je find_space_submarine_down
jg place_submarine


cambiar_si:
mov si, 0
jmp cambiar_ceros


cambiar_ceros:                  ; Cambia los valores del entero 0 al caracter '0' que se encuentren en la matriz
mov al, table[si]
cmp al, 0
je transformar
cmp si, 36 
je imprimir
inc si  
jne cambiar_ceros


transformar:                    ; Transforma los 0 a '0'
cmp si, 36 
je imprimir

add al, 30h
mov table[si], al
inc si
jmp cambiar_ceros


imprimir:
;;call imprimirMatriz  ;Imprecion del tablero


jmp ingresoCoordenadas




;---------------------------------Ingreso de coordenadas---------------------------------
ingresoCoordenadas:             ;Imprime el mensaje para el ingreso de cordenadas
   
    inc nDisparos               ;Incremento del contador de disparos (Misil a disparar)
    mov ah , 09h
    lea dx , msgMisil
    int 21h                     ;Imprecion del mensaje en msgMisil
                        
    mov ax , 00h
    mov al , nDisparos
    mov bl , 10
    div bl
    mov dx , ax
    
    mov ah , 02h
    add dl , 30h                ;Conversion de la decena de nDisparos a codigo ASCII
    int 21h                     ;Imprecion del la decena de nDisparos
    mov dl , dh
    add dl , 30h                ;Conversion de la unidad de nDisparos a codigo ASCII
    int 21h                     ;Imprecion del la unidade de nDisparos
    
    mov ah , 09h
    lea dx , msgIngreso 
    int 21h                     ;Imprecion del mensaje en msgIngreso 
    
    jmp scanerLetra             ;Salto a scanerLetra (Inicio del ingreso de datos)



scanerLetra:                    ;Extrae una letra entre A-F o a-f, si se ingresa algo incorecto lo borra y vuelve a pedirlo   
    mov ah , 00h
    int 16h                     ;Extrae un caracter del teclado y lo guarda en al
    
    cmp al , 65
    jb scanerLetra              ;Si lo ingresado esta debajo de A(65 ASCII) , salto a scanerLetra (Reingreso de letra)
    cmp al , 70
    jbe mayuscula               ;Si caracter ingresado entre A(65 ASCII)-F(70 ASCII) salto a mayuscula 
     
    cmp al , 97         
    jb scanerLetra              ;Si lo ingresado esta encima de F(70 ASCII) y debajo de a(97 ASCII), salto a scanerLetra (Reingreso de letra)
    cmp al , 102
    jbe minuscula               ;Si caracter ingresado entre a(97 ASCII)-f(102 ASCII) salto a minuscula
    
    
    jmp scanerLetra             ;Si el caracter ingresado no esta entre A-F o a-f, salto a scanerLetra (Reingreso de letra)
    
     

mayuscula:                      ;Convierte caracter guardado en al de A-F a entero de 1-6 
    mov ah , 02h
    mov dl , al
    int 21h                     ;Imprime el caracter guardado en en al
    
    sub al , 64                 ;Conversion a numero
    mov corX ,al                ;Guardado en memoria
    
    jmp scanerNumero            ;Salto a scanerNumero
    
    
minuscula:                      ;Convierte caracter guardado en en al de a-f a entero de 1-6
    mov ah , 02h
    mov dl , al
    int 21h                     ;Imprime el caracter guardado en en al
                            
    sub al , 96                 ;Conversion a entero
    mov corX ,al                ;Guardado en memoria de cordenada en x
    
    jmp scanerNumero            ;scanerNumero
                                

scanerNumero:                   ;Extrae una caracter entre 1-6, si se ingresa algo incorecto lo borra y vuelve a pedirlo
    mov ah , 00h
    int 16h                     ;Extrae un caracter del teclado y lo guarda en al
    
    cmp al , 8         
    je volverLetra              ;Si caracter ingresado es retroseso, salto a volverLetra 
    
    cmp al , 54
    ja  scanerNumero            ;Si caracter ingresado esta encima de 6(54 ASCII) salto a scanerNumero (Reingreso de numero)
    cmp al , 49
    jb  scanerNumero            ;Si caracter ingresado esta debajo de 1(49 ASCII) salto a scanerNumero (Reingreso de numero)
    
    mov ah , 02h
    mov dl , al
    int 21h                     ;Imprime el caracter guardado en en al
    
    sub al , 30h                ;Conversion de caracter en ASCII a numero entero
    mov corY , al               ;Guardado en memoria de cordenada en y
    
    jmp finalisarIngreso        ;Si caracter ingresdo entre 1(49 ASCII)-6(54 ASCII) salto a disparar 



volverLetra:                    ;Retrosede a scanerLetra
    call borrar
    jmp  scanerLetra


volverNumero:                   ;Retrosede a scanerNumero
    call borrar
    jmp  scanerNumero


finalisarIngreso:               ;Finalisa el ingreso de los datos ENTER dispara y retroseso para volver
    mov ah , 00h
    int 16h                     ;Extrae un caracter del teclado y lo guarda en al
    
    cmp al ,13                  ;Al precionar ENTER se dispara
    je  disparar
    
    cmp al , 8         
    je volverNumero             ;Si caracter ingresado es retroseso, salto a volverNumero
    
    jmp finalisarIngreso        ;Si no es ENTER o retroseso se vuelve a pedir por teclado

    
borrar:                         ;Borra un caracter de pantalla
    mov ah , 02h
    mov dl , 8
    int 21h                     ;Retrosede un espacio en la consola
    mov dl , 00h
    int 21h                     ;Imprimer un espacion en blanco
    mov dl , 8
    int 21h                     ;Retrosede un un espacio en la consola
    ret                         ;Retorno a donde borrar fue llamado



;---------------------------------Disparos---------------------------------
disparar:                       ;Revisa el valor de matriz en la cordenas de ingresada (corX,corY) 
    
    mov al , 6
    mov bl ,corY
    dec bl
    mul bl              
    dec al                      ;Los calculos determinana la posicicion del ultimo elemento de la fila anterior (6,corY-1) en la matriz
    
    add al , corX               ;Determina la posicion derminada por (corX, corY) en la matriz
    mov ah , 00h
    mov si , ax                 ;Guarda la posicion derminada por (corX, corY) en la matriz en regitro si 
    mov al ,table[si]           ;Extrae el valor de la matriz en posicion si
    
    cmp al , "0"
    je tiroFallido              ;Si al == "0", el tiro fue al agua, salto a tiroFallido 
    
    cmp al , "1"
    ja tiroExitoso              ;Si al > "1" , el tiro fue a un barco ("S" o "C" o "P"), salto a tiroExitoso 
    je tiroRepetido             ;Si al== "1" , ya se disparo hay tiroRepetido
    

tiroRepetido:                   ;Notifica que ya se disparo hay y "vuelve a cargar el misil"
    dec nDisparos
    mov ah , 09h
    lea dx , msgRepetido
    int 21h                     ;Imprecion del mensaje en msgRepetido
                    
    jmp continuar
 

tiroFallido:                    ;Imprime el mensaje de tiro fallido
    mov ah , 09h
    lea dx , msgFallido
    int 21h                     ;Imprecion del mensaje en msgFallido
    
    jmp continuar 


tiroExitoso:                    ;Imprime el mensaje de tiro exitoso ,cambia el valor en esa cordenada a 1 y reduse la vida del barco al que se disparo
    mov ah , 09h
    lea dx , msgExitoso
    int 21h                     ;Imprecion del mensaje en msgExitoso
    mov al, table[si]
    mov table[si] , "1"         ;Asigna el valor de 1 a la matriz en la posicion si (corX, corY)
                        
                                ;Dependiendo de barco disparado el programa saltara a un procedimeinto diferente  
    cmp al, "C"
    je tiroCrusero              ;Si al == "C", se disparo a un crusero , salto a tiroCrusero 
    
    cmp al, "S"
    je tiroSubmarino            ;Si al == "S", se disparo a un submarino , salto a tiroSubmarino 
    
    cmp al, "P"
    je tiroPortaAviones         ;Si al == "P", se disparo a un porta aviones , salto a tiroPortaAviones


tiroSubmarino:                  ;Reduce vpSubmarino y revisa si el crusero ya ha sido hundido 
    dec vpSubmarino             ;Decremento en uno del vpSubmarino
    
    mov al , vpSubmarino
    cmp al , 00h
    jne continuar               ;si al != 0 , vpSubmarino no es cero , salto a continuar
      
    mov ah , 09h
    lea dx , msgSubmarinoHundido
    int 21h                     ;si al == 0, Imprecion del mensaje en msgSubmarinoHundido
    jmp continuar               ;Salto a continuar


tiroCrusero:                    ;Reduce vpCrucero y revisa si el crusero ya ha sido hundido  
    dec vpCrucero               ;Decremento en uno del vpCrucero
    
    mov al , vpCrucero
    cmp al , 00h        
    jne continuar               ;si al != 0 , vpCrucero no es cero , salto a continuar
      
    mov ah , 09h
    lea dx , msgCruseroHundido
    int 21h                     ;si al == 0 , Imprecion del mensaje en msgCruseroHundido
    jmp continuar               ;Salto a continuar
                        
         
tiroPortaAviones:               ;Reduce vpPortaAviones y revisa si el porta aviones ya ha sido hundido 
    dec vpPortaAviones          ;Decremento en uno del vpPortaAviones
    
    mov al , vpPortaAviones
    cmp al , 00h         
    jne continuar               ;si al != 0 , vpPortaAviones no es cero , salto a continuar
      
    mov ah , 09h
    lea dx , msgPortaAvionesHundido
    int 21h                     ; si al == 0, Imprecion del mensaje en msgPortaAvionesHundido
    jmp continuar



continuar:                      ;Controla si el juego continua o acaba   
    
    call saltoLinea
    
    mov corX , 0
    mov corY , 0
    
    mov dl , vpSubmarino
    add dl , vpCrucero
    add dl , vpPortaAviones
    cmp dl , 0             
    je ganador                  ;Si la suma de los vp de todos los barcos es 0, entonses juego ganado, salto a ganador
                                          
    mov dl , nDisparos
    cmp dl , 20
    jae perdedor                ;Si nDisparos == 20 , entonses juego perdido, salto a perdedor
    jb ingresoCoordenadas       ;Si nDisparos != 20 , quedan misiles disponibles, salto a ingresoCordenadas
                       

saltoLinea:
    mov ah,02h
    mov dl,13
    int 21h                     ;Retorno de carro (regreso al inicio de la linea)
      
    mov dl,10
    int 21h                     ;Salto a nueva linea
    ret
                   
;---------------------------------Juego ganado---------------------------------
ganador:                        ;Imprime los mensajes de ganador y el numero de tiros que se uso para ganar

    mov ah , 09h
    lea dx , msgGanador1
    int 21h                     ;Imprecion del mensaje en msgGanador1
    
    call saltoLinea
    
    mov ah , 09h
    lea dx , msgGanador2
    int 21h                     ;Imprecion del mensaje en msgGanador2
    
    mov ax , 00h
    mov al , nDisparos
    mov bl , 10
    div bl
    mov dx , ax
    
    mov ah , 02h
    add dl , 30h                ;Conversion de la decena de nDisparos a codigo ASCII
    int 21h                     ;Imprecion del la decena de nDisparos
    mov dl , dh
    add dl , 30h                ;Conversion de la unidad de nDisparos a codigo ASCII
    int 21h                     ;Imprecion del la unidad de nDisparos
    

    jmp nuevaPartida



;---------------------------------Juego perdido---------------------------------
perdedor:                       ;Imprime el mensaja de perdedor , el numero de casillas no asertadas y muestra el tablero al jugador
    mov ah , 09h
    lea dx , msgPerdedor1
    int 21h                     ;Imprecion del mensaje en msgPerdedor1
    
    call saltoLinea
    
    mov ah , 09h
    lea dx , msgPerdedor2
    int 21h                     ;Imprecion del mensaje en msgPerdedor2
    
    mov ah , 00h
    mov al , vpSubmarino
    add al , vpCrucero
    add al , vpPortaAviones     ;Suma de la vida de todos los barcos 

    mov bl , 10
    div bl
    mov dx , ax
    
    mov ah , 02h
    add dl , 30h                ;Conversion de la decena de al a codigo ASCII
    int 21h                     ;Imprecion del la decena de al
    mov dl , dh
    add dl , 30h                ;Conversion de la unidad de al a codigo ASCII
    int 21h                     ;Imprecion del la unidad de al

    call saltoLinea
    
    mov ah , 09h
    lea dx , msgPerdedor3
    int 21h                     ;Imprecion del mensaje en msgPerdedor3
    
    call saltoLinea
    
    mov ah , 09h
    lea dx , msgPerdedor4
    int 21h                     ;Imprecion del mensaje en msgPerdedor4
    
    call saltoLinea
    
    mov ah , 09h
    lea dx , msgPerdedor5
    int 21h                     ;Imprecion del mensaje en msgPerdedor5
    
    call saltoLinea
    
    call imprimirMatriz         ;Imprecion del tablero
    
    jmp nuevaPartida            ;Salto a nuevaPartida 



imprimirMatriz:                 ;Imprime el tablero de juego y la informacion de este
    mov ah , 02h
    mov dl , 09
    int 21h
    
    mov ah , 09h
    lea dx , cordenadasX
    int 21h                     ;Imprecion del mensaje en cordenadasX
    
    call saltoLinea
    
    mov dl , 09
    int 21h                     ;Impracion de Tab
    
    mov ah , 09h
    lea dx , borde
    int 21h                     ;Imprecion del borde superior de tablero
    
    call saltoLinea
    
    call saltoLinea
    
    mov ah , 02h   
    mov dl , 09
    int 21h                     ;Imprecion de Tab 
    
    mov dl , 179                ;Imprecion de ascii 179 (Barra vertical)
    int 21h
    
    mov si, 00h                 ;Inicio del indise de la matriz
    mov cx , 00h                ;Inicio del contador de elementos impresos por fila
    mov bl , 00h                ;Inicio del contdor de filas
    
    jmp imprimirFila            ;Salto a imprimir fila


imprimirFila:                   ;Imprime un fila del tablero
    mov ah , 02h
    mov dl , table[si]
    int 21h                     ;Imprime un caracter de la matriz
    
    inc cx                      ;Incremento del contador de elementos por fila 
    inc si                      ;Incremento del indise de la matriz
    
    cmp cx , 6
    je siguienteFila            ;Si cx == 6, ya se han impreso todos los elementos de la fila , salto a siguienteFila
    mov dl , 00h
    int 21h                     ;Imprime un espacio
    jne imprimirFila            ;Si cx != 6, quedan caracteres de la fila por imprimir , salto a imprimirFila


siguienteFila:                  ;Imprime el numero de fila y pasa a imprimir la siguiente fila del tablero
    inc bl
    mov cx , 00h                ;Reinico del contador de elementos por fila  
    
    mov ah , 02h        
    mov dl , 179
    int 21h                     ;Imprecion de ascii 179 (Barra vertical)
    
    mov dl , 00h
    int 21h                     ;Imprime un espacio
    
    mov dl , bl
    add dl , 30h
    int 21h                     ;Imprecion de la fila que acaba de ser impresa (numero en bl) 
    
    call saltoLinea
    
    cmp bl , 6          
    je finImprimirMatriz        ;Si bl == 6, se han impreso todas las filas, salto a finImprimirMatriz
    mov dl , 09
    int 21h
        
    mov dl , 179
    int 21h                     ;Imprecion de ascii 179 (Barra vertical)
    jne imprimirFila            ;Si bl != 6, quedan filas por imprimir, salto a imprimirFila
                            
          
finImprimirMatriz:              ;Concluye la imprecion del tablero y retorna a donde  imprimirMatriz fue llamado

    mov dl , 09
    int 21h                     ;Imprecion de Tab 

    mov ah , 09h
    lea dx , borde
    int 21h                     ;Imprecion del borde superior de tablero
    
    call saltoLinea
    ret 



;---------------------------------Nueva partida---------------------------------


nuevaPartida:                   ;Imprime los mensajes de nueva partida
    
    call saltoLinea
    mov ah , 09h
    lea dx , msgNuevaPartida
    int 21h

    jmp continuarOReiniciar
     
    
continuarOReiniciar:            ;Segun el input sea ESC o ENTER , acaba o continua el programa    
    
    mov ah , 00h
    int 16h  
    
    cmp al , 27
    je salir                    ;De ingresarse ESC el programa acaba 
    
    cmp al , 13
    je reiniciar                ;De ingresarse ENTER el programa continua
    
    jmp continuarOReiniciar
    
    
reiniciar:                      ;Reinicia todas la variable numericas y el tablero a su estado inicial

    mov corX , 0 
    mov corY , 0
    
    mov vpSubmarino , 3
    mov vpCrucero , 4 
    mov vpPortaAviones , 5 
    mov nDisparos , 0
    
    mov si, 00h
    call tableroCeros           ;Reinicio del tablero
    
    jmp generarTablero

tableroCeros:                   ;Retorna el tablero a su estado original (lleno de 0 numero)

    mov table[si], 00h 
    cmp si, 36 
    je finTableroCeros
    inc si
    jne tableroCeros
    
finTableroCeros:                ;Acaba con los ciclos de tableroCeros
ret


salir: ;Cierra el programa 
 
    call saltoLinea
    
    mov ah , 09h
    lea dx , msgFin
    int 21h    
    .exit                       ;Imprecion del mensaje en msgFin

end
