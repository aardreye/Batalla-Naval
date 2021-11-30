;Gabriel Alexander Maldonado Rodriguez
;Aaron Reyes 


.model small
.data

;----------Variables----------
corX db 0       ;cordenada de las colubnas para el disparo
corY db 0       ;cordenada de las filas para el disparo 
nDisparos db 0  ;Numero de disparos

;vp de los barcos
vpSubmarino db 3
vpCrucero db 4 
vpPortaAviones db 5

;----------Areglos----------
           ;ABCDEF
x_random db ?       ;coordenada de las columnas para el disparo
y_random db ?       ;coordenada de las filas para el disparo 

table   db 6 dup(0) ;1
        db 6 dup(0) ;2
        db 6 dup(0) ;3
        db 6 dup(0) ;4
        db 6 dup(0) ;5
        db 6 dup(0) ;6 

cordenadasX db " A B C D E F $"
borde db "_____________$"

;----------Texto---------- 



;Mesajes de ingreso 
msgInicio db "          Bienvenido a BATALLA NAVAL $"
msgMisil db "Misil $"
msgIngreso db ",ingrese la celda a atacar: $"

msgNuevaPartida db "Ingrese ENTER para nueva partida y ESC para acabar el programa $"

;Notificasiones de disparo
msgExitoso db "..................Impacto confirmado$"   
msgFallido db "..................Sin impacto$"
msgRepetido db "..................Ya disparo hay, no desperdicie misiles!$"

;Notificasiones de hundimiento
msgSubmarinoHundido db ", submarino hundido.$"
msgCruseroHundido db ", crusero hundido.$"
msgPortaAvionesHundido db ", porta avione hundido.$"

;Mensajes de final de juego:
msgGanador1 db "Felisitaciones ha hundido todos los barcos. Ha ganado!! $"
msgGanador2 db "Numero de total de tiros: $"

msgPerdedor1 db "No ha hundido todos lo barcos. Ha perdido. $"
msgPerdedor2 db "Objetivos restantes por disparar: $"
msgPerdedor3 db "Imprimiendo tablero $"
msgPerdedor4 db "S = Submarino      C = Crusero     P = Portaviones $"
msgPerdedor5 db "0 = Agua       1 = Disparos Asertados  $"

.code
.start

;---------------------------------Inicio del juego-----------------------------------
iniciar:
    mov ah , 09h
    lea dx , msgInicio
    int 21h                     ;Imprecion del mensaje en msgInicio 
    
    call saltoLinea
     
    call imprimirMatriz
    
    call saltoLinea             ;Salto de liena
    jmp place_p_aircraft       

;---------------------------------Generacion de Tablero---------------------------------

 ;COLOCA UN PORTAVIONES DE FORMA ALEATORIA EN EL TABLERO
place_p_aircraft: ; 50h >> 5 
call coordinate_random
call get_coordinate  

mov bl, x_random
mov cl, 6

cmp bl, 4
jg fill_left_p_aircraft

cmp bl, 3
jl fill_right_p_aircraft

mov bl, y_random

cmp bl, 4
jg fill_up_p_aircraft

cmp bl, 3
jl fill_down_p_aircraft

cmp bl, 4
je place_p_aircraft

cmp bl, 3                          ;si entra en el punto critico, volver a generar una coordenada random
je place_p_aircraft


;COLOCA UN CRUCERO DE FORMA ALEATORIA EN EL TABLERO
place_cruise: ; 43h >> 4
call coordinate_random          ;genera una coordenada random
call get_coordinate             ;ontiene el valor en matriz de la coordenada random
call empty_coordinate_cruise    ;se asegura que la coordenada random este vacia

mov bl, x_random
mov cl, 6

cmp bl, 4
jge find_space_cruise_left     ;si la coordenada x >= 4 coloca un crucero a hacia la derecha 

cmp bl, 3
jle find_space_cruise_right      ;si la coordenada x <= 3 coloca un crucero a hacia la derecha 


;COLOCAR UN SUBMARINO DE FORMA ALEATORIA EN EL TABLERO
place_submarine: ; 53h >> 3
call coordinate_random
call get_coordinate 
call empty_coordinate_submarine 

mov bl, y_random
mov cl, 6

cmp bl, 4
jge find_space_submarine_up

