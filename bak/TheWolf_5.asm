; **************************************************************************
; *   Aggiunta una minima gestione del punteggio                           *
; *   stabilizzazione del gioco                                            *
; ************************************************************************** 






*=$0801 ; 10 SYS (2064)

        byte $0E, $08, $0A, $00, $9E, $20, $28, $32
        byte $30, $36, $34, $29, $00, $00, $00



        jsr ClearScreen                         ; esegue la cancellazione dello schermo
        jsr SetupColorSprite0                   ; definisce i colori per lo sprite 0 (WOLF)
        jsr EnableMulticolor                    ; abilita il multicolor per gli sprite
        jsr EnableSprite                        ; abilita gli sprite
        jsr SetPointerDataSprites               ; 
        jsr SetDefaultPositionSprite            ; setta la posizione di default dello sprite 0
        jsr SetPlayingField                     ; setta i colori del campo di gioco
        jsr DrawText                            ; scrive il testo 
        jsr MakeMap                             ; disegna la mappa sullo schermo





        sei
loop    

        jsr PlayerControl                       ; Gestione dei movimenti del JOY per loop
                                                ; sprite 0 (wolf).

        
        jsr CheckPlayerCollison                 ; Verifica se si presenta una collisione
                                                ; tra lo sprite 0 (wolf) e uno delgli   
                                                ; altri sprite.


        jsr CheckSpriteCollideChar

        jsr WaitRaster                          ; attende l'arrivo della raster prima di
                                                ; continuare il loop del gioco.


        lda REFRESH_BALLONS
        cmp #$FF
        bne continue

        lda #%00011111        
        sta VIC_SPRITE_ENABLE_REGISTER

        jsr Ballon
        lda #$0
        sta REFRESH_BALLONS

continue
        inc REFRESH_BALLONS


        
        lda SCORE   
        cmp #58
        bne NoResetScore
        lda #48
        sta SCORE

NoResetScore
        sta $420                                ; Scrive il punteggio a video


        jmp loop


;===============================================================================
CheckPlayerCollison

        lda $D01E

        cmp #3                                  ; 00000011
        bne NoCollideSprite1_2

        lda #$86
        sta $07f9

        lda VIC_SPRITE_ENABLE_REGISTER
        and #%11111101
        sta VIC_SPRITE_ENABLE_REGISTER      

        lda SCORE                               ; Verifica che lo score non 
        cmp #48                                 ; assuma mai volori inferiori
        beq NoCollideSprite1_2                  ; allo 0 (48)
        dec SCORE 
       
        jmp ExitCollide

NoCollideSprite1_2
        CMP #5                                  ; 00000101
        BNE NoCollideSprite3_1

        lda #$86
        sta $07fA

        lda VIC_SPRITE_ENABLE_REGISTER
        and #%11111011
        sta VIC_SPRITE_ENABLE_REGISTER 

        inc SCORE                               ; Incrementa lo score        
        
        jmp ExitCollide

NoCollideSprite3_1
        CMP #09                                 ; 0001001
        BNE NoCollideSprite4_1

 
        lda #$86
        sta $07fB

        lda VIC_SPRITE_ENABLE_REGISTER
        and #%11110111
        sta VIC_SPRITE_ENABLE_REGISTER 

        inc SCORE                               ; Incrementa lo score

        jmp ExitCollide

NoCollideSprite4_1

        CMP #17                                 ; 00010001
        BNE NoCollideSprite5_1

        lda #$86
        sta $07fc

        lda VIC_SPRITE_ENABLE_REGISTER
        and #%11101111
        sta VIC_SPRITE_ENABLE_REGISTER

        inc SCORE                               ; Incrementa lo score

NoCollideSprite5_1

ExitCollide

        
       
        rts


;===============================================================================
Ballon

        LDX TEMP
        cpx #9
        bne BallonContinue
        
        ldx #0
        stx TEMP

