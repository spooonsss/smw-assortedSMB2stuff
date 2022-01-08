;Veggie, based off of smkdan's Sprite Gen block. By ICB. Act Like Block 25
; Point the sprite number to the Birdo Egg in your sprites list, and change it's GFX to look like the
; SMB 2 Veggie of your choice.

db $42

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireBall
JMP TopCorner : JMP BodyInside : JMP HeadInside

!SPRITENUMBER = $42	;sprite # to generate (Birdo Egg)
!ISCUSTOM = $01		;set to 01 to generate custom or 00 for standard

!XDISP = $FFF6		;value added to block position on generation
!YDISP = $0000

MarioAbove:
MarioBelow:
BodyInside:

LDA $1470 ; carrying something already
BNE RETURN2
LDA $16
AND #$40
BEQ RETURN2
TRB $16 ; un-press Y or X, so we don't shoot a fireball
PHY
LDA #$08
STA $1498
LDA #$06
STA $1DF9

if !ISCUSTOM
	SEC
else
	CLC
endif
	LDA #!SPRITENUMBER	;sprite to generate
	%spawn_sprite()
	BCS RETURN2
	TAX
	LDA #$0B
	STA $14C8,x

	REP #$20	;apply xdisp
	LDA $9A
	CLC
	ADC #!XDISP
	SEP #$20
	STA $E4,x
	XBA
	STA $14E0,x

	REP #$20	;apply ydisp
	LDA $98
	CLC
	ADC #!YDISP
	SEP #$20
	STA $D8,x
	XBA
	STA $14D4,x
	LDA #$02	;erase self
	STA $9C
	JSL $00BEB0|!bank	;generate blank block

PLY

RETURN2:

MarioSide:
SpriteV:
SpriteH:
MarioCape:
MarioFireBall:
TopCorner:
HeadInside:
	RTL

print "A planted SMB2 vegetable that can be plucked from the ground."