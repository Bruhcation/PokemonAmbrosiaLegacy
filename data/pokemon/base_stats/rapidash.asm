	db RAPIDASH ; 078

	db  65, 100,  70, 115, 100,  80
	;   hp  atk  def  spd  sat  sdf

	db FIRE, FIRE ; type
	db 60 ; catch rate
	db 192 ; base exp
	db NO_ITEM, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	db 100 ; unknown 1
	db 5 ; step cycles to hatch
	db 5 ; unknown 2
	INCBIN "gfx/pokemon/rapidash/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	dn EGG_GROUND, EGG_GROUND ; egg groups

	; tm/hm learnset
	tmhm HEADBUTT, BODY_SLAM, CURSE, TOXIC, HIDDEN_POWER, SUNNY_DAY, HYPER_BEAM, PROTECT, SUBSTITUTE, IRON_HEAD, RETURN, DOUBLE_EDGE, SLEEP_TALK, FIRE_BLAST, SWIFT, REST, FLAMETHROWER, HORN_DRILL, THUNDERBOLT, SOLARBEAM, CALM_MIND, FLASH, EARTHQUAKE
	; end
