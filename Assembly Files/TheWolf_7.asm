
*=$0801 ; 10 SYS (2064)

          byte           $0E, $08, $0A, $00, $9E, $20, $28, $32
          byte           $30, $36, $34, $29, $00, $00, $00


          jsr            ClearColorRAM
          jsr            ClearScreen; esegue la cancellazione dello schermo
          jsr            SetupColorsSprites
                                   ;jsr SetupColorSprite0                   ; definisce i colori per lo sprite 0 (WOLF)
          jsr            EnableMulticolor; abilita il multicolor per gli sprite
          jsr            EnableSprite; abilita gli sprite
          jsr            SetPointerDataSprites;
          jsr            SetDefaultPositionSprite; setta la posizione di default dello sprite 0
          jsr            SetPlayingField; setta i colori del campo di gioco
          jsr            DrawText  ; scrive il testo
          jsr            MakeMap   ; disegna la mappa sullo schermo





          sei
loop

          jsr            PlayerControl; Gestione dei movimenti del JOY per loop
                                   ; sprite 0 (wolf).


          jsr            CheckPlayerCollison; Verifica se si presenta una collisione
                                   ; tra lo sprite 0 (wolf) e uno delgli
                                   ; altri sprite.


          jsr            CheckSpriteCollideChar

          jsr            WaitRaster; attende l'arrivo della raster prima di
                                   ; continuare il loop del gioco.


          lda            REFRESH_BALLONS
          cmp            #$FF
          bne            continue

          lda            #%00011111
          sta            VIC_SPRITE_ENABLE_REGISTER

          jsr            Ballon
          lda            #$0
          sta            REFRESH_BALLONS

continue
          inc            REFRESH_BALLONS



          lda            SCORE
          cmp            #58
          bne            NoResetScore
          lda            #48
          sta            SCORE

NoResetScore
          sta            $420      ; Scrive il punteggio a video


          jmp            loop


;===============================================================================
CheckPlayerCollison

          lda            $D01E

          cmp            #3        ; 00000011
          bne            NoCollideSprite1_2

          lda            #$86
          sta            $07f9

          lda            VIC_SPRITE_ENABLE_REGISTER
          and            #%11111101
          sta            VIC_SPRITE_ENABLE_REGISTER

          lda            SCORE     ; Verifica che lo score non
          cmp            #48       ; assuma mai volori inferiori
          beq            NoCollideSprite1_2; allo 0 (48)
          dec            SCORE

          jmp            ExitCollide

NoCollideSprite1_2
          CMP            #5        ; 00000101
          BNE            NoCollideSprite3_1

          lda            #$86
          sta            $07fA

          lda            VIC_SPRITE_ENABLE_REGISTER
          and            #%11111011
          sta            VIC_SPRITE_ENABLE_REGISTER

          inc            SCORE     ; Incrementa lo score

          jmp            ExitCollide

NoCollideSprite3_1
          CMP            #09       ; 0001001
          BNE            NoCollideSprite4_1


          lda            #$86
          sta            $07fB

          lda            VIC_SPRITE_ENABLE_REGISTER
          and            #%11110111
          sta            VIC_SPRITE_ENABLE_REGISTER

          inc            SCORE     ; Incrementa lo score

          jmp            ExitCollide

NoCollideSprite4_1

          CMP            #17       ; 00010001
          BNE            NoCollideSprite5_1

          lda            #$86
          sta            $07fc

          lda            VIC_SPRITE_ENABLE_REGISTER
          and            #%11101111
          sta            VIC_SPRITE_ENABLE_REGISTER

          inc            SCORE     ; Incrementa lo score

NoCollideSprite5_1

ExitCollide



          rts


;===============================================================================
Ballon

          LDX            TEMP
          cpx            #9
          bne            BallonContinue

          ldx            #0
          stx            TEMP