BallonContinue
 

        ; prova posizionamento secondo sprite
        lda SPRITE2_BALLONS_POSX,x
        sta $d002
        lda SPRITE2_BALLONS_POSY,x
        sta $d003
        lda #$89        ; palloncino marrone
        sta $07f9

        ; prova posizionamento terzo sprite

        lda SPRITE3_BALLONS_POSX,x
        sta $d004
        lda SPRITE3_BALLONS_POSY,x
        sta $d005
        lda #$89        ; palloncino marrone
        sta $07fa


        lda SPRITE4_BALLONS_POSY,x
        sta $d006
        lda SPRITE4_BALLONS_POSY,x        
        sta $d007
        lda #$89        ; palloncino marrone
        sta $07fb


        inc TEMP

        rts


;===============================================================
; Scrive un messaggio a video
drawText
        ldx #$00                        ; Puntatore al carattere da leggere

loopText 
        lda punteggio,x                    ; Prende il carattere puntato dalla
                                        ; dalla stringa di testo
        cmp #$0                         ; Controlla che il byte letto sia il
        beq done                        ; termonatore di stringa
        

outchar
        and #$3f                        ; correction because for poke A is 1 and not 65.
        sta SCREENMEM,x                   ; store character directly in screen memory

        inx                             ; Aggiorna il puntatore al caratter

continueText                            ; keep going until we have processed the entire string
        clv
        bvc loopText                    ; branch always – two opcode relocatable version of jmp

done 
        rts



;===============================================================================
; Controlla se lo sprite è in collisione con il carattere
CheckSpriteCollideChar

        ldx VIC_SPRITE_COLLISION_FOREGROUND
        cpx #$1
        beq CollisionWithChar
        ; non si è verificata nessuna collisione
        rts

CollisionWithChar


        ; una volta identificata la collisione posiziona la volpe
        lda #150
        sta VIC_SPRITE_POSX_REGISTER   
        sta VIC_SPRITE_POSY_REGISTER   
        sta SPRITE_POS_X
        sta SPRITE_POS_Y

        lda #0
        sta VIC_SPRITE_POSX_EXTENDED_REGISTER
        sta SPRITE_POS_X_EXTEND


        rts

;===============================================================================
;
SetPlayingField
        lda ORANGE                              ; colora il bordo dello schermo
        sta VIC_BORDER_REGISTER
;        lda WHITE
;        sta VIC_BACKGROUND_REGISTER

        rts

;===============================================================================
; Setta la posizione di default dello sprite 0, questa va rivista!!!
SetDefaultPositionSprite
        lda #30
        sta VIC_SPRITE_POSX_REGISTER
        lda #150
        sta VIC_SPRITE_POSY_REGISTER

        rts

;===============================================================================
; Setta il puntatore alla fiìgura per lo sprite 0
SetPointerDataSprites
        lda #$80
        sta VIC_SPRITE_0_POINTER        ; puntatore al blocco dati che contiene la figura
                                        ; per lo sprite 0
        rts

;===============================================================================
; Abilita la modalità multicolor per gli sprite. 

EnableMulticolor

        ldx #$0
loopEnableMulticolor
        lda spriteNumberMask,x
        ora VIC_SPRITE_ENABLE_MULTICOLOR
        sta VIC_SPRITE_ENABLE_MULTICOLOR
        inx
        cpx #$4
        bne loopEnableMulticolor

        rts


;===============================================================================
; Abilita gli sprite. 

EnableSprite

        ldx #$0
loopEnableSprite
        lda spriteNumberMask,x
        ora VIC_SPRITE_ENABLE_REGISTER
        sta VIC_SPRITE_ENABLE_REGISTER
        inx
        cpx #$4
        bne loopEnableSprite
        
        rts


;===============================================================================
; Posiziona lo sprite 0 (WOLF) in un punto definito dello schermo

BasePositionSprite
        ldx #$0
        lda SPRITE_POS_X,x
        sta VIC_SPRITE_POSX_REGISTER
        lda #$0
        sta VIC_SPRITE_POSY_REGISTER

        rts


