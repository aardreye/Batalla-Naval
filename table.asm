.model small
.data

x_random db ?       ;coordenada de las columnas para el disparo
y_random db ?       ;coordenada de las filas para el disparo 

table   db 6 dup(0) ;1
        db 6 dup(0) ;2
        db 6 dup(0) ;3
        db 6 dup(0) ;4
        db 6 dup(0) ;5
        db 6 dup(0) ;6

.code
.start

;GENERADOR DEL TABLERO DE JUEGO DE FORMA ALEATORIA

matrix_generator:
;generar coordenada
call place_p_aircraft
;call empty_space_p_aircraft
;generar coordenada
;call empty_coordinate


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
je salir
inc si  
jne cambiar_ceros


transformar:
cmp si, 36 
je salir

add al, 30h
mov table[si], al
inc si
jmp cambiar_ceros


salir: ;Cerrar programa 
.exit
end