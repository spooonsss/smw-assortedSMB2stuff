db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireBall : JMP Return_l : JMP Return_l : JMP Return_l

!XDISP = $FFF6		;value added to block position on generation
!YDISP = $0000

Return_l:
	RTL

MarioAbove:
	LDY #$01	;act like tile 130
	LDA #$30
	STA $1693
LDA $16
AND #$40
BEQ RETURN2
LDA #$E4
STA $7D
STZ $7B
LDA #$0A
STA $1498
LDA #$06
STA $1DF9

	LDA #$06	;erase self
	STA $9C
	JSL $00BEB0	;generate blank block
%create_smoke()	;make smoke
RETURN2:
RTL

SpriteV:
	LDY #$01	;act like tile 130
	LDA #$30
	STA $1693
MarioSide:
MarioBelow:
MarioCape:
SpriteH:
MarioFireBall:
	RTL

print "A SMB2-style diggable sand block that reveals a coin."