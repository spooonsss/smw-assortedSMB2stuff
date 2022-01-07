;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Birdo's Egg, by mikeyk
;;
;; Description
;: 
;; Note: When rideable, clipping tables values should be: 03 0A FE 0E
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Uses first extra bit: NO
;;
;; Extra Property Byte 1
;;    bit 0 - enable spin killing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    print "INIT",pc
                    PHY
                    %SubHorzPos()
                    TYA
                    STA $157C,x
                    PLY
                    RTL                 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    print "MAIN",pc
                    PHB                     ; \
                    PHK                     ;  | main sprite function, just calls local subroutine
                    PLB                     ;  |
                    JSR SPRITE_CODE_START   ;  |
                    PLB                     ;  |
                    RTL                     ; /


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

X_SPEED:             db $20,$E0
KILLED_X_SPEED:      db $F0,$10

RETURN:              RTS
SPRITE_CODE_START:   JSR SPRITE_GRAPHICS       ; graphics routine
                    LDA $14C8,x             ; \ 
                    CMP #$08                ;  | if status != 8, return
                    BNE RETURN              ; /
                    ; JSR SUB_OFF_SCREEN_X0   ; handle off screen situation
                    LDA #0
                    %SubOffScreen()
                    LDY $157C,x             ; \ set x speed based on direction
                    LDA X_SPEED,y           ;  |
                    STA $B6,x               ; /
                    LDA $9D                 ; \ if sprites locked, return
                    BNE RETURN              ; /

                    STZ $AA,x
                    JSL $01802A             ; update position based on speed values
         
                    LDA $1588,x             ; \ if sprite is in contact with an object...
                    AND #$03                ;  |
                    BEQ NO_CONTACT          ;  |
                    LDA $157C,x             ;  | flip the direction status
                    EOR #$01                ;  |
                    STA $157C,x             ; /
NO_CONTACT:          
                    JSL $01A7DC             ; check for mario/sprite contact (carry set = contact)
                    BCC RETURN_24           ; return if no contact
                    %SubVertPos()        ; 
                    LDA $0E                 ; \ if mario isn't above sprite, and there's vertical contact...
                    CMP #$E6                ;  |     ... sprite wins
                    BPL SPRITE_WINS         ; /
                    LDA $7D                 ; \if mario speed is upward, return
                    BMI RETURN_24           ; /
                    LDA !extra_prop_1,x
                    AND #$01
                    BEQ SPIN_KILL_DISABLED  ;
                    LDA $140D               ; \ if mario is spin jumping, goto SPIN_KILL
                    BNE SPIN_KILL           ; / 
SPIN_KILL_DISABLED: LDA #$01                ; \ set "on sprite" flag
                    STA $1471               ; /
                    LDA #$06                ; \ set riding sprite
                    STA $154C,x             ; / 
                    STZ $7D                 ; y speed = 0
                    LDA #$E1                ; \
                    LDY $187A               ;  | mario's y position += E1 or D1 depending if on yoshi
                    BEQ NO_YOSHI            ;  |
                    LDA #$D1                ;  |
NO_YOSHI:           CLC                     ;  |
                    ADC $D8,x               ;  |
                    STA $96                 ;  |
                    LDA $14D4,x             ;  |
                    ADC #$FF                ;  |
                    STA $97                 ; /
                    LDY #$00                ; \ 
                    LDA $77
                    AND #$03
                    BNE RETURN_24B
                    LDA $1491               ;  | $1491 == 01 or FF, depending on direction
                    BPL LABEL9              ;  | set mario's new x position
                    DEY                     ;  |
LABEL9:             CLC                     ;  |
                    ADC $94                 ;  |
                    STA $94                 ;  |
                    TYA                     ;  |
                    ADC $95                 ;  |
                    STA $95                 ; /
RETURN_24B:         RTS                     ;

SPRITE_WINS:        LDA $154C,x             ; \ if riding sprite...
                    ORA $15D0,x             ;  |   ...or sprite being eaten...
                    BNE RETURN_24           ; /   ...return
                    LDA $1490               ; \ if mario star timer > 0, goto HAS_STAR 
                    BNE HAS_STAR            ; / NOTE: branch to RETURN_24 to disable star killing                  
                    JSL $00F5B7             ; hurt mario
RETURN_24:          RTS                     ; final return

