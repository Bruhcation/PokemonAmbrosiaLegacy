	db BUTTERFREE ; 012

	db  60,  45,  50,  70,  85,  85
	;   hp  atk  def  spd  sat  sdf

	db BUG, PSYCHIC_TYPE ; type
	db 45 ; catch rate
	db 100 ; base exp
	db SILVERPOWDER, NO_ITEM ; items
	db GENDER_F50 ; gender ratio
	db 100 ; unknown 1
	db 5 ; step cycles to hatch
	db 5 ; unknown 2
	INCBIN "gfx/pokemon/butterfree/front.dimensions"
	dw NULL, NULL ; unused (beta front/back pics)
	db GROWTH_MEDIUM_FAST ; growth rate
	dn EGG_BUG, EGG_BUG ; egg groups

	; tm/hm learnset
	tmhm CURSE, TOXIC, HIDDEN_POWER, SUNNY_DAY, HYPER_BEAM, PROTECT, GIGA_DRAIN, SUBSTITUTE, SOLARBEAM, RETURN, DOUBLE_EDGE, PSYCHIC_M, SLEEP_TALK, SWIFT, REST, FLASH, ROOST, SLUDGE_BOMB
	; end