BallonContinue


                                   ; prova posizionamento secondo sprite
          lda            SPRITE2_BALLONS_POSX,x
          sta            $d002
          lda            SPRITE2_BALLONS_POSY,x
          sta            $d003
          lda            #$89      ; palloncino marrone
          sta            $07f9

                                   ; prova posizionamento terzo sprite

          lda            SPRITE3_BALLONS_POSX,x
          sta            $d004
          lda            SPRITE3_BALLONS_POSY,x
          sta            $d005
          lda            #$89      ; palloncino marrone
          sta            $07fa


          lda            SPRITE4_BALLONS_POSY,x
          sta            $d006
          lda            SPRITE4_BALLONS_POSY,x
          sta            $d007
          lda            #$89      ; palloncino marrone
          sta            $07fb


          inc            TEMP

          rts


;===============================================================
; Scrive un messaggio a video
drawText
          ldx            #$00      ; Puntatore al carattere da leggere

loopText
          lda            punteggio,x; Prende il carattere puntato dalla
                                   ; dalla stringa di testo
          cmp            #$0       ; Controlla che il byte letto sia il
          beq            done      ; termonatore di stringa


outchar
          and            #$3f      ; correction because for poke A is 1 and not 65.
          sta            SCREENMEM,x; store character directly in screen memory

          inx                      ; Aggiorna il puntatore al caratter

continueText                         ; keep going until we have processed the entire string
          clv
          bvc            loopText  ; branch always – two opcode relocatable version of jmp

done
          rts



;===============================================================================
; Controlla se lo sprite è in collisione con il carattere
CheckSpriteCollideChar
          ldx            VIC_SPRITE_COLLISION_FOREGROUND
          cpx            #$1
          bne            NoCollisionWithChar

                                   ; Imposta flag di collisione su base direzione
          lda            #0
          sta            COLLISION_X
          sta            COLLISION_Y

          lda            SPRITE_LAST_DIRECTION
          sta            BLOCKED_DIRECTION

                                   ; Se la direzione è verticale, setta COLLISION_Y = 1
          lda            SPRITE_LAST_DIRECTION
          cmp            #1        ; UP
          beq            SetCollisionY
          cmp            #2        ; DOWN
          beq            SetCollisionY

                                   ; Se la direzione è orizzontale, setta COLLISION_X = 1
          cmp            #3        ; LEFT
          beq            SetCollisionX
          cmp            #4        ; RIGHT
          beq            SetCollisionX

SetCollisionX
          lda            #1
          sta            COLLISION_X
          jmp            PushOutCollision

SetCollisionY
          lda            #1
          sta            COLLISION_Y

PushOutCollision
                                   ; Spingi indietro lo sprite sull'asse X se c'è collisione X
          lda            COLLISION_X
          beq            NoPushX
          lda            SPRITE_LAST_DIRECTION
          cmp            #3        ; LEFT
          beq            PushRight
          cmp            #4        ; RIGHT
          beq            PushLeft

NoPushX
                                   ; Spingi indietro lo sprite sull'asse Y se c'è collisione Y
          lda            COLLISION_Y
          beq            EndCollision
          lda            SPRITE_LAST_DIRECTION
          cmp            #1        ; UP
          beq            PushDown
          cmp            #2        ; DOWN
          beq            PushUp

EndCollision
          rts

PushRight
          inc            SPRITE_POS_X
          lda            SPRITE_POS_X
          sta            VIC_SPRITE_POSX_REGISTER
          rts

PushLeft
          dec            SPRITE_POS_X
          lda            SPRITE_POS_X
          sta            VIC_SPRITE_POSX_REGISTER
          rts

PushDown
          inc            SPRITE_POS_Y
          lda            SPRITE_POS_Y
          sta            VIC_SPRITE_POSY_REGISTER
          rts

PushUp
          dec            SPRITE_POS_Y
          lda            SPRITE_POS_Y
          sta            VIC_SPRITE_POSY_REGISTER
          rts

