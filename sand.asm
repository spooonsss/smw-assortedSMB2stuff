;; Sand Block. By ICB. Make act like Block 100

db $42

JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireBall : JMP RETURN2 : JMP RETURN2 : JMP RETURN2

MarioAbove:
LDA $16			;If button
AND #$40		;Y or X isn't pressed
BEQ RETURN2		;return
TRB $16 ; un-press Y or X, so we don't shoot a fireball
LDA #$E4		;Move Mario up
STA $7D			;for a second
STZ $7B			;Zero horz speed
LDA #$0A		;Show ducking while picking up
STA $1498		;item pose
LDA #$06		;play sound
STA $1DF9

	LDA #$02	;Generate
	STA $9C		;A
	JSL $00BEB0|!bank	;blank block
	%create_smoke()	;make smoke (er...sand)
RETURN2:
RTL

SpriteV:
MarioSide:
MarioBelow:
SpriteH:
MarioCape:
MarioFireBall:
	RTL

print "A SMB2-style diggable sand block."