;===============================================================================
; Definisce i colori per lo sprite 0 in modalità multicolr
SetupColorSprite0

        lda ORANGE
        sta VIC_SPRITE_0_COLOR
        lda BLACK 
        sta VIC_SPRITE_MULTICOLOR_0
        lda WHITE 
        sta VIC_SPRITE_MULTICOLOR_1
        rts





;===============================================================================
;Player Control

PlayerControl

        lda DOWN                                ; gestione del movimento DOWN
        bit JOY_PORT_A
        bne NotDownPressed                     

        lda SPRITE_UP
        sta VIC_SPRITE_0_POINTER

        inc SPRITE_UP
        cmp #$87
        bne NoResetSpriteUp
        lda #$86
        sta SPRITE_UP
        

NoResetSpriteUp

        jsr PlayerMoveDown

NotDownPressed
        lda UP
        bit JOY_PORT_A
        bne NotUpPressed

        lda SPRITE_DOWN 
        sta VIC_SPRITE_0_POINTER

        jsr PlayerMoveUp

NotUpPressed

        lda LEFT                               ; Gestione del movimento a sinistra del JOY
        bit JOY_PORT_A
        bne NotLeftPressed
        
        lda SPRITE_LEFT                         ; Legge il byte che rappresenta lo                                                
        sta VIC_SPRITE_0_POINTER                ; sprite da visulaizzare e lo memorizza
                                                ; nel registro $07f8.


        ; Routine per attesa su cambio sprite
        lda SPRITE_DELAY
        cmp #$03
        beq NoDelayChangeSpriteLeft
        inc SPRITE_DELAY
        jmp NoResetSpriteLeft

NoDelayChangeSpriteLeft
        lda #$0
        sta SPRITE_DELAY

        inc SPRITE_LEFT                         ; Incrementa il byte che rappresenta il 
                                                ; prossimo sprite da utilizzare per
                                                ; l'asse delle X.
        
        lda SPRITE_LEFT                                              
        cmp #$85
        bne NoResetSpriteLeft
        lda #$83
        sta SPRITE_LEFT


NoResetSpriteLeft
        
        jsr PlayerMoveLeft



NotLeftPressed                                  ; Gestione del movimento a destra del JOY
        lda RIGHT
        bit JOY_PORT_A
        bne NoRightPressed
        
        lda SPRITE_RIGHT
        sta VIC_SPRITE_0_POINTER


        ; Routine per attesa su cambio sprite
        lda SPRITE_DELAY
        cmp #$03
        beq NoDelayChangeSpriteRight
        inc SPRITE_DELAY
        jmp NoResetSpriteRight

NoDelayChangeSpriteRight
        lda #$0
        sta SPRITE_DELAY


        inc SPRITE_RIGHT
        lda SPRITE_RIGHT
        cmp #$82
        bne NoResetSpriteRight
        lda #$80
        sta SPRITE_RIGHT

NoResetSpriteRight

        jsr PlayerMoveRight

NoRightPressed

        rts



;===============================================================================
; 

PlayerMoveDown

        beq NoMovePlayerDown
        inc SPRITE_POS_Y                        ; Incrementa il byte che rappresenta
                                                ; la posizione dello sprite
                                                ; sull'asse delle Y
        txa
        asl
        tay

        lda SPRITE_POS_Y                        ; Carica nell'accumulatore il byte
        sta VIC_SPRITE_POSY_REGISTER            ; che rappresenta la posizione dello
                                                ; sprite sull'asse delle Y e
                                                ; lo memrizza nel registro $D000
                                                ; del VIC

        lda #2
        sta SPRITE_LAST_DIRECTION
        
        
             
NoMovePlayerDown                                   
        rts

PlayerMoveUp
        dec SPRITE_POS_Y                        ; Decrementa il byte che rappresenta
                                                ; la posizione dello sprite
                                                ; sull'asse delle Y
        txa
        asl
        tay

        lda SPRITE_POS_Y                        ; Carica nell'accumulatore il byte
        sta VIC_SPRITE_POSY_REGISTER            ; che rappresenta la posizione dello
                                                ; sprite sull'asse delle Y e
                                                ; lo memrizza nel registro $D000
                                                ; del VIC

        lda #1
        sta SPRITE_LAST_DIRECTION

                                                
        rts