cmp bl, 3
jle find_space_submarine_down


;COLOCAR UN PORATAAVIONES DE DERECHA A IZQUIERDA
fill_left_p_aircraft:
mov table[si], 50h   ;Asigna el valor de 1 a la matriz en la posicion si
dec si
dec cl      
cmp cl, 1
jg fill_left_p_aircraft
jle place_cruise  


;COLOCAR UN PORATAAVIONES DE IZQUIERDA A DERECHA
fill_right_p_aircraft:
mov table[si], 50h   ;Asigna el valor de 1 a la matriz en la posicion si
inc si
dec cl      
cmp cl, 1
jg fill_right_p_aircraft
jle place_cruise 


;COLOCAR UN PORATAAVIONES DE ABAJO HACIA ARRIBA
fill_up_p_aircraft:
mov table[si], 50h   ;Asigna el valor de 1 a la matriz en la posicion si
sub si, 6
dec cl      
cmp cl, 1
jg fill_up_p_aircraft
jle place_cruise


;COLOCAR UN PORATAAVIONES DE ARRIBA HACIA ABAJO
fill_down_p_aircraft:
mov table[si], 50h   ;Asigna el valor de 1 a la matriz en la posicion si
add si, 6
dec cl      
cmp cl, 1
jg fill_down_p_aircraft
jle place_cruise


;GENERAR UN NUMERO RANDOM EN EL RANGO DE 1 A 6   
number_random:          
mov ah, 00h         ; obtiene la hora del sistema
int 1Ah             ; cx: dx = numero de tics del reloj desde la medianoche

mov ax, dx          ; ahora ax contiene  el numero de tics
xor dx, dx          ; se borra el registro dx
mov cx, 6           ; asignamos el decimal 6 a cx
div cx              ; obtenemos un resto en el rango de 1 a 6 y se almacena en dx    
add dl, 1         ; agregamos ASCII '1'(49) a dx para ponerlos en ASCII '1' a '6'
ret


;GENERAR UNA COORDENADA RANDOM EN EL RANGO DE 1 A 6

coordinate_random:
call number_random
mov x_random, dl    
call number_random
mov y_random, dl
ret 


;OBTENER EL VALOR DE LA COORDENADA RANDOM EN AL
get_coordinate:
mov al , 6
mov bl , y_random
dec bl
mul bl              
dec al              

add al , x_random   ; Posicionamiento aleatorio de "x"
mov ah , 00h
mov si , ax         ; Guarda la coordenada aleatoria (x,y) en el registro si 
mov al , table[si]  ; Extrae el valor de la matriz en posicion almacenada en registro si
ret


;VERIFICAR QUE LA COORDENADA PARA EL CRUCERO ESTE VACIA 
empty_coordinate_cruise:
cmp al, 0
mov di, 3
mov bp, si
jg place_cruise         ;si no esta vacio generar otra coordenada
ret

;VERIFICAR QUE LA COORDENADA PARA EL SUBMARINO ESTE VACIA
empty_coordinate_submarine:
cmp al, 0
mov di, 2
mov bp, si
jg place_submarine         ;si no esta vacio generar otra coordenada
ret

;COLOCAR UN CRUCERO DE DERECHA A IZQUIERDA
fill_left_cruise:
mov table[si], 43h        ;Asigna el valor de 1 a la matriz en la posicion si
dec si              
dec cl      
cmp cl, 2               ; pone un limite de 4 posicionamientos en el tablero
jg fill_left_cruise
jle place_submarine     


find_space_cruise_left:
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
mov table[si], 43h        ;Asigna el valor de 1 a la matriz en la posicion si
inc si
dec cl      
cmp cl, 2               ; pone un limite de 4 posicionamientos en el tablero
jg fill_right_cruise
jle place_submarine


find_space_cruise_right:
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
mov table[si], 53h   ;Asigna el valor de 1 a la matriz en la posicion si
sub si, 6
dec cl      
cmp cl, 3
jg fill_up_submarine
jle cambiar_si
 
 
find_space_submarine_up:
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
mov table[si], 53h   ;Asigna el valor de 1 a la matriz en la posicion si
add si, 6
dec cl      
cmp cl, 3
jg fill_down_submarine
jle cambiar_si


find_space_submarine_down:
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


