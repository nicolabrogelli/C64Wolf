;===============================================================================
; Esegue la cancellazione dello schermo richiamando la routne all'indirizzo $E544
ClearScreen
        jsr $E544       
        rts



;===============================================================================
; Attende l'arrivo della rasterline

WaitRaster
        lda #255
waitLoop
        cmp VIC_RASTER_REGISTER
        bne waitLoop

        rts


;===============================================================================
; Il sistema va rivisto magari importando direttamente la mappa
MakeMap
         ldx #$00

draw1    lda #102   
         sta $0428,x    ; disegna la riga superiore
         sta $07C0,x    ; disegna la riga inferiore
         sta $0450
         sta $0477
         sta $0478
         sta $049f
         sta $04a0
         sta $04c7
         sta $04c8
         sta $04ef
         sta $04f0
         sta $0517
         sta $0518
         sta $053f
         sta $0540
         sta $0567
         sta $0568
         sta $058f
         sta $0590
         sta $05b7
         sta $05b8
         sta $05df
         sta $05e0

         inx
         cpx #$28 ;(Or use #40 instead)
         bne draw1

         ldx #$00

draw2    lda #102  
         sta $0607
         sta $0608
         sta $062f
         sta $0630
         sta $0657
         sta $0658
         sta $067f
         sta $0680
         sta $06a7
         sta $06a8
         sta $06cf
         sta $06d0
         sta $06f7
         sta $06f8
         sta $071f
         sta $0720
         sta $0747
         sta $0748
         sta $076f
         sta $0770
         sta $0797
         sta $0798
         sta $07bf

         inx
         cpx #$28 ;(Or use #40 instead)
         bne draw2
         
        

        
         rts