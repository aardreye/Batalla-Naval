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
array   db "00SSS0" ;1
        db "0C000P" ;2
        db "0C000P" ;3
        db "0C000P" ;4
        db "0C000P" ;5
        db "00000P" ;6



;----------Texto----------
;Mesajes de ingreso
msgMisil db "Misil $"
msgIngreso db ",ingrese la celda a atacar: $"

;Notificasiones de disparo
msgExitoso db "..................Impacto confirmado$"   
msgFallido db "..................Sin impacto$"
msgRepetido db "..................Ya disparo hay, no desperdicie misiles!$"

;Notificasiones de hundimiento
msgSubmarinoHundido db ", submarino hundido.$"
msgCruseroHundido db ", crusero hundido.$"
msgPortaAvionesHundido db ", porta avione hundido.$"



.code
.start

;---------------------------------Generacion de Tablero---------------------------------






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
    call borrar         ;Borra el ultimo caracter en pantalla
      
    mov ah , 01h
    int 21h             ;Extrae un caracter del teclado y lo guarda en al
    
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
    sub al , 64         ;Conversion a numero
    mov corX ,al        ;Guardado en memoria
    mov ah , 02h
    mov dl , 00h
    int 21h             ;Imprime un espacio para evitar que la letra se borre al entrar en scanerNumero
    jmp scanerNumero    ;Salto a scanerNumero
    
    
minuscula:          ;Convierte caracter guardado en en al de a-f a entero de 1-6
    sub al , 96         ;Conversion a entero
    mov corX ,al        ;Guardado en memoria de cordenada en x
    mov ah , 02h
    mov dl , 00h
    int 21h             ;Imprime un espacio para evitar que la letra se borre al entrar en scanerNumero
    jmp scanerNumero    ;scanerNumero
    

scanerNumero:       ;Extrae una caracter entre 1-6, si se ingresa algo incorecto lo borra y vuelve a pedirlo
    call borrar         ;Borra el ultimo caracter en pantalla
    
    mov ah , 01h
    int 21h             ;Extrae un caracter del teclado y lo guarda en al
    
    cmp al , 54
    ja  scanerNumero    ;Si caracter ingresado esta encima de 6(54 ASCII) salto a scanerNumero (Reingreso de numero)
    cmp al , 49
    jb  scanerNumero    ;Si caracter ingresado esta debajo de 1(49 ASCII) salto a scanerNumero (Reingreso de numero)
    
    sub al , 30h        ;Conversion de caracter en ASCII a numero entero
    mov corY , al       ;Guardado en memoria de cordenada en y
    
    jmp disparar        ;Si caracter ingresdo entre 1(49 ASCII)-6(54 ASCII) salto a disparar 

    
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
    mov si , ax         ;Guarde la posicion derminada por (corX, corY) en la matriz en regitro si 
    mov al ,array[si]   ;Extrae el valor de la matriz en posicion si
    
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


tiroExitoso:       ;Imprime el mensaje de tiro exitoso ,cambia el valor en esa cordenada a 1 y reduse la vidad del barco al que se disparo
    mov ah , 09h
    lea dx , msgExitoso
    int 21h             ;Imprecion del mensaje en msgExitoso
    mov al, array[si]
    mov array[si] , "1"  ;Asigna el valor de 1 a la matriz en la posicion si (corX, corY)
                        
                        ;Dependiendo de barco disparado el programa saltara a un procedimeinto diferente  
    cmp al, "C"
    je tiroCrusero      ;Si al == "C", se disparo a un crusero , salto a tiroCrusero 
    
    cmp al, "S"
    je tiroSubmarino    ;Si al == "S", se disparo a un submarino , salto a tiroSubmarino 
    
    cmp al, "P"
    je tiroPortaAviones ;Si al == "P", se disparo a un porta aviones , salto a tiroPortaAviones


tiroSubmarino:        ;Reduce vpSubmarino y revisa si el crusero ya sido hundido 
    dec vpSubmarino      ;Decremento en uno del vpSubmarino
    mov al , vpSubmarino
    
    cmp al , 00h
    jne continuar        ;si al != 0 , vpSubmarino no es cero , salto a continuar
      
    mov ah , 09h
    lea dx , msgSubmarinoHundido
    int 21h             ;si al == 0, Imprecion del mensaje en msgSubmarinoHundido
    jmp continuar


tiroCrusero:        ;Reduce vpCrucero y revisa si el crusero ya sido hundido  
    dec vpCrucero       ;Decremento en uno del vpCrucero
    mov al , vpCrucero
    
    cmp al , 00h        
    jne continuar       ;si al != 0 , vpCrucero no es cero , salto a continuar
      
    mov ah , 09h
    lea dx , msgCruseroHundido
    int 21h            ;si al == 0 , Imprecion del mensaje en msgCruseroHundido
    jmp continuar
         
         
tiroPortaAviones:        ;Reduce vpPortaAviones y revisa si el crusero ya sido hundido 
    dec vpPortaAviones   ;Decremento en uno del vpPortaAviones
    mov al , vpPortaAviones
    
    cmp al , 00h         
    jne continuar        ;si al != 0 , vpPortaAviones no es cero , salto a continuar
      
    mov ah , 09h
    lea dx , msgPortaAvionesHundido
    int 21h            ; si al == 0, Imprecion del mensaje en msgPortaAvionesHundido
    jmp continuar



continuar:         ;Controla si el juego continua o acaba   
    mov ah,02h
    mov dl,13
    int 21h            ;Retorno de carro (regreso al inicio de la linea)
      
    mov dl,10
    int 21h            ;Salto a nueva linea
    
    mov dl , vpSubmarino
    add dl , vpCrucero
    add dl , vpPortaAviones
    cmp dl , 0             
    je ganador             ;Si la suma de los vp de todos los barcos es 0, entonses juego ganado, salto a ganador
                                         
    mov dl , nDisparos
    cmp dl , 20
    jae perdedor           ;Si nDisparos == 20 , entonses juego perdido, salto a perdedor
    jb ingresoCordenadas   ;Si nDisparos != 20 , quedan misiles disponibles, salto a ingresoCordenadas
                       
                   
;---------------------------------Juego ganado---------------------------------
ganador:
jmp salir



;---------------------------------Juego perdido---------------------------------
perdedor:
jmp salir 



;---------------------------------Nueva partida---------------------------------




salir: ;Cerrar programa 
.exit
end