cambiar_ceros:
mov al, table[si]
cmp al, 0
je transformar
cmp si, 36 
je imprimir
inc si  
jne cambiar_ceros


transformar:
cmp si, 36 
je imprimir

add al, 30h
mov table[si], al
inc si
jmp cambiar_ceros


imprimir:
;;call imprimirMatriz  ;Imprecion del tablero


jmp ingresoCordenadas




;---------------------------------Ingreso de cordenadas---------------------------------
ingresoCordenadas:  ;Imprime el mensaje para el ingreso de cordenadas
   
    inc nDisparos       ;Incremento del contador de disparos (Misil a disparar)
    mov ah , 09h
    lea dx , msgMisil
    int 21h             ;Imprecion del mensaje en msgMisil
                        
    mov ax , 00h
    mov al , nDisparos
    mov bl , 10
    div bl
    mov dx , ax
    
    mov ah , 02h
    add dl , 30h        ;Conversion de la decena de nDisparos a codigo ASCII
    int 21h             ;Imprecion del la decena de nDisparos
    mov dl , dh
    add dl , 30h        ;Conversion de la unidad de nDisparos a codigo ASCII
    int 21h             ;Imprecion del la unidade de nDisparos
    
    mov ah , 09h
    lea dx , msgIngreso 
    int 21h             ;Imprecion del mensaje en msgIngreso 
    
    jmp scanerLetra     ;Salto a scanerLetra (Inicio del ingreso de datos)



scanerLetra:            ;Extrae una letra entre A-F o a-f, si se ingresa algo incorecto lo borra y vuelve a pedirlo   
    mov ah , 00h
    int 16h             ;Extrae un caracter del teclado y lo guarda en al
    
    cmp al , 65
    jb scanerLetra      ;Si lo ingresado esta debajo de A(65 ASCII) , salto a scanerLetra (Reingreso de letra)
    cmp al , 70
    jbe mayuscula       ;Si caracter ingresado entre A(65 ASCII)-F(70 ASCII) salto a mayuscula 
     
    cmp al , 97         
    jb scanerLetra      ;Si lo ingresado esta encima de F(70 ASCII) y debajo de a(97 ASCII), salto a scanerLetra (Reingreso de letra)
    cmp al , 102
    jbe minuscula       ;Si caracter ingresado entre a(97 ASCII)-f(102 ASCII) salto a minuscula
    
    
    jmp scanerLetra     ;Si el caracter ingresado no esta entre A-F o a-f, salto a scanerLetra (Reingreso de letra)
    
     

mayuscula:          ;Convierte caracter guardado en al de A-F a entero de 1-6 
    mov ah , 02h
    mov dl , al
    int 21h             ;Imprime el caracter guardado en en al
    
    sub al , 64         ;Conversion a numero
    mov corX ,al        ;Guardado en memoria
    
    jmp scanerNumero    ;Salto a scanerNumero
    
    
minuscula:          ;Convierte caracter guardado en en al de a-f a entero de 1-6
    mov ah , 02h
    mov dl , al
    int 21h             ;Imprime el caracter guardado en en al
    
    sub al , 96         ;Conversion a entero
    mov corX ,al        ;Guardado en memoria de cordenada en x
    
    jmp scanerNumero    ;scanerNumero
    

scanerNumero:       ;Extrae una caracter entre 1-6, si se ingresa algo incorecto lo borra y vuelve a pedirlo
    mov ah , 00h
    int 16h             ;Extrae un caracter del teclado y lo guarda en al
    
    cmp al , 8         
    je volverLetra      ;Si caracter ingresado es retroseso, salto a volverLetra 
    
    cmp al , 54
    ja  scanerNumero    ;Si caracter ingresado esta encima de 6(54 ASCII) salto a scanerNumero (Reingreso de numero)
    cmp al , 49
    jb  scanerNumero    ;Si caracter ingresado esta debajo de 1(49 ASCII) salto a scanerNumero (Reingreso de numero)
    
    mov ah , 02h
    mov dl , al
    int 21h             ;Imprime el caracter guardado en en al
    
    sub al , 30h        ;Conversion de caracter en ASCII a numero entero
    mov corY , al       ;Guardado en memoria de cordenada en y
    
    jmp finalisarIngreso        ;Si caracter ingresdo entre 1(49 ASCII)-6(54 ASCII) salto a disparar 



