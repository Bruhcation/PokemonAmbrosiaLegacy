	db LUCARIO ; 162

	db  70,  110,  70,  90,  115,  70
	;   hp  atk  def  spd  sat  sdf

	db FIGHTING, STEEL ; type
	db 45 ; catch rate
	db 193 ; base exp
	db NO_ITEM, NO_ITEM ; items
	db GENDER_F25 ; gender ratio
	db 100 ; unknown 1
	db 20 ; step cycles to hatch
	db 5 ; unknown 2
	INCBIN "gfx/pokemon/machamp/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_SLOW ; growth rate
	dn EGG_HUMANSHAPE, EGG_HUMANSHAPE ; egg groups

	; tm/hm learnset
	tmhm DRAIN_PUNCH, BODY_SLAM, BULK_UP, HEADBUTT, CURSE, TOXIC, ROCK_SMASH, HIDDEN_POWER, HYPER_BEAM, PROTECT, SUBSTITUTE, EARTHQUAKE, EARTH_POWER, ROCK_SLIDE, RETURN, DOUBLE_EDGE, DIG, ICE_PUNCH, SLEEP_TALK, THUNDERPUNCH, REST, FIRE_PUNCH, STRENGTH, ROCK_SLIDE, SWORDS_DANCE, NASTY_PLOT, AURA_SPHERE
	; end