NoCollisionWithChar
          lda            #0
          sta            BLOCKED_DIRECTION
          lda            #0
          sta            COLLISION_X
          sta            COLLISION_Y
          rts




;===============================================================================
;
SetPlayingField
          lda            ORANGE    ; colora il bordo dello schermo
          sta            VIC_BORDER_REGISTER
;        lda WHITE
;        sta VIC_BACKGROUND_REGISTER

          rts

;===============================================================================
; Setta la posizione di default dello sprite 0, questa va rivista!!!
SetDefaultPositionSprite
          lda            #160
          sta            SPRITE_POS_X
          sta            VIC_SPRITE_POSX_REGISTER

          lda            #100
          sta            SPRITE_POS_Y
          sta            VIC_SPRITE_POSY_REGISTER

          lda            #0
          sta            SPRITE_POS_X_EXTEND
          sta            VIC_SPRITE_POSX_EXTENDED_REGISTER

          rts

;===============================================================================
; Setta il puntatore alla fiìgura per lo sprite 0
SetPointerDataSprites
          lda            #$80
          sta            VIC_SPRITE_0_POINTER; puntatore al blocco dati che contiene la figura
                                   ; per lo sprite 0
          rts

;===============================================================================
; Abilita la modalità multicolor per gli sprite.

EnableMulticolor

          ldx            #$0
loopEnableMulticolor
          lda            spriteNumberMask,x
          ora            VIC_SPRITE_ENABLE_MULTICOLOR
          sta            VIC_SPRITE_ENABLE_MULTICOLOR
          inx
          cpx            #$4
          bne            loopEnableMulticolor

          rts


;===============================================================================
; Abilita gli sprite.

EnableSprite

          ldx            #$0
loopEnableSprite
          lda            spriteNumberMask,x
          ora            VIC_SPRITE_ENABLE_REGISTER
          sta            VIC_SPRITE_ENABLE_REGISTER
          inx
          cpx            #$4
          bne            loopEnableSprite

          rts


;===============================================================================
; Posiziona lo sprite 0 (WOLF) in un punto definito dello schermo

BasePositionSprite
          ldx            #$0
          lda            SPRITE_POS_X,x
          sta            VIC_SPRITE_POSX_REGISTER
          lda            #$0
          sta            VIC_SPRITE_POSY_REGISTER

          rts


;===============================================================================
; Definisce i colori per lo sprite 0 in modalità multicolr
SetupColorSprite0

          lda            ORANGE
          sta            VIC_SPRITE_0_COLOR
          lda            BLACK
          sta            VIC_SPRITE_MULTICOLOR_0
          lda            WHITE
          sta            VIC_SPRITE_MULTICOLOR_1
          rts





;===============================================================================
;Player Control
PlayerControl

          lda            #0
          sta            BLOCKED_DIRECTION

                                   ; GIÙ
          lda            JOY_PORT_A
          and            #DOWN     ; DOWN = %00000010
          beq            MoveDown  ; se il bit è 0 → tasto premuto

                                   ; SU
          lda            JOY_PORT_A
          and            #UP       ; UP = %00000001
          beq            MoveUp

                                   ; SINISTRA
          lda            JOY_PORT_A
          and            #LEFT     ; LEFT = %00000100
          beq            MoveLeft

                                   ; DESTRA
          lda            JOY_PORT_A
          and            #RIGHT    ; RIGHT = %00001000
          beq            MoveRight

          rts                      ; nessun tasto premuto → esce

MoveDown
          lda            #$88      ; Sprite numero 9
          sta            VIC_SPRITE_0_POINTER

          jsr            PlayerMoveDown
          rts

NoResetSpriteDown
          jsr            PlayerMoveDown
          rts

MoveUp
          lda            SPRITE_UP
          sta            VIC_SPRITE_0_POINTER

          inc            SPRITE_UP
          cmp            #$87
          bne            NoResetSpriteUp
          lda            #$86
          sta            SPRITE_UP

NoResetSpriteUp
          jsr            PlayerMoveUp
          rts