volverLetra:            ;Retrosede a scanerLetra
    call borrar
    jmp  scanerLetra


volverNumero:           ;Retrosede a scanerNumero
    call borrar
    jmp  scanerNumero


finalisarIngreso:       ;Finalisa el ingreso de los datos ENTER dispara y retroseso para volver
    mov ah , 00h
    int 16h             ;Extrae un caracter del teclado y lo guarda en al
    
    cmp al ,13          ;Al precionar ENTER se dispara
    je  disparar
    
    cmp al , 8         
    je volverNumero      ;Si caracter ingresado es retroseso, salto a volverNumero
    
    jmp finalisarIngreso ;Si no es ENTER o retroseso se vuelve a pedir por teclado

    
borrar:             ;Borra un caracter de pantalla
    mov ah , 02h
    mov dl , 8
    int 21h             ;Retrosede un espacio en la consola
    mov dl , 00h
    int 21h             ;Imprimer un espacion en blanco
    mov dl , 8
    int 21h             ;Retrosede un un espacio en la consola
    ret                 ;Retorno a donde borrar fue llamado



;---------------------------------Disparos---------------------------------
disparar:           ;Revisa el valor de matriz en la cordenas de ingresada (corX,corY) 
    
    mov al , 6
    mov bl ,corY
    dec bl
    mul bl              
    dec al              ;Los calculos determinana la posicicion del ultimo elemento de la fila anterior (6,corY-1) en la matriz
    
    add al , corX       ;Determina la posicion derminada por (corX, corY) en la matriz
    mov ah , 00h
    mov si , ax         ;Guarda la posicion derminada por (corX, corY) en la matriz en regitro si 
    mov al ,table[si]   ;Extrae el valor de la matriz en posicion si
    
    cmp al , "0"
    je tiroFallido     ;Si al == "0", el tiro fue al agua, salto a tiroFallido 
    
    cmp al , "1"
    ja tiroExitoso     ;Si al > "1" , el tiro fue a un barco ("S" o "C" o "P"), salto a tiroExitoso 
    je tiroRepetido    ;Si al== "1" , ya se disparo hay tiroRepetido
    

tiroRepetido:          ;Notifica que ya se disparo hay y "vuelve a cargar el misil"
    dec nDisparos
    mov ah , 09h
    lea dx , msgRepetido
    int 21h             ;Imprecion del mensaje en msgRepetido
                    
    jmp continuar
 

tiroFallido:           ;Imprime el mensaje de tiro fallido
    mov ah , 09h
    lea dx , msgFallido
    int 21h             ;Imprecion del mensaje en msgFallido
    
    jmp continuar 


tiroExitoso:       ;Imprime el mensaje de tiro exitoso ,cambia el valor en esa cordenada a 1 y reduse la vida del barco al que se disparo
    mov ah , 09h
    lea dx , msgExitoso
    int 21h             ;Imprecion del mensaje en msgExitoso
    mov al, table[si]
    mov table[si] , "1"  ;Asigna el valor de 1 a la matriz en la posicion si (corX, corY)
                        
                        ;Dependiendo de barco disparado el programa saltara a un procedimeinto diferente  
    cmp al, "C"
    je tiroCrusero      ;Si al == "C", se disparo a un crusero , salto a tiroCrusero 
    
    cmp al, "S"
    je tiroSubmarino    ;Si al == "S", se disparo a un submarino , salto a tiroSubmarino 
    
    cmp al, "P"
    je tiroPortaAviones ;Si al == "P", se disparo a un porta aviones , salto a tiroPortaAviones


tiroSubmarino:        ;Reduce vpSubmarino y revisa si el crusero ya ha sido hundido 
    dec vpSubmarino      ;Decremento en uno del vpSubmarino
    
    mov al , vpSubmarino
    cmp al , 00h
    jne continuar        ;si al != 0 , vpSubmarino no es cero , salto a continuar
      
    mov ah , 09h
    lea dx , msgSubmarinoHundido
    int 21h             ;si al == 0, Imprecion del mensaje en msgSubmarinoHundido
    jmp continuar       ;Salto a continuar