SPIN_KILL:          JSR SUB_STOMP_PTS       ; give mario points
                    JSL $01AA33             ; set mario speed, NOTE: remove call to not bounce off sprite
                    JSL $01AB99             ; display contact graphic
                    LDA #$04                ; \ status = 4 (being killed by spin jump)
                    STA $14C8,x             ; /   
                    LDA #$1F                ; \ set spin jump animation timer
                    STA $1540,x             ; /
                    JSL $07FC3B             ; show star animation
                    LDA #$08                ; \ play sound effect
                    STA $1DF9               ; /
                    RTS                     ; return
HAS_STAR:           LDA #$02                ; \ status = 2 (being killed by star)
                    STA $14C8,x             ; /
                    LDA #$D0                ; \ set y speed
                    STA $AA,x               ; /
                    %SubHorzPos()        ; get new direction
                    LDA KILLED_X_SPEED,y    ; \ set x speed based on direction
                    STA $B6,x               ; /
                    INC $18D2               ; increment number consecutive enemies killed
                    LDA $18D2               ; \
                    CMP #$08                ;  | if consecutive enemies stomped >= 8, reset to 8
                    BCC NO_RESET2           ;  |
                    LDA #$08                ;  |
                    STA $18D2               ; /   
NO_RESET2:          JSL $02ACE5             ; give mario points
                    LDY $18D2               ; \ 
                    CPY #$08                ;  | if consecutive enemies stomped < 8 ...
                    BCS NO_SOUND2           ;  |
                    LDA STAR_SOUNDS,y       ;  |    ... play sound effect
                    STA $1DF9               ; /
NO_SOUND2:          RTS                     ; final return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TILEMAP:             db $e6,$e6

SPRITE_GRAPHICS:
        %GetDrawInfo()       ; sets y = OAM offset
		LDA #$F0		; \ kill that annoying tile used
		STA $0309,y		; / for original shell tilemaps
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

LOOP_START_2:        LDA $00                 ; \ tile x position = sprite x location ($00)
                    STA $0300,y             ; /

                    LDA $01                 ; \ tile y position = sprite y location ($01)
                    STA $0301,y             ; /

                    LDA $15F6,x             ; tile properties xyppccct, format
                    LDX $02                 ; \ if direction == 0...
                    BNE NO_FLIP             ;  |
                    ORA #$40                ; /    ...flip tile
NO_FLIP:             ORA $64                 ; add in tile priority of level
                    STA $0303,y             ; store tile properties

                    LDX $03                 ; \ store tile
                    LDA TILEMAP,x           ;  |
                    STA $0302,y             ; /

                    INY                     ; \ increase index to sprite tile map ($300)...
                    INY                     ;  |    ...we wrote 1 16x16 tile...
                    INY                     ;  |    ...sprite OAM is 8x8...
                    INY                     ; /    ...so increment 4 times

                    PLX                     ; pull, X = sprite index
                    LDY #$02                ; \ 460 = 2 (all 16x16 tiles)
                    LDA #$00                ;  | A = (number of tiles drawn - 1)
                    ; JSL $01B7B3             ; / don't draw if offscreen
                    %FinishOAMWrite()
                    RTS                     ; return
                    



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; routines below can be shared by all sprites.  they are ripped from original
; SMW and poorly documented
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; points routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

STAR_SOUNDS:         db $00,$13,$14,$15,$16,$17,$18,$19

SUB_STOMP_PTS:       PHY                     ; 
                    LDA $1697               ; \
                    CLC                     ;  | 
                    ADC $1626,x             ; / some enemies give higher pts/1ups quicker??
                    INC $1697               ; increase consecutive enemies stomped
                    TAY                     ;
                    INY                     ;
                    CPY #$08                ; \ if consecutive enemies stomped >= 8 ...
                    BCS NO_SOUND            ; /    ... don't play sound 
                    LDA STAR_SOUNDS,y       ; \ play sound effect
                    STA $1DF9               ; /   
NO_SOUND:            TYA                     ; \
                    CMP #$08                ;  | if consecutive enemies stomped >= 8, reset to 8
                    BCC NO_RESET            ;  |
                    LDA #$08                ; /
NO_RESET:            JSL $02ACE5             ; give mario points
                    PLY                     ;
                    RTS                     ; return
                
