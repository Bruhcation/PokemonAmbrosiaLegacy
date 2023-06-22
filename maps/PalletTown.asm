	object_const_def
	const PALLETTOWN_TEACHER
	const PALLETTOWN_FISHER
	const PALLETTOWN_AERITH
	const PALLETTOWN_CRYSTAL
	const PALLETTOWN_POKEBALL

PalletTown_MapScripts:
	def_scene_scripts

	def_callbacks
	callback MAPCALLBACK_NEWMAP, .FlyPoint
	callback MAPCALLBACK_OBJECTS, .Aerith

.FlyPoint:
	setflag ENGINE_FLYPOINT_PALLET
	endcallback

.Aerith:
    disappear PALLETTOWN_CRYSTAL
    appear PALLETTOWN_AERITH
    checkevent EVENT_BEAT_AERITH_1
    iftrue .end
    disappear PALLETTOWN_AERITH
.end
    endcallback

PalletTownTeacherScript:
	jumptextfaceplayer PalletTownTeacherText

PalletTownFisherScript:
	jumptextfaceplayer PalletTownFisherText

PalletTownSign:
	jumptext PalletTownSignText

RedsHouseSign:
	jumptext RedsHouseSignText

OaksLabSign:
	jumptext OaksLabSignText

BluesHouseSign:
	jumptext BluesHouseSignText

PalletTownTeacherText:
	text "I'm raising #-"
	line "MON too."

	para "They serve as my"
	line "private guards."
	done

PalletTownFisherText:
	text "Technology is"
	line "incredible!"

	para "You can now trade"
	line "#MON across"
	cont "time like e-mail."
	done

PalletTownSignText:
	text "PALLET TOWN"

	para "A Tranquil Setting"
	line "of Peace & Purity"
	done

RedsHouseSignText:
	text "RED'S HOUSE"
	done

OaksLabSignText:
	text "OAK #MON"
	line "RESEARCH LAB"
	done

BluesHouseSignText:
	text "BLUE'S HOUSE"
	done

Aerith2Script:
    faceplayer
	opentext
	checkevent EVENT_BEAT_AERITH_2
	iftrue .FightDone
.fight
	writetext Aerith2SeenText
	waitbutton
	closetext
	checkevent EVENT_BEAT_AERITH_2
	iftrue .dontAsk
	opentext
	writetext Aerith2OfferFightText
	waitbutton
	yesorno
	iffalse .refused
	closetext
.dontAsk
	winlosstext Aerith2BeatenText, Aerith2WinsText
	loadvar VAR_BATTLETYPE, BATTLETYPE_BOSS_BATTLE
	loadtrainer KIMONO_GIRL, AERITH_2
	startbattle
	reloadmapafterbattle
	setevent EVENT_BEAT_AERITH_2
	end
.FightDone:
	writetext Aerith2AfterBattleText
	waitbutton
    closetext
	opentext
	writetext RematchTextAerith2
	yesorno
	iftrue .fight
.refused
	writetext RematchRefuseTextAerith2
	waitbutton
	closetext
	end
Aerith2SeenText:
    text "Hey <PLAYER>!"

    para "What brings you"
    line "here?"

    para "I can feel there"
    line "something special"
    cont "about this town."

    para "The earth tells"
    line "me this is a very"
    cont "important place."

    para "I've heard people"
    line "talking about a"
    cont "war."

    para "Typical humans and"
    line "their petty"
    cont "desires."

    para "I will defend"
    line "the planet against"
    cont "all of them!"
    done
Aerith2BeatenText:
    text "Well done"
    done
Aerith2WinsText:
    text "Good try"
    done
Aerith2OfferFightText:
    text "Let's have a"
    line "fight!?"
    done
Aerith2AfterBattleText:
    text "No matter what"
    line "happens you"
    cont "have to protect"
    cont "the planet OK."

    para "It's like a child"
    line "lost and looking"
    cont "for it's mother."

    para "I can hear her"
    line "crying."

    para "can't you."
    done
RematchTextAerith2:
    text "Let's fight?"
    done
RematchRefuseTextAerith2:
    text "That's fine!"
    done

PalletTownCrystalScript1:
    checkevent EVENT_BEAT_ELITE_FOUR
    iffalse .end
    checkevent EVENT_BEAT_CRYSTAL_6
    iftrue .end
    showemote EMOTE_SHOCK, PLAYER, 15
    applymovement PLAYER, PalletTownMovement_PlayerRight
    sjump PalletTownCrystalScript
.end
    end