PlayerMoveLeft
        dec SPRITE_POS_X,x                      ; Decrementa il byte che raooresenta
                                                ; la posizione dello sprite sull'
                                                ; asse delle X.
        bne NoChangeInExtendedFlagLeft

        lda BIT_TABLE,x
        eor #$ff
        and SPRITE_POS_X_EXTEND
        sta SPRITE_POS_X_EXTEND
        sta VIC_SPRITE_POSX_EXTENDED_REGISTER

NoChangeInExtendedFlagLeft
        txa
        asl
        tay
        lda SPRITE_POS_X                        ; Carica nell'accumulatore il byte
        sta VIC_SPRITE_POSX_REGISTER,y          ; che rappresenta la posizione dello
                                                ; sprite sull'asse delle X e
                                                ; lo memrizza nel registro $D000
                                                ; del VIC

        lda #3
        sta SPRITE_LAST_DIRECTION



        rts


PlayerMoveRight
        inc SPRITE_POS_X                        ; Incrementa il byte che rappresenta
                                                ; la posizione dello sprite sull'
                                                ; asse X.
        lda SPRITE_POS_X                        
        bne NoChangeInExtendedFlagRight

        lda BIT_TABLE,x
        ora SPRITE_POS_X_EXTEND
        sta SPRITE_POS_X_EXTEND
        sta VIC_SPRITE_POSX_EXTENDED_REGISTER

NoChangeInExtendedFlagRight       
        txa
        asl
        tay
        lda SPRITE_POS_X                        ; Carica nell'accumulatore il byte
        sta VIC_SPRITE_POSX_REGISTER,y          ; che rappresenta la posizione dello
                                                ; sprite sull'asse delle X e
                                                ; lo memrizza nel registro $D000
                                                ; del VIC


        lda #4
        sta SPRITE_LAST_DIRECTION

        rts


;===============================================================================

SCORE                                   ; Punteggio di default 0
        byte 48  


REFRESH_BALLONS
        byte 0

TEMP
        byte 0

SPRITE_POS_X
        byte 30,0,0,0,0,0,0,0            ; posizione x di partenza degli sprite

SPRITE_POS_Y
        byte 150,0,0,0,0,0,0,0            ; posizione x di partenza degli sprite

BIT_TABLE
        byte 1,2,4,8,16,32,64,128

SPRITE_POS_X_EXTEND
        byte 0

SPRITE_LEFT
        byte 131                        ; il numero è espresso in decimale

SPRITE_RIGHT
        byte 128                        ; il numero è espresso in decimale

SPRITE_UP
        byte 134                        ; il numero è espresso in decimale

SPRITE_DOWN
        byte 136                        ; il numero è espresso in decimale

SPRITE_DELAY
        byte 0


SPRITE_LAST_DIRECTION                   ; 1 UP
        byte 0                          ; 2 DOWN
                                        ; 3 LEFT
                                        ; 4 RIGHT

SPRITE2_BALLONS_POSX
        byte 60, 120, 90, 60, 200, 70, 130, 200, 240

SPRITE2_BALLONS_POSY
        byte 130, 155, 175, 125 , 90, 200, 95, 100, 70 

  

SPRITE3_BALLONS_POSX
        byte 200, 70, 130, 200, 240, 60, 215, 90, 180

SPRITE3_BALLONS_POSY
        byte 200, 80, 115, 125 , 90, 110, 220, 100, 215


SPRITE4_BALLONS_POSX
        byte 130, 95, 110, 115, 155, 100, 90, 110, 60

SPRITE4_BALLONS_POSY
        byte 90, 200, 80, 215, 155, 90, 117, 175, 125

spriteNumberMask
        byte %00000001, %00000010, %00000100, %00001000, %00010000, %00100000, %01000000, %10000000


punteggio byte "IL TUO PUNTEGGIO ATTUALE:",0


* = $2000
incbin sprites.bin



