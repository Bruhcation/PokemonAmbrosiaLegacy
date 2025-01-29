	db WIGGLYTUFF ; 040

	db 140,  70,  55,  45,  85,  55
	;   hp  atk  def  spd  sat  sdf

	db NORMAL, FAIRY ; type
	db 50 ; catch rate
	db 109 ; base exp
	db NO_ITEM, NO_ITEM ; items
	db GENDER_F75 ; gender ratio
	db 100 ; unknown 1
	db 5 ; step cycles to hatch
	db 5 ; unknown 2
	INCBIN "gfx/pokemon/wigglytuff/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_FAST ; growth rate
	dn EGG_FAIRY, EGG_FAIRY ; egg groups

	; tm/hm learnset
	tmhm DRAIN_PUNCH, BODY_SLAM, HEADBUTT, CURSE, TOXIC, HIDDEN_POWER, SUNNY_DAY, BLIZZARD, ICE_BEAM, HYPER_BEAM, PROTECT, RAIN_DANCE, SUBSTITUTE, SOLARBEAM, THUNDER, RETURN, DOUBLE_EDGE, PSYCHIC_M, CALM_MIND, AURA_SPHERE, SHADOW_BALL, DARK_PULSE, ICE_PUNCH, SLEEP_TALK, FIRE_BLAST, THUNDERPUNCH, REST, FIRE_PUNCH, STRENGTH, FLASH, FLAMETHROWER, THUNDERBOLT, THUNDER_WAVE, ICE_BEAM, SWIFT, IRON_HEAD
	; end
