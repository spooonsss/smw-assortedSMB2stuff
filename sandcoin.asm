db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireBall : JMP RETURN2 : JMP RETURN2 : JMP RETURN2

!XDISP = $FFF6		;value added to block position on generation
!YDISP = $0000

MarioAbove:
LDA $16
AND #$40
BEQ RETURN2
TRB $16 ; un-press Y or X, so we don't shoot a fireball
LDA #$E4
STA $7D
STZ $7B
LDA #$0A
STA $1498
LDA #$06
STA $1DF9

	LDA #$06	;erase self
	STA $9C
	JSL $00BEB0|!bank	;generate blank block
%create_smoke()	;make smoke
RETURN2:
RTL

SpriteV:
MarioSide:
MarioBelow:
MarioCape:
SpriteH:
MarioFireBall:
	RTL

print "A SMB2-style diggable sand block that reveals a coin."