*=$0810 ;SYS2064 to run

        SEI
        LDA #$37
        STA $01
        LDA #$18
        STA $D016 ;Screen Multicolour mode enabled
        STA $D018 ;Charset mode set to display custom char $2000-$2800
        LDA #$00    ;Set colour black
        STA $D020 ;to border
        STA $D021 ;and background
        LDA #$0B
        STA $D022 ;Char Multicolour 1
        LDA #$0C
        STA $D023 ;Char Multicolour 2

;Draw main screen from matrix -
;NOTE max 256 chars per location ($0400-$04FF, $0500-$05ff,
;$0600,$06ff,$0700,$07e8)

        LDX #$00
DRAWSCRN
        LDA MATRIX,X    ;Get data from screen data file SCREEN.BIN
        STA $0400,X     ;Put data into SCREEN RAM
        LDA MATRIX+$100,X ;Fetch the next 256 bytes of data from binary
        STA $0500,X    ;Store the next 256 bytes to screen
        LDA MATRIX+$200,X ;... and so on
        STA $0600,X
        LDA MATRIX+$2E8,X
        STA $06E8,X
        INX             ;Increment accumulator until 256 bytes read
        BNE DRAWSCRN    ;

        JMP * ;Infinite loop

;If using a cross assembler use CORRECT pseudo command, offset for importing binary data

* = $2000
CHARSET
incbin charatter.bin

* = $2800
MATRIX
incbin screen.bin