tiroCrusero:        ;Reduce vpCrucero y revisa si el crusero ya ha sido hundido  
    dec vpCrucero       ;Decremento en uno del vpCrucero
    
    mov al , vpCrucero
    cmp al , 00h        
    jne continuar       ;si al != 0 , vpCrucero no es cero , salto a continuar
      
    mov ah , 09h
    lea dx , msgCruseroHundido
    int 21h            ;si al == 0 , Imprecion del mensaje en msgCruseroHundido
    jmp continuar      ;Salto a continuar
         
         
tiroPortaAviones:        ;Reduce vpPortaAviones y revisa si el porta aviones ya ha sido hundido 
    dec vpPortaAviones   ;Decremento en uno del vpPortaAviones
    
    mov al , vpPortaAviones
    cmp al , 00h         
    jne continuar        ;si al != 0 , vpPortaAviones no es cero , salto a continuar
      
    mov ah , 09h
    lea dx , msgPortaAvionesHundido
    int 21h            ; si al == 0, Imprecion del mensaje en msgPortaAvionesHundido
    jmp continuar



continuar:         ;Controla si el juego continua o acaba   
    
    call saltoLinea
    
    mov corX , 0
    mov corY , 0
    
    mov dl , vpSubmarino
    add dl , vpCrucero
    add dl , vpPortaAviones
    cmp dl , 0             
    je ganador             ;Si la suma de los vp de todos los barcos es 0, entonses juego ganado, salto a ganador
                                         
    mov dl , nDisparos
    cmp dl , 20
    jae perdedor           ;Si nDisparos == 20 , entonses juego perdido, salto a perdedor
    jb ingresoCordenadas   ;Si nDisparos != 20 , quedan misiles disponibles, salto a ingresoCordenadas
                       

saltoLinea:
    mov ah,02h
    mov dl,13
    int 21h            ;Retorno de carro (regreso al inicio de la linea)
      
    mov dl,10
    int 21h            ;Salto a nueva linea
    ret
                   
;---------------------------------Juego ganado---------------------------------
ganador:                 ;Imprime los mensajes de ganador y el numero de tiros que se uso para ganar

    mov ah , 09h
    lea dx , msgGanador1
    int 21h              ;Imprecion del mensaje en msgGanador1
    
    call saltoLinea
    
    mov ah , 09h
    lea dx , msgGanador2
    int 21h              ;Imprecion del mensaje en msgGanador2
    
    mov ax , 00h
    mov al , nDisparos
    mov bl , 10
    div bl
    mov dx , ax
    
    mov ah , 02h
    add dl , 30h        ;Conversion de la decena de nDisparos a codigo ASCII
    int 21h             ;Imprecion del la decena de nDisparos
    mov dl , dh
    add dl , 30h        ;Conversion de la unidad de nDisparos a codigo ASCII
    int 21h             ;Imprecion del la unidad de nDisparos
    

    jmp nuevaPartida



;---------------------------------Juego perdido---------------------------------
perdedor:              ;Imprime el mensaja de perdedor , el numero de casillas no asertadas y muestra el tablero al jugador
    mov ah , 09h
    lea dx , msgPerdedor1
    int 21h            ;Imprecion del mensaje en msgPerdedor1
    
    call saltoLinea
    
    mov ah , 09h
    lea dx , msgPerdedor2
    int 21h              ;Imprecion del mensaje en msgPerdedor2
    
    mov ah , 00h
    mov al , vpSubmarino
    add al , vpCrucero
    add al , vpPortaAviones ;Suma de la vida de todos los barcos 

    mov bl , 10
    div bl
    mov dx , ax
    
    mov ah , 02h
    add dl , 30h        ;Conversion de la decena de al a codigo ASCII
    int 21h             ;Imprecion del la decena de al
    mov dl , dh
    add dl , 30h        ;Conversion de la unidad de al a codigo ASCII
    int 21h             ;Imprecion del la unidad de al

    call saltoLinea
    
    mov ah , 09h
    lea dx , msgPerdedor3
    int 21h             ;Imprecion del mensaje en msgPerdedor3
    
    call saltoLinea
    
    mov ah , 09h
    lea dx , msgPerdedor4
    int 21h             ;Imprecion del mensaje en msgPerdedor4
    
    call saltoLinea
    
    mov ah , 09h
    lea dx , msgPerdedor5
    int 21h            ;Imprecion del mensaje en msgPerdedor5
    
    call saltoLinea
    
    call imprimirMatriz  ;Imprecion del tablero
    
    jmp nuevaPartida     ;Salto a nuevaPartida 