MoveLeft
          lda            SPRITE_LEFT
          sta            VIC_SPRITE_0_POINTER

          lda            SPRITE_DELAY
          cmp            #$03
          beq            NoDelayChangeSpriteLeft
          inc            SPRITE_DELAY
          jmp            NoResetSpriteLeft

NoDelayChangeSpriteLeft
          lda            #$00
          sta            SPRITE_DELAY
          inc            SPRITE_LEFT
          lda            SPRITE_LEFT
          cmp            #$85
          bne            NoResetSpriteLeft
          lda            #$83
          sta            SPRITE_LEFT

NoResetSpriteLeft
          jsr            PlayerMoveLeft
          rts

MoveRight
          lda            SPRITE_RIGHT
          sta            VIC_SPRITE_0_POINTER

          lda            SPRITE_DELAY
          cmp            #$03
          beq            NoDelayChangeSpriteRight
          inc            SPRITE_DELAY
          jmp            NoResetSpriteRight

NoDelayChangeSpriteRight
          lda            #$00
          sta            SPRITE_DELAY
          inc            SPRITE_RIGHT
          lda            SPRITE_RIGHT
          cmp            #$82
          bne            NoResetSpriteRight
          lda            #$80
          sta            SPRITE_RIGHT

NoResetSpriteRight
          jsr            PlayerMoveRight
          rts


;===============================================================================
;

PlayerMoveDown
          lda            #2
          sta            SPRITE_LAST_DIRECTION

          lda            BLOCKED_DIRECTION
          cmp            #2        ; Se la direzione bloccata è DOWN
          beq            NoMoveDownBlocked

          lda            COLLISION_Y
          cmp            #1
          beq            NoMoveDownBlocked

          inc            SPRITE_POS_Y
          lda            SPRITE_POS_Y
          sta            VIC_SPRITE_POSY_REGISTER
          rts

NoMoveDownBlocked
          rts

PlayerMoveUp
          lda            #1
          sta            SPRITE_LAST_DIRECTION

          lda            BLOCKED_DIRECTION
          cmp            #1        ; Se la direzione bloccata è UP
          beq            NoMoveUpBlocked

          lda            COLLISION_Y
          cmp            #1
          beq            NoMoveUpBlocked

          dec            SPRITE_POS_Y
          lda            SPRITE_POS_Y
          sta            VIC_SPRITE_POSY_REGISTER
          rts

NoMoveUpBlocked
          rts


PlayerMoveLeft
          lda            #3
          sta            SPRITE_LAST_DIRECTION

          lda            COLLISION_X
          cmp            #1
          beq            NoMoveLeftBlocked; Se c'è collisione asse X blocca movimento

          lda            SPRITE_POS_X
          bne            NormalLeftMove

                                   ; SPRITE_POS_X == 0, gestisci bit esteso
          lda            SPRITE_POS_X_EXTEND
          and            #%00000001
          beq            NoMoveLeftBlocked; se bit già a 0, non posso più andare a sinistra

          lda            SPRITE_POS_X_EXTEND
          and            #%11111110
          sta            SPRITE_POS_X_EXTEND
          sta            VIC_SPRITE_POSX_EXTENDED_REGISTER

          lda            #$FF
          sta            SPRITE_POS_X
          sta            VIC_SPRITE_POSX_REGISTER
          rts

NormalLeftMove
          dec            SPRITE_POS_X
          lda            SPRITE_POS_X
          sta            VIC_SPRITE_POSX_REGISTER
          rts

NoMoveLeftBlocked
          rts



PlayerMoveRight
          lda            #4
          sta            SPRITE_LAST_DIRECTION

          lda            COLLISION_X
          cmp            #1
          beq            NoMoveRightBlocked; Se c'è collisione asse X blocca movimento

          lda            SPRITE_POS_X
          cmp            #$FF
          bne            NormalRightMove

          lda            SPRITE_POS_X_EXTEND
          and            #%00000001
          bne            NoMoveRightBlocked

          lda            SPRITE_POS_X_EXTEND
          ora            #%00000001
          sta            SPRITE_POS_X_EXTEND
          sta            VIC_SPRITE_POSX_EXTENDED_REGISTER

          lda            #0
          sta            SPRITE_POS_X
          sta            VIC_SPRITE_POSX_REGISTER
          rts

