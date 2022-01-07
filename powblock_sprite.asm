;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SMB2 POW block
; By ICB. Based on code by SMWedit and GhettoYouth.
;
; Uses first extra bit: NO
;
; NOTE: use this sprite in conjunction w/ the SMB pow 2 block
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INIT and MAIN JSL targets
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		print "INIT",pc
LDA #$01
                    STA $157C,x             ; \ $02 = direction
		LDA #$0A		; \ make it an
		STA $14C8,x		; / activated shell
		RTL

		print "MAIN",pc
		PHB
		PHK
		PLB
		JSR SPRITE_ROUTINE
		PLB
		RTL     


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SPRITE ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DYING:	
                    STZ $B6,x
                    STZ $AA,x
		RTS

SPRITE_ROUTINE:	JSR SUB_GFX
		LDA $14C8,x		; \  return if
		CMP #$02		;  | sprite status
		BEQ DYING		;  | is < 8, or
		CMP #$08		;  | branch to death
		BCC RETURN		; /  handler if dying
		LDA $9D			; \ return if
		BNE RETURN		; / sprites locked
        LDA #0
        %SubOffScreen() 	; only process sprite while on screen

		LDA $1588,x		; \  if not hitting
		AND #%00000111		;  | wall, then skip
		BEQ NOHITWALL		; /  this next code

KILL:
	lda #$28			;shake ground
	STA $1887

        jsl $00FA80		;kill sprites, turn to coins
        LDA #$16                ; \ Play sound effect
        STA $1DFC               ; / 
		LDA #$02		; \ make sprite
		STA $14C8,x		; / start dying

NOHITWALL:



RETURN:		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GRAPHICS ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; TILEMAP:            db $82,$82
TILEMAP:            db $A0,$A0

SUB_GFX:    %GetDrawInfo()       ; sets y = OAM offset
        ; FIXME: what bug is this supposed to fix
		; LDA #$F0		; \ kill that annoying tile used
		; STA $0309,y		; / for original shell tilemaps
                    LDA $157C,x             ; \ $02 = direction
                    STA $02                 ; / 
                    LDA $14                 ; \ 
                    LSR A                   ;  |
                    LSR A                   ;  |
                    LSR A                   ;  |
                    CLC                     ;  |
                    ADC $15E9               ;  |
                    AND #$01                ;  |
                    STA $03                 ;  | $03 = index to frame start (0 or 1)
                    PHX                     ; /
                    
                    LDA $14C8,x
                    CMP #$02
                    BNE LOOP_START_2
                    STZ $03
                    LDA $15F6,x
                    ORA #$80
                    STA $15F6,x

LOOP_START_2:       LDA $00                 ; \ tile x position = sprite x location ($00)
                    STA $0300,y             ; /

                    LDA $01                 ; \ tile y position = sprite y location ($01)
                    STA $0301,y             ; /

                    LDA $15F6,x             ; tile properties xyppccct, format
                    ; Don't flip; we don't want "WOꟼ"
                    ; LDX $02                 ; \ if direction == 0...
                    ; BEQ NO_FLIP             ;  |
                    ; ORA #$40                ; /    ...flip tile
NO_FLIP:            ORA $64                 ; add in tile priority of level
                    STA $0303,y             ; store tile properties

                    LDX $03                 ; \ store tile
                    LDA TILEMAP,x           ;  |
                    STA $0302,y             ; /

                    ; INY                     ; \ increase index to sprite tile map ($300)...
                    ; INY                     ;  |    ...we wrote 1 16x16 tile...
                    ; INY                     ;  |    ...sprite OAM is 8x8...
                    ; INY                     ; /    ...so increment 4 times

                    PLX                     ; pull, X = sprite index
                    LDY #$02                ; \ 460 = 2 (all 16x16 tiles)
                    LDA #$00                ;  | A = (number of tiles drawn - 1)
                    %FinishOAMWrite()       ; / don't draw if offscreen
                    RTS                     ; return