imprimirMatriz:              ;Imprime el tablero de juego y la informacion de este
    mov ah , 02h
    mov dl , 09
    int 21h
    
    mov ah , 09h
    lea dx , cordenadasX
    int 21h                  ;Imprecion del mensaje en cordenadasX
    
    call saltoLinea
    
    mov dl , 09
    int 21h                  ;Impracion de Tab
    
    mov ah , 09h
    lea dx , borde
    int 21h                 ;Imprecion del borde superior de tablero
    
    call saltoLinea
    
    call saltoLinea
    
    mov ah , 02h   
    mov dl , 09
    int 21h                 ;Imprecion de Tab 
    
    mov dl , 179            ;Imprecion de ascii 179 (Barra vertical)
    int 21h
    
    mov si, 00h             ;Inicio del indise de la matriz
    mov cx , 00h            ;Inicio del contador de elementos impresos por fila
    mov bl , 00h            ;Inicio del contdor de filas
    
    jmp imprimirFila        ;Salto a imprimir fila


imprimirFila:               ;Imprime un fila del tablero
    mov ah , 02h
    mov dl , table[si]
    int 21h              ;Imprime un caracter de la matriz
    
    inc cx               ;Incremento del contador de elementos por fila 
    inc si               ;Incremento del indise de la matriz
    
    cmp cx , 6
    je siguienteFila     ;Si cx == 6, ya se han impreso todos los elementos de la fila , salto a siguienteFila
    mov dl , 00h
    int 21h              ;Imprime un espacio
    jne imprimirFila     ;Si cx != 6, quedan caracteres de la fila por imprimir , salto a imprimirFila


siguienteFila:       ;Imprime el numero de fila y pasa a imprimir la siguiente fila del tablero
    inc bl
    mov cx , 00h        ;Reinico del contador de elementos por fila  
    
    mov ah , 02h        
    mov dl , 179
    int 21h             ;Imprecion de ascii 179 (Barra vertical)
    
    mov dl , 00h
    int 21h             ;Imprime un espacio
    
    mov dl , bl
    add dl , 30h
    int 21h             ;Imprecion de la fila que acaba de ser impresa (numero en bl) 
    
    call saltoLinea
    
    cmp bl , 6          
    je finImprimirMatriz ;Si bl == 6, se han impreso todas las filas, salto a finImprimirMatriz
    mov dl , 09
    int 21h
        
    mov dl , 179
    int 21h              ;Imprecion de ascii 179 (Barra vertical)
    jne imprimirFila     ;Si bl != 6, quedan filas por imprimir, salto a imprimirFila
          
          
finImprimirMatriz:        ;Concluye la imprecion del tablero y retorna a donde  imprimirMatriz fue llamado

    mov dl , 09
    int 21h               ;Imprecion de Tab 

    mov ah , 09h
    lea dx , borde
    int 21h               ;Imprecion del borde superior de tablero
    
    call saltoLinea
    ret 



;---------------------------------Nueva partida---------------------------------


nuevaPartida:                  ;Imprime los mensajes de nueva partida
    
    call saltoLinea
    mov ah , 09h
    lea dx , msgNuevaPartida
    int 21h

    jmp continuarOReiniciar
     
    
continuarOReiniciar:            ;Segun el input sea ESC o ENTER , acaba o continua el programa    
    
    mov ah , 00h
    int 16h  
    
    cmp al , 27
    je salir         ;De ingresarse ESC el programa acaba 
    
    cmp al , 13
    je reiniciar     ;De ingresarse ENTER el programa continua
    
    jmp ingresoCordenadas
    
    
reiniciar:                    ;Reinicia todas la variable numericas y el tablero a su estado inicial

    mov corX , 0 
    mov corY , 0
    
    mov vpSubmarino , 3
    mov vpCrucero , 4 
    mov vpPortaAviones , 5 
    mov nDisparos , 0
    
    mov si, 00h
    call tableroCeros 
    
    jmp iniciar

tableroCeros: 

    mov table[si], 00h 
    cmp si, 36 
    je finTableroCeros
    inc si
    jne tableroCeros
    
finTableroCeros:
ret


salir: ;Cerrar programa 
.exit
end