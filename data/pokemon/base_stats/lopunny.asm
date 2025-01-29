	db LOPUNNY ; 022

	db  65, 106,  84, 105,  54,  96
	;   hp  atk  def  spd  sat  sdf

	db FAIRY, FIGHTING ; type
	db 60 ; catch rate
	db 178 ; base exp
	db NO_ITEM, NO_ITEM ; items
	db GENDER_F75 ; gender ratio
	db 100 ; unknown 1
	db 5 ; step cycles to hatch
	db 5 ; unknown 2
	INCBIN "gfx/pokemon/dragonite/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	dn EGG_FAIRY, EGG_FAIRY ; egg groups

	; tm/hm learnset
	tmhm DRAIN_PUNCH, BODY_SLAM, HEADBUTT, CURSE, ROCK_SMASH, HIDDEN_POWER, SUNNY_DAY, BLIZZARD, ICE_BEAM, ICY_WIND, PROTECT, SUBSTITUTE, IRON_HEAD, THUNDER, RETURN, DOUBLE_EDGE, DIG, SHADOW_BALL, SLEEP_TALK, SWIFT, REST, FIRE_PUNCH, ICE_PUNCH, THUNDERPUNCH, SWORDS_DANCE
	; end
