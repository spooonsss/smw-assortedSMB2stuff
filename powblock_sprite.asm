;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SMB2 POW block
; By ICB. Based on code by SMWedit and GhettoYouth.
;
; Uses first extra bit: NO
;
; NOTE: use this sprite in conjunction w/ the SMB pow 2 block
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!tile_no = $A0

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

        jsl $00FA80|!bank		;kill sprites, turn to coins
        LDA #$16                ; \ Play sound effect
        STA $1DFC               ; / 
		LDA #$02		; \ make sprite
		STA $14C8,x		; / start dying

NOHITWALL:



RETURN:		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GRAPHICS ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


SUB_GFX:    %GetDrawInfo()       ; sets y = OAM offset
        ; Undo the tile set at 19f27 (we are running original sprite code when status=carried)
		LDA #$F0		; \ kill that annoying tile used
		STA $0309,y		; / for original shell tilemaps
                    LDA $157C,x             ; \ $02 = direction
                    STA $02                 ; / 
                    
                    LDA $14C8,x
                    CMP #$02
                    BNE STORE_OAM
                    LDA $15F6,x
                    ORA #$80
                    STA $15F6,x

STORE_OAM:       LDA $00                 ; \ tile x position = sprite x location ($00)
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

                    LDA #!tile_no           ; \
                    STA $0302,y             ; /

                    LDY #$02                ; \ 460 = 2 (all 16x16 tiles)
                    LDA #$00                ;  | A = (number of tiles drawn - 1)
                    %FinishOAMWrite()       ; / don't draw if offscreen
                    RTS                     ; return