PalletTownCrystalScript2:
    checkevent EVENT_BEAT_ELITE_FOUR
    iffalse .end
    checkevent EVENT_BEAT_CRYSTAL_6
    iftrue .end
    showemote EMOTE_SHOCK, PLAYER, 15
    turnobject PLAYER, DOWN
    sjump PalletTownCrystalScript
.end
    end
    
PalletTownCrystalScript:
    playmusic MUSIC_CRYSTAL_ENCOUNTER
    appear PALLETTOWN_CRYSTAL
    applymovement PALLETTOWN_CRYSTAL, PalletTownMovement_CrystalApproaches

    opentext
    writetext PalletTownCrystalText_Intro
    waitbutton
    closetext

	winlosstext Crystal6LosesText, Crystal6WinsText
    loadvar VAR_BATTLETYPE, BATTLETYPE_SETNOITEMS
	loadtrainer CRYSTAL, CRYSTAL_6
	startbattle
	reloadmapafterbattle
	setevent EVENT_BEAT_CRYSTAL_6

    special FadeOutMusic
	opentext
	writetext PalletTownCrystalText_KeepItUp
	waitbutton
	closetext
	applymovement PALLETTOWN_CRYSTAL, PalletTownMovement_CrystalLeaves
	disappear PALLETTOWN_CRYSTAL
	special RestartMapMusic
	end

PalletTownMovement_PlayerRight:
    step RIGHT
    turn_head DOWN
    step_end

PalletTownMovement_CrystalApproaches:
    big_step UP
    big_step UP
    big_step UP
    big_step UP
    step_end

PalletTownCrystalText_Intro:
    text "Hey there CHAMPION"
    line "<PLAYER>!"

    para "It's been a while!"

    para "You know I always"
    line "thought KANTO was"
    cont "much more urban"
    cont "and polluted than"
    cont "JOHTO."

    para "But this place is"
    line "nice."

    para "There is something"
    line "about it."

    para "It reminds me of"
    line "home."

    para "...."

    para "I have heard that"
    line "HOEN may invade"
    cont "any day now."

    para "I bet you have"
    line "got even stronger"
    cont "since we last"
    cont "fought."

    para "I want to be able"
    line "to fight back and"
    cont "protect these"
    cont "people."

    para "Help me become"
    line "stronger."
    done

Crystal6LosesText:
    text "I don't think"
    line "I'll ever be as"
    cont "strong as you."
    done

Crystal6WinsText:
    text "I'm ready to"
    line "fight."
    done

PalletTownCrystalText_KeepItUp:
    text "The next time we"
    line "see eachother we"
    cont "might be fighting"
    cont "not for fun, but"
    cont "our lives."

    para "For the lives of"
    line "everyone."

    para "I can't imagine"
    line "anyone beating"
    cont "you!"

    para "When HOEN invade"
    line "I know you will"
    cont "defeat them."

    para "I wont let you"
    line "down!"
    done

PalletTownMovement_CrystalLeaves:
    big_step LEFT
    big_step UP
    big_step UP
    big_step UP
    big_step UP
    big_step UP
    big_step UP
    step_end

PalletTownFocusSash:
	itemball FOCUS_SASH

PalletTown_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  5,  5, REDS_HOUSE_1F, 1
	warp_event 13,  5, BLUES_HOUSE, 1
	warp_event 12, 11, OAKS_LAB, 1

	def_coord_events
	coord_event 8,  2, SCENE_ALWAYS, PalletTownCrystalScript1
	coord_event 9,  2, SCENE_ALWAYS, PalletTownCrystalScript2

	def_bg_events
	bg_event  7,  9, BGEVENT_READ, PalletTownSign
	bg_event  3,  5, BGEVENT_READ, RedsHouseSign
	bg_event 13, 13, BGEVENT_READ, OaksLabSign
	bg_event 11,  5, BGEVENT_READ, BluesHouseSign

	def_object_events
	object_event  3,  8, SPRITE_TEACHER, SPRITEMOVEDATA_WANDER, 2, 2, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, PalletTownTeacherScript, -1
	object_event 12, 14, SPRITE_FISHER, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 2, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, PalletTownFisherScript, -1
	object_event  6, 13, SPRITE_KIMONO_GIRL, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, Aerith2Script, EVENT_FIELD_MON_1
	object_event 9,  7, SPRITE_BEAUTY, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_TEMP_EVENT_1
	object_event  7, 38, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, PalletTownFocusSash, EVENT_PALLET_TOWN_FOCUS_SASH