NormalRightMove
          inc            SPRITE_POS_X
          lda            SPRITE_POS_X
          sta            VIC_SPRITE_POSX_REGISTER
          rts

NoMoveRightBlocked
          rts



;===============================================================================
ClearColorRAM
          ldx            #$00
FillColorLoop
          lda            #ORANGE   ; valore 8
          sta            COLORMEM,x
          inx
          cpx            #$F8      ; 248 * 4 = 992 (quasi tutto lo schermo)
          bne            FillColorLoop
          rts



; SetupColorsSprites DEBUG!!!!!!!
; Imposta colori fissi per sprite 0..3 e multicolor 0 e 1
SetupColorsSprites
          lda            #ORANGE   ; colore arancione per sprite 0
          sta            $D027     ; VIC_SPRITE_0_COLOR

                                   ;lda #$01           ; colore bianco per sprite 1
                                   ;sta $D028          ; VIC_SPRITE_1_COLOR

                                   ;lda #$01           ; colore bianco per sprite 2
                                   ;sta $D029          ; VIC_SPRITE_2_COLOR

                                   ;lda #$01           ; colore bianco per sprite 3
                                   ;sta $D02A          ; VIC_SPRITE_3_COLOR

          lda            #BLACK    ; multicolor 0 = nero
          sta            $D025     ; VIC_SPRITE_MULTICOLOR_0

          lda            #WHITE    ; multicolor 1 = bianco
          sta            $D026     ; VIC_SPRITE_MULTICOLOR_1

          rts
;===============================================================================

SCORE                              ; Punteggio di default 0
          byte           48


REFRESH_BALLONS
          byte           0

TEMP
          byte           0

SPRITE_POS_X
          byte           30,0,0,0,0,0,0,0            ; posizione x di partenza degli sprite

SPRITE_POS_Y
          byte           150,0,0,0,0,0,0,0            ; posizione x di partenza degli sprite

BIT_TABLE
          byte           1,2,4,8,16,32,64,128

SPRITE_POS_X_EXTEND
          byte           0

SPRITE_LEFT
          byte           131                        ; il numero è espresso in decimale

SPRITE_RIGHT
          byte           128                        ; il numero è espresso in decimale

SPRITE_UP
          byte           134                        ; il numero è espresso in decimale

SPRITE_DOWN
          byte           136                        ; il numero è espresso in decimale

SPRITE_DELAY
          byte           0


SPRITE_LAST_DIRECTION                           ; 1 UP
          byte           0                      ; 2 DOWN
                                                ; 3 LEFT
                                                ; 4 RIGHT

SPRITE2_BALLONS_POSX
          byte           60, 120, 90, 60, 200, 70, 130, 200, 240

SPRITE2_BALLONS_POSY
          byte           130, 155, 175, 125 , 90, 200, 95, 100, 70



SPRITE3_BALLONS_POSX
          byte           200, 70, 130, 200, 240, 60, 215, 90, 180

SPRITE3_BALLONS_POSY
          byte           200, 80, 115, 125 , 90, 110, 220, 100, 215


SPRITE4_BALLONS_POSX
          byte           130, 95, 110, 115, 155, 100, 90, 110, 60

SPRITE4_BALLONS_POSY
          byte           90, 200, 80, 215, 155, 90, 117, 175, 125

spriteNumberMask
          byte           %00000001, %00000010, %00000100, %00001000, %00010000, %00100000, %01000000, %10000000


punteggio byte           "IL TUO PUNTEGGIO ATTUALE:",0


*         = $2000
incbin    sprites.bin



