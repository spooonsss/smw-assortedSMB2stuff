;; Sand Block. By ICB. Make act like Block 25

db $42

JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireBall : JMP RETURN2 : JMP RETURN2 : JMP RETURN2

MarioAbove:
	LDY #$01	;act like tile 130
	LDA #$30	;If standing on top
	STA $1693
LDA $16			;If button
AND #$40		;Y or X isn't pressed
BEQ RETURN2		;return
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
	LDY #$01	;act like tile 130
	LDA #$30	;to sprites
	STA $1693	;that are walking on top
MarioSide:
MarioBelow:
SpriteH:
MarioCape:
MarioFireBall:
	RTL

print "A SMB2-style diggable sand block."